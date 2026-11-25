FROM alt:p11

RUN set -eu; \
    groupadd managers; \
    groupadd specialists; \
    for account in user1 user2; do \
        useradd -m -s /bin/bash -g managers "$account"; \
    done; \
    for account in user3 user4; do \
        useradd -m -s /bin/bash -g specialists "$account"; \
    done; \
    install -d -o root -g root -m 0755 \
        /home/work /home/work/total_data /home/work/daily_data /home/work/tasks

CMD ["sleep", "infinity"]
