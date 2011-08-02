#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# This skript fills in the xfiles for being used by other programs that might be using those information

if [ -n "$dracutlib" ] && [ -f $dracutlib ]; then
	. $dracutlib
elif [ -f /lib/dracut-lib.sh ]; then
  . /lib/dracut-lib.sh
fi

# check debugging-mode
if getarg rdnetdebug ; then
    exec >/tmp/osr-write-xfiles.$1.$$.out
    exec 2>>/tmp/osr-write-xfiles.$1.$$.out
    set -x
fi

if [ -f std-lib.sh ]; then
    . ./std-lib.sh
    libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr-move-chroot: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs ${libdir}
sourceRootfsLibs ${libdir}

[ -f /tmp/root.info ] && . /tmp/root.info

echo_local "osr-write-xfiles: Writing xtab.. "
create_xtab "${NEWROOT}/$(repository_get_value xtabfile)" "$(repository_get_value cdsllink)" "$(repository_get_value chrootenv_mountpoint )"

echo_local "osr-write-xfiles: Writing xrootfs.. "
create_xrootfs ${NEWROOT}/$(repository_get_value xrootfsfile) $(repository_get_value rootfs)

echo_local "osr-write-xfiles: Writing xkillall_procs.. "
create_xkillall_procs "${NEWROOT}/$(repository_get_value xkillallprocsfile)" "" "$(repository_get_value rootfs)"
step "Created xtab,xrootfs,xkillall_procs file" "xfiles"
	 
