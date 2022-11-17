#!/bin/ash
CURL_RESULT=$(curl -s -X POST -H 'Content-Type: application/json' -d '{"command": "status-get", "service": [ "dhcp4" ]}' ${KEA_IP}:6780) || exit 1
if echo "${CURL_RESULT}" | grep -q '"status": "ready"'; then
    exit 0;
else
    exit 2;
fi