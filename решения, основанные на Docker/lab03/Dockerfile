FROM alt:p11

# Подготовка стенда. Устанавливаем shadow-groups для задания 4.4.
RUN set -eu; \
    apt-get update; \
    apt-get install -y shadow-groups; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Подготовка к заданиям 4.1 и 4.3. Создаём пользователей и обеспечиваем членство в users.
RUN set -eu; \
    if ! grep -q '^users:' /etc/group; then groupadd users; fi; \
    for account in user1 user2 user3 user4; do \
        useradd -U -m -s /bin/bash -G users "$account"; \
    done

# Задание 4.2. Создаём группы для работы с членством.
RUN set -eu; \
    groupadd managers; \
    groupadd specialists; \
    groupadd tests

# Задание 4.4. Подготавливаем файл для проверки группового доступа.
RUN set -eu; \
    install -d -m 0755 /opt/lab03; \
    printf '%s\n' 'Учебный файл группы tests' > /opt/lab03/test.txt; \
    chown root:tests /opt/lab03/test.txt; \
    chmod 0640 /opt/lab03/test.txt

CMD ["sleep", "infinity"]
