FROM alt:p11

RUN set -eu; \
    apt-get update; \
    apt-get install -y shadow-groups; \
    apt-get clean; \
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
