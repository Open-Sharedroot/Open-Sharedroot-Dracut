#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# Generates the udev rules needed to detect the nodeid. 
# Will only be setup if the nodeid was not detected before.

if [ ! -f /tmp/osr.nodeid ]
then
    # Will be done on any interface. And only if /tmp/osr.nodeid does not exist prior
    printf 'ACTION=="add", SUBSYSTEM=="net", RUN+="/sbin/osr-detect-nodeid $env{INTERFACE}"\n'  > /etc/udev/rules.d/50-osr.rules
fi
# Will be done on any interface. And only if /tmp/osr.nodeid does not exist prior
printf 'ACTION=="add", SUBSYSTEM=="net", RUN+="/sbin/osr-set-nodeconfig-net $env{INTERFACE}"\n'  >  /etc/udev/rules.d/51-osr.rules 
printf 'ACTION=="online", SUBSYSTEM=="net", RUN+="/sbin/osr-detect-syslog $env{INTERFACE}"\n'  >>  /etc/udev/rules.d/51-osr.rules
printf 'ACTION=="online", SUBSYSTEM=="net", RUN+="/sbin/osr-detect-root $env{INTERFACE}"\n'  >>  /etc/udev/rules.d/51-osr.rules
