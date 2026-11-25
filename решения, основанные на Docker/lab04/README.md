# Лабораторная работа № 4. Основные права доступа

Цель — проверить, как владелец, группа, права каталогов и `umask` влияют на работу с файлами. Номера заданий сохранены из [исходной методички](<../../исходники (Прокушев, Я.Е. Информационная безопасность операционных систем Linux : практикум по защите информации)/исходники отцифрованные в md формат/lab-04.md>).

## Предусловия

Эти настройки применяются при сборке образа. В [diff.md](diff.md) указано, какие шаги перенесены в Dockerfile и какие выполняет студент.

### 1. Базовый образ

Для стенда используется ALT Linux p11. [Dockerfile, строка 1](Dockerfile#L1)

### 2. Пользователи и основные группы (подготовка к заданию 5.2)

Dockerfile создаёт группы `managers` и `specialists`. Основная группа `user1` и `user2` — `managers`, у `user3` и `user4` — `specialists`. Для каждой учётной записи создаётся домашний каталог, оболочкой назначается Bash. При сборке пароли не задаются. [Dockerfile, строки 4–12](Dockerfile#L4-L12)

### 3. Учебные каталоги и исходные права (задание 5.1)

Dockerfile создаёт `/home/work` и три вложенных каталога: `total_data`, `daily_data` и `tasks`. Для каждого каталога заданы владелец `root`, группа `root` и режим `0755`. Учебные пользователи могут открывать эти каталоги, а создавать в них файлы смогут после изменения прав в задании 5.2. [Dockerfile, строки 15–17](Dockerfile#L15-L17)

## Запуск стенда

Выполните на хосте из каталога с `compose.yaml`:

```bash
docker compose up -d --build lab04
docker compose exec lab04 bash
```

[Compose](../compose.yaml) запускает контейнер `lab04` с именем хоста `wrk1`. Команда `sleep infinity` удерживает контейнер запущенным между сеансами. [Dockerfile, строка 19](Dockerfile#L19)

## Практические задания

Команды выполняйте внутри контейнера от `root`. Для проверок от имени учебных пользователей используйте `runuser`. С ключом `-l` он открывает сеанс входа, в котором Bash читает системный профиль. Это используется в задании 5.4.

### 5.1. Проверьте исходные права

```bash
ls -la /home/work
for directory in /home/work/{total_data,daily_data,tasks}; do
    runuser -u user1 -- bash -c 'cd "$1" && pwd && touch default-check.txt' _ "$directory"
done
```

Переход в каждый каталог должен пройти, а создание файла — закончиться отказом. Запишите владельцев, группы и права каталогов. Объясните, почему `x` на каталоге разрешает переход, а для создания файла нужны `w` и `x`.

### 5.2. Настройте права на каталоги

1. Назначьте `managers` группой владельца `total_data` и разрешите ей полный доступ. Снимите права остальных пользователей отдельной командой и сравните результаты двух проверок:

   ```bash
   chgrp managers /home/work/total_data
   chmod g=rwx /home/work/total_data
   ls -ld /home/work/total_data
   chmod o= /home/work/total_data
   ls -ld /home/work/total_data
   ```

2. Настройте `daily_data` для группы `specialists`. Остальные смогут просматривать каталог и проходить в него, но не смогут создавать в нём файлы:

   ```bash
   chgrp specialists /home/work/daily_data
   chmod 0775 /home/work/daily_data
   ```

3. Для `tasks` назначьте группу `managers` и покажите все три специальных бита на каталоге:

   ```bash
   chgrp managers /home/work/tasks
   chmod 7775 /home/work/tasks
   ls -la /home/work
   id user2
   id user3
   ```

   Снимите биты по одному и каждый раз смотрите, какая буква меняется:

   ```bash
   chmod g-s /home/work/tasks
   ls -ld /home/work/tasks
   chmod u-s /home/work/tasks
   ls -ld /home/work/tasks
   chmod -t /home/work/tasks
   ls -ld /home/work/tasks
   ```

   В конце ожидаются `0770 root:managers` для `total_data`, `0775 root:specialists` для `daily_data` и `0775 root:managers` для `tasks`. Бит SUID здесь только демонстрируется на каталоге: он не меняет UID процесса.

### 5.3. Проверьте совместное редактирование

1. От имени `user3` создайте два файла с маской `022` и добавьте группе право записи только в первый файл:

   ```bash
   runuser -u user3 -- bash -c '
       cd /home/work/daily_data || exit
       umask 022
       printf "%s\n" "Файл пользователя user3" > test31.txt
       printf "%s\n" "Файл пользователя user3" > test32.txt
       ls -l test31.txt test32.txt
       chmod g+w test31.txt
       ls -l test31.txt test32.txt
   '
   ```

2. От имени `user4` попробуйте дописать текст в каждый файл, изменить права второго файла и сохранить отдельную копию:

   ```bash
   runuser -u user4 -- bash -c 'echo "Изменение от user4" >> /home/work/daily_data/test31.txt'
   runuser -u user4 -- bash -c 'echo "Изменение от user4" >> /home/work/daily_data/test32.txt'
   runuser -u user4 -- chmod g+w /home/work/daily_data/test32.txt
   runuser -u user4 -- cp /home/work/daily_data/test32.txt /home/work/daily_data/test32-copy.txt
   ```

   Запись в `test31.txt` и копирование должны пройти. Запись в `test32.txt` и изменение его прав должны завершиться отказом. Права на файл не мешают создать его копию: для этого нужны чтение исходного файла и запись в каталог.

3. От имени `user4` самостоятельно создайте непустой `test41.txt` в `daily_data`. Дайте группе `specialists` право записи в файл и проверьте его от имени `user3`.

### 5.4. Исследуйте влияние `umask`

Настройте маску для новых сеансов Bash через `/etc/profile.d/`. Откройте новый сеанс, чтобы применить её:

```bash
printf '%s\n' 'umask 002' > /etc/profile.d/zz-lab04-umask.sh
runuser -l user2 -c 'umask; cd /home/work/total_data && echo "Файл user2" > test2.txt && ls -l test2.txt'
runuser -u user1 -- bash -c 'echo "Изменение от user1" >> /home/work/total_data/test2.txt'
runuser -l user3 -c 'umask; cd /home/work/daily_data && echo "Файл user3" > test3.txt && ls -l test3.txt'
runuser -u user4 -- bash -c 'echo "Изменение от user4" >> /home/work/daily_data/test3.txt'
```

Новые обычные файлы должны получить `0664`, поэтому участники соответствующих групп смогут их редактировать. Сравните этот режим с `0644` из задания 5.3. Маска убирает биты из режима, запрошенного программой, обычно `0666` для файла и `0777` для каталога. У `test2.txt` будет бит чтения для остальных, но открыть файл смогут только те, у кого есть право прохода через `total_data` с режимом `0770`.

## Отчёт и контрольные вопросы

Сохраните вывод `ls` до и после изменения прав, результаты попыток записи от разных пользователей и сравнение двух значений `umask`.

1. Какие привилегии доступа к ресурсам предусмотрены в базовой системе разграничения прав доступа Linux?
2. Какие роли пользователей предусмотрены в базовой системе разграничения прав доступа Linux?
3. Для чего применяются SUID, SGID и sticky bit?
4. Для чего нужна команда `chmod` и каков её синтаксис?
5. Для чего нужна команда `chown` и каков её синтаксис?
6. Для чего нужна команда `chgrp` и каков её синтаксис?
7. Как просматривать права командой `ls`?
8. Что означают режимы `0750`, `0777`, `2770` и `2760`?
9. Как снять SUID, SGID и sticky bit с каталога?
10. Для чего нужна `umask`?
11. Как изменить `umask` для текущего и для новых сеансов?
