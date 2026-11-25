#!/bin/bash
set -e

# Задание 3.1. Сложность паролей.
install -D -m 0644 /usr/local/share/lab02/passwdqc.conf /etc/passwdqc.conf

# Задание 3.2. Срок действия паролей и очистка счётчика при удалении учётки.
install -D -m 0755 /usr/local/share/lab02/clear-failures.sh /usr/local/sbin/lab02-clear-failures
install -D -m 0640 /usr/local/share/lab02/login.defs /etc/login.defs

# Задание 3.3. Ограничение числа неудачных входов.
install -D -m 0644 /usr/local/share/lab02/faillock.conf /etc/security/faillock.conf
install -d -m 0755 /var/run/faillock

# Задание 3.4. Сохраняем исходный стек PAM и подключаем учебную конфигурацию.
if [[ -f /etc/pam.d/system-auth-local-only && ! -e /etc/pam.d/system-auth-local-only.original ]]; then
    cp -p /etc/pam.d/system-auth-local-only /etc/pam.d/system-auth-local-only.original
fi

install -D -m 0644 /usr/local/share/lab02/system-auth-local-only /etc/pam.d/system-auth-local-only
install -D -m 0644 /usr/local/share/lab02/login.pam /etc/pam.d/login
install -D -m 0644 /usr/local/share/lab02/passwd.pam /etc/pam.d/passwd

# Задание 3.5. Дополнительная группа для учебных пользователей.
if ! grep -q '^users:' /etc/group; then
    groupadd users
fi
