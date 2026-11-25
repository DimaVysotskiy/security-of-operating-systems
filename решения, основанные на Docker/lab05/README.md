# Лабораторная работа № 5. Списки контроля доступа (ACL)

Цель — настроить разные права для двух групп, проверить наследование ACL и увидеть действие маски эффективных прав. Номера заданий сохранены из [исходной методички](<../../исходники (Прокушев, Я.Е. Информационная безопасность операционных систем Linux : практикум по защите информации)/исходники отцифрованные в md формат/lab-05.md>).

## Предусловия

Начальное состояние стенда задают Dockerfile и скрипт первого запуска. В [diff.md](diff.md) указано, какие шаги методички выполняются при подготовке и какие выполняет студент.

### 1. Базовый образ и утилиты ACL

Используется ALT Linux p11. При сборке APT обновляет индексы штатных репозиториев и устанавливает пакет `acl`, в который входят `getfacl` и `setfacl`. После установки скачанные архивы и индексы удаляются. [Dockerfile, строки 1–8](Dockerfile#L1-L8)

### 2. Учётные записи и основные группы

Dockerfile создаёт группы `managers` и `specialists`. У `user1` и `user2` основная группа `managers`, у `user3` и `user4` — `specialists`. Для каждой учётной записи создаётся домашний каталог и назначается оболочка Bash. Пароли при сборке не задаются. [Dockerfile, строки 11–19](Dockerfile#L11-L19)

### 3. Учебные каталоги и обычные права (задания 6.1–6.2)

Dockerfile создаёт `/home/work` с владельцем `root:root` и правами `0775`. Вложенные каталоги `total_data`, `daily_data` и `tasks` получают владельца `root:root` и права `0770`. Учебные пользователи могут перечислять имена в `/home/work`. Доступ внутрь `total_data` и `daily_data` студент открывает, когда настраивает ACL в заданиях 6.3 и 6.5. [Dockerfile, строки 22–25](Dockerfile#L22-L25)

### 4. Демонстрационный ACL для `tasks` (задание 6.1)

При первом запуске `init.sh` добавляет на `/home/work/tasks` именованные записи `user:root:rwx` и `group:root:rwx`, а для остальных задаёт `r-x`. ACL устанавливается в файловой системе контейнера, поэтому проверка не зависит от сохранения ACL в слоях образа. После успешной настройки скрипт записывает отметку `/var/lib/lab05/initialized`. При перезапуске существующего контейнера отметка сохраняется, и изменения студента не сбрасываются. [Dockerfile, строки 28–30](Dockerfile#L28-L30), [init.sh, строки 4–11](init.sh#L4-L11)

## Запуск стенда

Выполните на хосте из каталога с `compose.yaml`:

```bash
docker compose up -d --build lab05
docker compose exec lab05 bash
```

[Compose](../compose.yaml) запускает контейнер `lab05` с именем хоста `wrk1`. После подготовки команда `sleep infinity` удерживает контейнер запущенным между сеансами.

## Практические задания

Команды выполняйте внутри контейнера от `root`. Для проверок под учебными пользователями используйте `runuser`. Поддержку ACL проверяйте по выводу `getfacl` и результатам фактического доступа к учебным файлам.

### 6.1. Просмотрите исходные права

```bash
stat /home/work
ls -la /home/work
getfacl -p /home/work/tasks
```

Сравните обычные права `total_data` и `daily_data` с расширенными правами `tasks`. У `tasks` в выводе `ls` есть `+`; в `getfacl` найдите именованные записи для пользователя и группы `root`, а также строку `mask::`.

### 6.2. Подготовьте каталоги к настройке ACL

Уберите демонстрационный ACL. Проверьте доступ к родительскому каталогу и к закрытому подкаталогу от имени `user1`:

```bash
setfacl -b /home/work/tasks
chmod 0770 /home/work/tasks
ls -la /home/work
runuser -u user1 -- ls /home/work
runuser -u user1 -- ls /home/work/total_data
```

`/home/work` принадлежит `root:root` и имеет права `0775`: учебный пользователь видит имена подкаталогов. Подкаталоги имеют режим `0770` и пока закрыты для учебных групп. Запишите результаты обеих проверок.

### 6.3. Настройте ACL для `total_data`

```bash
setfacl -m 'g:managers:rwx,m::rwx' /home/work/total_data
setfacl -d -m 'g:managers:rwx,m::rwx' /home/work/total_data
getfacl -p /home/work/total_data
```

Сравните запись `group:managers:rwx` с `default:group:managers:rwx`: первая действует на сам каталог, вторая участвует в наследовании при создании объектов.

### 6.4. Проверьте доступ к `total_data`

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

### 6.5. Настройте и проверьте ACL для `daily_data`

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

### 6.6. Исследуйте маску эффективных прав

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

### 6.7. Самостоятельно настройте общий каталог

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
