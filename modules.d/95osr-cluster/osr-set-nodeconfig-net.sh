#!/bin/sh
if [ -n "$dracutlib" ] && [ -f $dracutlib ]; then
	. $dracutlib
elif [ -f /lib/dracut-lib.sh ]; then
  . /lib/dracut-lib.sh
fi

if getarg rdnetdebug ; then
    exec >/tmp/$(basename $0).$1.$$.out
    exec 2>>/tmp/$(basename $0).$1.$$.out
    set -x
fi

if [ -f std-lib.sh ]; then
	. ./std-lib.sh
	libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr-set-nodeconfig-net: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs ${libdir} 

# Sets up the node configuration setup from a pregenerated nodeconfiguration at initrd build time
# It requires a preset nodeid (/tmp/osr.nodeid)

netif=$1
if [ -f /tmp/osr.nonodeid_${netif} ]; then
    info $(basename $0)": Skipping <$netif>."
elif repository_has_key "nodeid"; then
	nodeid=$(repository_get_value "nodeid")
	if [ -f "/etc/conf.d/osr-nodeidvalues-${nodeid}.conf" ]; then
		ipstr=$(osr_set_nodeconfig_net $nodeid)
		echo -n "ip=$ipstr" >> /etc/cmdline
		info $(basename $0)": nodedeconfig-net ipstr: $ipstr" 
	else
		info $(basename $0)": Could not find nodeconfiguration for nodeid $nodeid. Continuing without."
	fi
else
	die $(basename $0)": nodeid neither detected nor setup as bootparameter. Cannot continue."
fi
	