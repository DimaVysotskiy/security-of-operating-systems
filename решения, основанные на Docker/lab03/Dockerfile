FROM alt:p11

ARG ALT_APT_MIRROR

RUN set -eu; \
    set --; \
    if [ -n "${ALT_APT_MIRROR:-}" ]; then \
        awk -v mirror="${ALT_APT_MIRROR%/}" '$1 == "rpm" && $4 !~ /-i586$/ { $3 = mirror; print }' \
            /etc/apt/sources.list.d/alt.list > /tmp/lab-apt.list; \
        set -- -o Dir::Etc::sourcelist=/tmp/lab-apt.list -o Dir::Etc::sourceparts=-; \
    fi; \
    apt-get "$@" update; \
    apt-get "$@" install -y shadow-groups; \
    apt-get clean; \
    rm -f /tmp/lab-apt.list; \
    rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    if ! grep -q '^users:' /etc/group; then groupadd users; fi; \
    for account in user1 user2 user3 user4; do \
        useradd -U -m -s /bin/bash -G users "$account"; \
    done; \
    groupadd managers; \
    groupadd specialists; \
    groupadd tests; \
    install -d -m 0755 /opt/lab03; \
    printf '%s\n' 'Учебный файл группы tests' > /opt/lab03/test.txt; \
    chown root:tests /opt/lab03/test.txt; \
    chmod 0640 /opt/lab03/test.txt

CMD ["sleep", "infinity"]
