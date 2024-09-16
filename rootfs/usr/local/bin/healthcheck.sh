#!/bin/ash
  if [ -z "${1}" ]; then
    netstat -uln | grep -q "67"
  else
    case "${1}" in
      "ctrl")
        CURL_RESULT=$(curl -s -X POST -H 'Content-Type: application/json' -d '{"command": "status-get", "service": [ "dhcp4" ]}' localhost:6780) || exit 1
        echo "${CURL_RESULT}" | grep -q '"status": "ready"'
      ;;
    esac
  fi