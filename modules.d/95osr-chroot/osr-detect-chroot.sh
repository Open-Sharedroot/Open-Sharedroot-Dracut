#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh


# This script detects if a chroot is needed for this rootfilesystem.
# It can either be configured via the nodevalues file or the following bootparameters:
#   chrootneeded
#   chroot
if [ -n "$dracutlib" ] && [ -f $dracutlib ]; then
    . $dracutlib
elif [ -f /lib/dracut-lib.sh ]; then
  . /lib/dracut-lib.sh
fi

if [ -f std-lib.sh ]; then
    . ./std-lib.sh
    libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr-detect-chroot: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs ${libdir} 

if repository_has_key "nodeid"; then
    nodeid=$(repository_get_value "nodeid")

    . /etc/conf.d/osr-nodeidvalues-${nodeid}.conf

    rootfs_chroot_needed initrd
    osr_param_store chrootneeded $?
  
    for param in mountpoint fstype device chrootdir options; do
        eval "value=\$chrootenv_$param"
        osr_param_store chrootenv_$param $value
    done
else
      die "osr-detect-chroot: nodeid neither detected nor setup as bootparameter. Cannot continue."
fi