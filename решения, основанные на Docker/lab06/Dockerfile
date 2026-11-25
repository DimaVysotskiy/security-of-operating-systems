FROM alt:p11

RUN set -eu; \
    apt-get update; \
    apt-get install -y nano osec osec-mailreport util-linux vixie-cron; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    install -d -m 0755 /etc/lab06 /home/lab06-baseline /home/test3; \
    install -d -o osec -g osec -m 0750 /var/lib/lab06-osec; \
    if [ -f /etc/cron.d/osec ]; then mv /etc/cron.d/osec /etc/lab06/osec.cron.example; fi; \
    printf '%s\n' 'Контрольный файл' > /home/lab06-baseline/base.txt; \
    printf '%s\n' 'Исходное содержимое asd.txt' > /home/test3/asd.txt; \
    printf '%s\n' 'Исходное содержимое qwe.txt' > /home/test3/qwe.txt; \
    chmod 0644 /home/lab06-baseline/base.txt /home/test3/asd.txt /home/test3/qwe.txt

COPY dirs.conf /etc/lab06/dirs.conf
COPY run-osec.sh /usr/local/sbin/lab06-run-osec
RUN chmod 0644 /etc/lab06/dirs.conf && chmod 0755 /usr/local/sbin/lab06-run-osec

ENV EDITOR=nano
CMD ["/usr/sbin/crond", "-n"]
