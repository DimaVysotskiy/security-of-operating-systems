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
    apt-get "$@" install -y apt-repo diffutils ethtool iproute2 iputils nano net-tools; \
    apt-get clean; \
    rm -f /tmp/lab-apt.list; \
    rm -rf /var/lib/apt/lists/*; \
    useradd -U -m -s /bin/bash admin; \
    install -d -o admin -g admin -m 0755 /home/admin/version_1

COPY lab01-snapshot.sh /usr/local/bin/lab01-snapshot
RUN chmod 0755 /usr/local/bin/lab01-snapshot

CMD ["sleep", "infinity"]
