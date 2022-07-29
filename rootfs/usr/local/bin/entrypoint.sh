#!/bin/ash
if [ -z "$1" ]; then
    set -- "kea-dhcp4" \
        -c "/kea/etc/dhcp4.conf"

    exec "$@"
else
    exec "$@"
fi