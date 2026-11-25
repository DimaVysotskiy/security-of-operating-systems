FROM alt:p11

# Подготовка к заданиям 6.1–6.7. Устанавливаем getfacl и setfacl из пакета acl.
RUN set -eu; \
    apt-get update; \
    apt-get install -y acl; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Подготовка к проверкам доступа. Создаём пользователей и назначаем основные группы.
RUN set -eu; \
    groupadd managers; \
    groupadd specialists; \
    for account in user1 user2; do \
        useradd -m -s /bin/bash -g managers "$account"; \
    done; \
    for account in user3 user4; do \
        useradd -m -s /bin/bash -g specialists "$account"; \
    done

# Задания 6.1–6.2. Создаём учебные каталоги с исходными владельцами и правами.
RUN set -eu; \
    install -d -o root -g root -m 0775 /home/work; \
    install -d -o root -g root -m 0770 \
        /home/work/total_data /home/work/daily_data /home/work/tasks

# Задание 6.1. Демонстрационный ACL для tasks применяется при первом запуске.
COPY init.sh /usr/local/sbin/lab05-init.sh
ENTRYPOINT ["/bin/bash", "/usr/local/sbin/lab05-init.sh"]
CMD ["sleep", "infinity"]
