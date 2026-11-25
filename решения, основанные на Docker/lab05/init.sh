#!/bin/bash
set -euo pipefail

state_dir=/var/lib/lab05
if [[ ! -f "$state_dir/initialized" ]]; then
    setfacl -m u:root:rwx,g:root:rwx,o::r-x /home/work/tasks
    mkdir -p "$state_dir"
    touch "$state_dir/initialized"
fi

exec "$@"
