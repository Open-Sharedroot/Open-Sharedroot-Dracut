#!/bin/sh

#
# Mounts the cdsl infrastructure as a bindmount
# All parameters are read from /tmp/osr.nodeid, /tmp/osr.cdsltree, /tmp/osr.cdsllink and mapped to:
# mount --bind $cdsltree/$nodeid $cdsllink

. /lib/dracut-lib.sh

if getarg rdnetdebug ; then
    exec >/tmp/osr-mount-cdsl.$1.$$.out
    exec 2>>/tmp/osr-mount-cdsl.$1.$$.out
    set -x
fi

if [ -f std-lib.sh ]; then
	. ./std-lib.sh
	libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs $libdir

for file in /tmp/osr.nodeid /tmp/root.info; do
   if ! [ -f $file ]; then
      die "osr: Cannot find parameter file $file. This parameter is required and not set."
   fi
done

. /tmp/root.info

if [ "$fstype" = "nfs" ]; then
	echo $(repository_get_value cdslsharedtree)"/var/lib/nfs/rpc_pipefs" > /tmp/nfs.rpc_pipefs_path
fi 

info "osr: Mapping $NEWROOT/"$(repository_get_value cdsltree)"/"$(repository_get_value nodeid)" => $NEWROOT/"$(repository_get_value cdsllink)
mount --bind $NEWROOT/$(repository_get_value cdsltree)/$(repository_get_value nodeid) $NEWROOT/$(repository_get_value cdsllink)
#exit $?