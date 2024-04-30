#!/bin/bash

function make_fhs_layout() {
    local destdir="${1}"
    local fhs=(/bin /boot /dev /etc /lib /media /mnt /opt /proc /root /run /sbin /srv /sys /tmp \
        /usr/bin /usr/include /usr/lib /usr/local /usr/sbin /usr/share \
        /var/cache /var/lib /var/lock /var/log /var/opt /var/run /var/spool /var/tmp)

    for d in ${fhs[@]}; do
        mkdir -p ${destdir}${d}
    done
}

make_fhs_layout ${@}
