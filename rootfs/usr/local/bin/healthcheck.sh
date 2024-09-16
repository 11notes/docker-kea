#!/bin/ash
  if [ -z "${1}" ]; then
    if [ -f "${APP_ROOT}/run/dhcp4.sock" ]; then
      exit 0;
    else
      exit 1;
    fi
  else
    case "${1}" in
      "ctrl")
        CURL_RESULT=$(curl -s -X POST -H 'Content-Type: application/json' -d '{"command": "status-get", "service": [ "dhcp4" ]}' localhost:6780) || exit 1
        if echo "${CURL_RESULT}" | grep -q '"status": "ready"'; then
          exit 0;
        else
          exit 1;
        fi
      ;;
    esac
  fi