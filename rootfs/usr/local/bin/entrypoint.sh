#!/bin/ash
if [ -z "$1" ]; then
    KEA_CTRL_PID="/usr/local/var/run/kea/kea-ctrl-agent.kea-ctrl-agent.pid"
    if [ -f "${KEA_CTRL_PID}" ]; then
        rm -f ${KEA_CTRL_PID}
    fi

    kea-ctrl-agent -c /kea/etc/kea-ctrl-agent.conf &

    KEA_DHCP4_PID="/usr/local/var/run/kea/dhcp4.kea-dhcp4.pid"
    if [ -f "${KEA_DHCP4_PID}" ]; then
        rm -f ${KEA_DHCP4_PID}
    fi

    set -- "kea-dhcp4" \
        -c "/kea/etc/dhcp4.conf"

    exec "$@"
else
    exec "$@"
fi