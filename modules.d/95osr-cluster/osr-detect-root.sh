#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh
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

# only for debugging...
debug()
{
    value=$1
#     ifdebug="DEBUG"
    ifdebug="NO_DEBUG"
    if [ "$ifdebug" = "DEBUG" ]
    then
        echo "====================[osr-detect-root]================================="
        echo $value
        echo "======================================================================"
    fi
}

debug "Jump in..."

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
    die "[osr-detect-root]: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs ${libdir} 

#-------------------------------------------------------------------------------

netif=$1
debug  "check exist /tmp/osr.nonodeid_${netif} \n"
debug  `[ -f /tmp/osr.nonodeid_${netif}]` 
if [ -f /tmp/osr.nonodeid_${netif} ]; then
    debug  "[osr-detect-root]: Skipping."
elif repository_has_key "nodeid"; then
    debug  "Running......"
    . /tmp/root.info
    oldroot="$root"
    osr_set_nodeconfig_root $(repository_get_value nodeid)
    # only for debugging...
    debug "oldroot: $oldroot"

    # is this set not by bot-comand-params... 
    if [ -z "$oldroot" ] || [ "$oldroot" = "block:/dev/root" ]; then
        debug "fstype: ${fstype} root: ${root} netroot: $netroot"
        # Network root scripts may need updated root= options,
        # so deposit them where they can see them (udev purges the env)
        # rflags="rw"
        if [ "$rflags" = "ro" ]
          then
          rflags="rw"
          echo 'over write rflags with "rw"'
        fi

        {
            echo "root='$root'"
            echo "rflags='$rflags'"
            echo "fstype='$fstype'"
            echo "netroot='$netroot'"
            echo "NEWROOT='$NEWROOT'"
        } > /tmp/root.info
        # only for debugging...
        debug "value of /tmp/root.info...\n"
        debug `cat /tmp/root.info`

        . /tmp/root.info
        echo "\n"
        ( [ $fstype = "nfs" ] || [ $fstype = "nfs4" ] ) && echo > /dev/root
    fi
    # Recalling netroot!
    debug "Calling nfsroot with $netif $netroot$rflags $NEWROOT"
    /sbin/nfsroot $netif $netroot$rflags $NEWROOT
    if [ -d /initqueue-finished ];
        then
        debug " /initqueue-finished exist"
    else
        debug "create /initqueue-finished"
        mkdir /initqueue-finished
    fi
    echo '[ -e $NEWROOT/proc ]' > $hookdir/initqueue/finished/osrroot.sh
    info "[osr-detect-root]: Successfully called nfsroot."
    
    # only for debugging...
    debug "try Ping NFS with arping:"
    debug `/sbin/arping -c 1 192.168.1.99`
    debug "[osr-detect-root] ...if-end"

fi

debug  "jump-out.........."