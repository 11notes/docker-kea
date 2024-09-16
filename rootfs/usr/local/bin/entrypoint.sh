#!/bin/ash
  if [ -z "${1}" ]; then
    if [ ! -z ${KEA_BIN} ]; then
      case "${KEA_BIN}" in
        "ctrl")
          elevenLogJSON info "starting kea control agent"
            set -- "/opt/kea/sbin/kea-ctrl-agent" \
              -c "/kea/etc/ctrl-agent.conf"
        ;;
        "dhcp4")
          elevenLogJSON info "starting kea dhcp4 server"
          set -- "/opt/kea/sbin/kea-dhcp4" \
            -c "/kea/etc/dhcp4.conf"
        ;;
      esac
    else
      elevenLogJSON info "starting kea dhcp4 server"
      set -- "/opt/kea/sbin/kea-dhcp4" \
        -c "/kea/etc/dhcp4.conf"
    fi
  fi
    
  exec "$@"