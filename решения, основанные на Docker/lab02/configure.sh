#!/bin/bash
set -euo pipefail

policy_dir=/usr/local/share/lab02

if [[ -f /etc/pam.d/system-auth-local-only && ! -e /etc/pam.d/system-auth-local-only.original ]]; then
    cp -p /etc/pam.d/system-auth-local-only /etc/pam.d/system-auth-local-only.original
fi

install -D -m 0644 "$policy_dir/passwdqc.conf" /etc/passwdqc.conf
install -D -m 0644 "$policy_dir/faillock.conf" /etc/security/faillock.conf
install -D -m 0644 "$policy_dir/system-auth-local-only" /etc/pam.d/system-auth-local-only
install -D -m 0644 "$policy_dir/login.pam" /etc/pam.d/login
install -D -m 0644 "$policy_dir/passwd.pam" /etc/pam.d/passwd
install -D -m 0755 "$policy_dir/clear-failures.sh" /usr/local/sbin/lab02-clear-failures
install -d -m 0755 /var/run/faillock

login_defaults=$(mktemp)
trap 'rm -f "$login_defaults"' EXIT
awk '
    $1 !~ /^(PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE|USERDEL_CMD|USERGROUPS_ENAB)$/ { print }
    END {
        print "PASS_MAX_DAYS 91"
        print "PASS_MIN_DAYS 0"
        print "PASS_WARN_AGE 10"
        print "USERDEL_CMD /usr/local/sbin/lab02-clear-failures"
        print "USERGROUPS_ENAB yes"
    }
' /etc/login.defs > "$login_defaults"
cat "$login_defaults" > /etc/login.defs

if ! grep -q '^users:' /etc/group; then
    groupadd users
fi
