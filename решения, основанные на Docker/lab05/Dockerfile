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
    apt-get "$@" install -y acl; \
    apt-get clean; \
    rm -f /tmp/lab-apt.list; \
    rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    groupadd managers; \
    groupadd specialists; \
    for account in user1 user2; do \
        useradd -m -s /bin/bash -g managers "$account"; \
    done; \
    for account in user3 user4; do \
        useradd -m -s /bin/bash -g specialists "$account"; \
    done; \
    install -d -o root -g root -m 0775 /home/work; \
    install -d -o root -g root -m 0770 \
        /home/work/total_data /home/work/daily_data /home/work/tasks

COPY init.sh /usr/local/sbin/lab05-init.sh
ENTRYPOINT ["/bin/bash", "/usr/local/sbin/lab05-init.sh"]
CMD ["sleep", "infinity"]
