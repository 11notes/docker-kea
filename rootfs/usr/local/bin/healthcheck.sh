#!/bin/ash
  if [ -z "${1}" ]; then
    if [ ! -z ${KEA_BIN} ]; then
      case "${KEA_BIN}" in
        "ctrl")
          CURL_RESULT=$(curl -s -X POST -H 'Content-Type: application/json' -d '{"command": "status-get", "service": [ "dhcp4" ]}' localhost:6780) || exit 1
          echo "${CURL_RESULT}" | grep -q '"status": "ready"'
        ;;
        "dhcp4")
          netstat -uln | grep -q ":67"
        ;;
      esac
    else
      netstat -uln | grep -q ":67"
    fi
  fi