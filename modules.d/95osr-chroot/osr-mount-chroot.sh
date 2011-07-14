#!/bin/sh
# This script builds the chroot needed to mount the chroot
if [ -n "$dracutlib" ] && [ -f $dracutlib ]; then
	. $dracutlib
elif [ -f /lib/dracut-lib.sh ]; then
  . /lib/dracut-lib.sh
fi

if getarg rdnetdebug ; then
    exec >/tmp/osr-mount-chroot.$1.$$.out
    exec 2>>/tmp/osr-mount-chroot.$1.$$.out
    set -x
fi

if [ -f std-lib.sh ]; then
	. ./std-lib.sh
	libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr-mount-chroot: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs ${libdir} 

echo "[osr-mount-chroot] : jump in..."

chrootneeded=$(repository_get_value chrootneeded)

if [ -n "$chrootneeded" ] && ( [ "$chrootneeded" -eq 0 ] || [ "$chrootneeded" = "__set__" ] ); then
  chrootenv_mountpoint=$(repository_get_value chrootenv_mountpoint)
  chrootenv_fstype=$(repository_get_value chrootenv_fstype)
  chrootenv_device=$(repository_get_value chrootenv_device)
  chrootenv_chrootdir=$(repository_get_value chrootenv_chrootdir)
  chrootenv_options=$(repository_get_value chrootenv_options)
  
  info "osr-mount-chroot: Mounting osr chroot environment"
  mount_chroot "$chrootenv_mountpoint" "$chrootenv_fstype" "$chrootenv_device" "$chrootenv_chrootdir" "$chrootenv_options"
  info "osr-mount-chroot: Preparing chroot" $(repository_get_value chrootenv_chrootdir)
  create_chroot "/" $(repository_get_value chrootenv_chrootdir)

else
  info "osr-mount-chroot: No chroot environment needed."
fi