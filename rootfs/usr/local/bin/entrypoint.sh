#!/bin/ash
if [ -z "$1" ]; then
    kea-ctrl-agent -c /kea/etc/kea-ctrl-agent.conf &

    set -- "kea-dhcp4" \
        -c "/kea/etc/dhcp4.conf"

    exec "$@"
else
    exec "$@"
fi