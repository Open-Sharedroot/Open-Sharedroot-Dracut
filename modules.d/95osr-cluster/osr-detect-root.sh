#!/bin/sh
#
# Script to automatically detect the apropriate root and set the environment variables accordingly.
# This script should be called prior to mount but after the nodeid has been set.
# 
#   Configuration
#      <rootvolume fstype="somefstype" name="root" mountopts="options"/>
#   Examples for fstype:
#      * ext3/4 => name=/dev/..
#      * nfs[4] => name=[nfs[4]:][server:]path[:options]
#      * gfs[2] => name=/dev/..
#      * ocfs2  => name=/dev/..
#
if [ -n "$dracutlib" ] && [ -f $dracutlib ]; then
	. $dracutlib
elif [ -f /lib/dracut-lib.sh ]; then
  . /lib/dracut-lib.sh
fi

if getarg rdnetdebug ; then
    exec >/tmp/osr-detect-root.$1.$$.out
    exec 2>>/tmp/osr-detect-root.$1.$$.out
    set -x
fi

if [ -f std-lib.sh ]; then
	. ./std-lib.sh
	libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr-detect-root: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs ${libdir} 

#-------------------------------------------------------------------------------

netif=$1
if [ -f /tmp/osr.nonodeid_${netif} ]; then
    info "osr-detect-root: Skipping."
elif repository_has_key "nodeid"; then
    . /tmp/root.info
    oldroot="$root"
    osr_set_nodeconfig_root $(repository_get_value nodeid)
    if [ -z "$oldroot" ] || [ "$oldroot" = "autodetect" ]; then
        info "osr-detect-root: fstype: ${fstype} root: ${root} netroot: $netroot"
        # Network root scripts may need updated root= options,
        # so deposit them where they can see them (udev purges the env)
        {
            echo "root='$root'"
            echo "rflags='$rflags'"
            echo "fstype='$fstype'"
            echo "netroot='$netroot'"
            echo "NEWROOT='$NEWROOT'"
        } > /tmp/root.info
        ( [ $fstype = "nfs" ] || [ $fstype = "nfs4" ] ) && echo > /dev/root
    fi
else
    # Recalling netroot!
    info "osr-detect-root: Calling nfsroot with $netif $netroot $NEWROOT"
    /sbin/nfsroot $netif $netroot $NEWROOT
    echo '[ -e $NEWROOT/proc ]' > /initqueue-finished/nfsroot.sh
    info "osr-detect-root: Successfully called nfsroot."
fi