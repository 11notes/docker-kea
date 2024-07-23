#!/bin/ash
  if [ -z "${1}" ]; then
    elevenLogJSON info "starting kea dhcp4 server"
    set -- "/opt/kea/sbin/kea-dhcp4" \
      -c "/kea/etc/dhcp4.conf"
  else
    case "${1}" in
      "ctrl")
        elevenLogJSON info "starting kea control agent"
          set -- "/opt/kea/sbin/kea-ctrl-agent" \
            -c "/kea/etc/ctrl-agent.conf"
      ;;
    esac
  fi
    
  exec "$@"