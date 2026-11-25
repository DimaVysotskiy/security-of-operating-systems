FROM alt:p11

RUN set -eu; \
    apt-get update; \
    apt-get install -y login passwd pam pam0_tcb pam0_passwdqc shadow-change; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Шаблоны для самостоятельной настройки в заданиях 3.10–3.11.
COPY policy/ /usr/local/share/lab02/
COPY configure.sh /usr/local/share/lab02/configure.sh

CMD ["sleep", "infinity"]
