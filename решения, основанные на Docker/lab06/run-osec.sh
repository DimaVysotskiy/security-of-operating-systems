#!/bin/bash
set -euo pipefail
export LC_ALL=C

report=/var/log/osec.log
exec 9>/run/lab06-osec.lock
if ! flock -n 9; then
    printf '%s\n' 'An integrity check is already running' >&2
    exit 1
fi

draft=$(mktemp /var/log/.osec.XXXXXX)
trap 'rm -f -- "$draft"' EXIT
printf '[%s]\n' "$(date -Is)" > "$draft"
runuser -u osec -- osec -t sha256 -D /var/lib/lab06-osec -f /etc/lab06/dirs.conf | osec_reporter >> "$draft"

for ((index = 5; index > 1; index--)); do
    if [[ -f "$report.$((index - 1))" ]]; then
        mv -f -- "$report.$((index - 1))" "$report.$index"
    fi
done
if [[ -f "$report" ]]; then
    mv -f -- "$report" "$report.1"
fi
mv -f -- "$draft" "$report"
cat -- "$report"
