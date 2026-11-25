FROM alt:p11 AS base

RUN set -eu; \
    apt-get update; \
    apt-get install -y login passwd pam pam0_tcb pam0_passwdqc shadow-change; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

COPY policy/ /usr/local/share/lab02/
COPY configure.sh /usr/local/share/lab02/configure.sh
CMD ["sleep", "infinity"]

FROM base AS lab02

RUN set -eu; \
    bash /usr/local/share/lab02/configure.sh; \
    useradd -U -m -s /bin/bash -G users -c 'Иван Иванов' user1; \
    useradd -U -m -s /bin/bash -G users -c 'Мария Кузнецова' user2; \
    useradd -U -m -s /bin/bash -G users -c 'Николай Николаев' user3; \
    useradd -U -m -s /bin/bash -G users -c 'Сергей Сергеев' user4
