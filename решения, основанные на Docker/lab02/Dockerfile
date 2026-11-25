FROM alt:p11 AS base

ARG ALT_APT_MIRROR

RUN set -eu; \
    set --; \
    if [ -n "${ALT_APT_MIRROR:-}" ]; then \
        awk -v mirror="${ALT_APT_MIRROR%/}" '$1 == "rpm" && $4 !~ /-i586$/ { $3 = mirror; print }' \
            /etc/apt/sources.list.d/alt.list > /tmp/lab-apt.list; \
        set -- -o Dir::Etc::sourcelist=/tmp/lab-apt.list -o Dir::Etc::sourceparts=-; \
    fi; \
    apt-get "$@" update; \
    apt-get "$@" install -y login passwd pam pam0_tcb pam0_passwdqc shadow-change; \
    apt-get clean; \
    rm -f /tmp/lab-apt.list; \
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
