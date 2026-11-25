#!/bin/bash
set -euo pipefail

case "${1:-}" in
    before) snapshot_dir=/home/admin/version_1 ;;
    after) snapshot_dir=/home/admin/version_2 ;;
    *)
        printf 'Usage: %s {before|after}\n' "${0##*/}" >&2
        exit 2
        ;;
esac

install -d -m 0755 "$snapshot_dir"
cat /etc/os-release > "$snapshot_dir/os-release.txt"
uname -a > "$snapshot_dir/kernel.txt"
apt-repo > "$snapshot_dir/repositories.txt"
rpm -qa --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' | LC_ALL=C sort > "$snapshot_dir/packages.txt"
printf '%s\n' "$snapshot_dir"
