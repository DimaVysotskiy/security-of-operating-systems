FROM alt:p11

# Подготовка стенда. Устанавливаем утилиты до записи исходного списка RPM.
RUN set -eu; \
    apt-get update; \
    apt-get install -y apt-repo diffutils ethtool iproute2 iputils nano net-tools; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Задание 2.1. Создаём учётную запись для лабораторной.
RUN useradd -U -m -s /bin/bash admin

# Задание 2.1. Сохраняем состояние системы до обновления.
RUN set -eu; \
    mkdir -p /home/admin/version_1; \
    chmod 0755 /home/admin/version_1; \
    cat /etc/os-release > /home/admin/version_1/os-release.txt; \
    apt-repo > /home/admin/version_1/repositories.txt; \
    rpm -qa --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' > /home/admin/version_1/packages.txt; \
    LC_ALL=C sort -o /home/admin/version_1/packages.txt /home/admin/version_1/packages.txt; \
    chown admin:admin /home/admin/version_1 /home/admin/version_1/*.txt

CMD ["sleep", "infinity"]
