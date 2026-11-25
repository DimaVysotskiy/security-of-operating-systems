FROM alt:p11

RUN set -eu; \
    apt-get update; \
    apt-get install -y login passwd pam pam0_tcb pam0_passwdqc shadow-change; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

COPY policy/ /usr/local/share/lab02/
COPY configure.sh /usr/local/share/lab02/configure.sh

# Задания 3.1–3.4. Применяем настройки паролей и PAM.
RUN bash /usr/local/share/lab02/configure.sh

# Задание 3.5. Создаём учебные учётные записи.
RUN set -eu; \
    useradd -U -m -s /bin/bash -G users -c 'Иван Иванов' user1; \
    useradd -U -m -s /bin/bash -G users -c 'Мария Кузнецова' user2; \
    useradd -U -m -s /bin/bash -G users -c 'Николай Николаев' user3; \
    useradd -U -m -s /bin/bash -G users -c 'Сергей Сергеев' user4

CMD ["sleep", "infinity"]
