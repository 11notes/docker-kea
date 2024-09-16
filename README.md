![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - kea
![size](https://img.shields.io/docker/image-size/11notes/kea/2.6.1?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/kea/2.6.1?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/kea?color=2b75d6) ![stars](https://img.shields.io/docker/stars/11notes/kea?color=e6a50e) [<img src="https://img.shields.io/badge/github-11notes-blue?logo=github">](https://github.com/11notes)

**Kea compiled from source with PostgreSQL and MariaDB support**

# SYNOPSIS
What can I do with this? Run Kea DHCP rootless with your favourite lease backends compiled from source and statically linked to create a small container image. All the benefits of Kea, none of the clutter from public repos 😉.

# VOLUMES
* **/kea/etc** - Directory of configuration files
* **/kea/var** - Directory of DHCP leases

# COMPOSE
```yaml
version: "3.8"
services:
  dhcp:
    image: "11notes/kea:2.6.1"
    container_name: "kea.dhcp"
    environment:
      TZ: Europe/Zurich
    volumes:
      - "kea-run:/kea/run"
      - "kea-etc:/kea/etc"
    networks:
      dhcp:
        ipv4_address: 192.168.100.67
    restart: always
  ctrl:
    image: "11notes/kea:2.6.1"
    container_name: "kea.ctrl"
    command: ctrl
    environment:
      TZ: Europe/Zurich
    volumes:
      - "kea-run:/kea/run"
    ports:
      - "6780:6780/tcp"
    restart: always
volumes:
  kea-etc:
  kea-run:
networks:
  dhcp:
    driver: macvlan
    driver_opts:
      parent: eth0.100
    ipam:
      config:
        - subnet: 192.168.100.0/24
```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /kea | home directory of user docker |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [kea](https://gitlab.isc.org/isc-projects/kea.git)
* [alpine](https://alpinelinux.org)

# TIPS
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes. You can find all my repositories on [github](https://github.com/11notes).
    