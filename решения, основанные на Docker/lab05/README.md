# Лабораторная работа № 5. Списки контроля доступа (ACL)

Цель — настроить разные права для двух групп, проверить наследование ACL и увидеть действие маски эффективных прав. Номера заданий сохранены из [исходной методички](<../../исходники (Прокушев, Я.Е. Информационная безопасность операционных систем Linux : практикум по защите информации)/исходники отцифрованные в md формат/lab-05.md>).

Из каталога с `compose.yaml`:

```bash
docker compose up -d --build lab05
docker compose exec lab05 bash
```

[Dockerfile](Dockerfile) устанавливает `getfacl` и `setfacl`, создаёт учебных пользователей и базовую структуру `/home/work`. Пользователи `user1` и `user2` входят в `managers`, `user3` и `user4` — в `specialists`. При первом запуске [init.sh](init.sh) задаёт демонстрационный ACL каталога `tasks` в файловой системе контейнера, чтобы не зависеть от того, сохраняет ли сборщик образа метаданные ACL в слоях. При обычном перезапуске скрипт не восстанавливает исходные права.

Команды ниже выполняйте внутри контейнера от `root`; для проверок под учебными пользователями используйте `runuser`. Поддержку ACL здесь определяем по установленным записям `getfacl` и фактическому доступу. Разделы хоста, `tune2fs` и `/etc/fstab` для работы не нужны.

## 6.1. Просмотрите исходные права

```bash
stat /home/work
ls -la /home/work
getfacl -p /home/work/tasks
```

Сравните обычные права `total_data` и `daily_data` с расширенными правами `tasks`. У `tasks` в выводе `ls` есть `+`; в `getfacl` найдите именованные записи для пользователя и группы `root`, а также строку `mask::`.

## 6.2. Подготовьте каталоги к настройке ACL

Уберите демонстрационный ACL. Проверьте доступ к родительскому каталогу и к закрытому подкаталогу от имени `user1`:

```bash
setfacl -b /home/work/tasks
chmod 0770 /home/work/tasks
ls -la /home/work
runuser -u user1 -- ls /home/work
runuser -u user1 -- ls /home/work/total_data
```

`/home/work` принадлежит `root:root` и имеет права `0775`: учебный пользователь видит имена подкаталогов. Подкаталоги имеют режим `0770` и пока закрыты для учебных групп. Запишите результаты обеих проверок.

## 6.3. Настройте ACL для `total_data`

```bash
setfacl -m 'g:managers:rwx,m::rwx' /home/work/total_data
setfacl -d -m 'g:managers:rwx,m::rwx' /home/work/total_data
getfacl -p /home/work/total_data
```

Сравните запись `group:managers:rwx` с `default:group:managers:rwx`: первая действует на сам каталог, вторая участвует в наследовании при создании объектов.

## 6.4. Проверьте доступ к `total_data`

```bash
runuser -u user1 -- bash -c '
    cd /home/work/total_data || exit
    echo "Файл user1" > u1.txt
    mkdir f1
    echo "Вложенный файл user1" > f1/u11.txt
    cp u1.txt u1-copy.txt
    cp -r f1 f1-copy
    rm u1-copy.txt f1-copy/u11.txt
    rmdir f1-copy
'
runuser -u user2 -- bash -c '
    cd /home/work/total_data || exit
    mkdir f2
    echo "Файл user2" > u2.txt
    echo "Изменение от user2" >> u1.txt
    rm f1/u11.txt
'
runuser -u user3 -- ls /home/work/total_data
getfacl -p /home/work/total_data/u1.txt /home/work/total_data/f1
```

У `user1` и `user2` операции должны пройти, у `user3` — отказ. Сравните список ACL файла и каталога; права на выполнение обычного файла при создании ограничены режимом, запрошенным программой.

## 6.5. Настройте и проверьте ACL для `daily_data`

Дайте `specialists` право редактирования, а `managers` — чтения и прохода. Настройте ACL самого каталога и наследуемые ACL:

