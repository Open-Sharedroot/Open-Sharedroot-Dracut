#!/bin/dash
# This script builds the chroot needed to mount the chroot
if [ -n "$dracutlib" ] && [ -f $dracutlib ]; then
	. $dracutlib
elif [ -f /lib/dracut-lib.sh ]; then
  . /lib/dracut-lib.sh
fi

if getarg rdnetdebug ; then
    exec >/tmp/osr-move-chroot.$1.$$.out
    exec 2>>/tmp/osr-move-chroot.$1.$$.out
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

. /tmp/root.info

chrootneeded=$(repository_get_value chrootneeded)

if [ -n "$chrootneeded" ] && ( [ "$chrootneeded" -eq 0 ] || [ "$chrootneeded" = "__set__" ] ); then
  olddir=$(repository_get_value chrootenv_mountpoint)
  newdir=$NEWROOT
  info "osr-move-chroot: Moving chroot $olddir=>$newdir" 
  move_chroot $olddir $newdir/$olddir
fi