```bash
setfacl -m 'g:specialists:rwx,g:managers:r-x,m::rwx' /home/work/daily_data
setfacl -d -m 'g:specialists:rwx,g:managers:r-x,m::rwx' /home/work/daily_data
getfacl -p /home/work/daily_data
runuser -u user3 -- bash -c '
    cd /home/work/daily_data || exit
    echo "Файл user3" > test31.txt
    mkdir F3
    echo "Вложенный файл user3" > F3/333.txt
'
runuser -u user1 -- cat /home/work/daily_data/F3/333.txt
runuser -u user1 -- bash -c 'echo "Попытка записи" >> /home/work/daily_data/test31.txt'
```

Пользователь `user3` должен создать оба объекта, а `user1` — прочитать файл, но получить отказ при записи. Сохраните вывод `getfacl` и результаты проверок.

## 6.6. Исследуйте маску эффективных прав

1. Уберите `x` из маски доступа на `daily_data`. Сравните именованные записи с эффективными правами. Оба пользователя должны видеть имена в каталоге, но не смогут пройти к файлу:

   ```bash
   setfacl -m 'm::rw-' /home/work/daily_data
   getfacl -ep /home/work/daily_data
   for account in user1 user3; do
       runuser -u "$account" -- ls --color=never /home/work/daily_data
       runuser -u "$account" -- cat /home/work/daily_data/test31.txt
   done
   ```

2. Восстановите маску рекурсивно. Проверьте, как она повлияла на существующий файл. Затем создайте новый текстовый файл и сравните его режим и ACL с существующим:

   ```bash
   setfacl -R -m 'm::rwx' /home/work/daily_data
   runuser -u user1 -- cat /home/work/daily_data/test31.txt
   runuser -u user3 -- bash -c 'echo "Новый текст" > /home/work/daily_data/fresh.txt'
   ls -l /home/work/daily_data/{test31,fresh}.txt
   getfacl -ep /home/work/daily_data/{test31,fresh}.txt
   ```

   Рекурсивная смена маски может сделать существующую запись `x` эффективной. У обычного файла, который только что создан с запрошенным режимом `0666`, бита выполнения нет.

3. Снимите биты выполнения у обычных файлов, оставляя возможность прохода по каталогам:

   ```bash
   find /home/work/daily_data -type f -exec chmod 0660 {} +
   ls -l /home/work/daily_data
   getfacl -ep /home/work/daily_data/test31.txt
   ```

4. Проверьте, что `user4` может создавать, изменять, переименовывать и удалять объекты, а `user1` — только читать и копировать в свой домашний каталог:

   ```bash
   runuser -u user4 -- bash -c '
       cd /home/work/daily_data || exit
       echo "Файл user4" > f44.txt
       mkdir f4
       echo "Изменение от user4" >> test31.txt
       ls F3
       rm fresh.txt
       mv f4 f4-renamed
   '
   runuser -u user1 -- cat /home/work/daily_data/test31.txt
   runuser -u user1 -- cp /home/work/daily_data/test31.txt /home/user1/daily-copy.txt
   runuser -u user1 -- rm /home/work/daily_data/f44.txt
   ```

   Последняя команда должна завершиться отказом. Вместо шага с `auditd` приложите к отчёту команды и их вывод: аудит ядра относится к хосту, у учебного контейнера нет отдельного ядра.

## 6.7. Самостоятельно настройте общий каталог

Создайте `/home/work/exchange` с владельцем `root:root` и базовым режимом `0770`. Командой `setfacl` настройте обеим группам `rwx` на самом каталоге и в записях по умолчанию. Проверьте через `getfacl`, что маска не ограничивает эти права, а `other` не получил доступ.

Через `runuser` создайте текстовый файл и вложенный каталог от имени `user1`. От имени `user3` измените и удалите файл. Затем поменяйте роли: пусть `user3` создаст файл, а `user1` изменит и удалит его. Приложите ACL каталога и результаты команд к отчёту.

## Отчёт и контрольные вопросы

Приложите исходный и итоговый вывод `getfacl`, сравнение масок и результаты успешных и запрещённых операций от имени разных пользователей.

1. Что означает термин ACL?
2. Каковы возможности ACL?
3. Как узнать, что файловая система поддерживает ACL?
4. Как установить права доступа к каталогам и файлам с помощью ACL?
5. Как настроить ACL по умолчанию для новых объектов?
6. Для чего используется маска эффективных прав?
7. Как удалить с объекта настроенные ранее ACL?
8. Как изменить отдельную запись ACL?
9. Как просмотреть установленные ACL?
