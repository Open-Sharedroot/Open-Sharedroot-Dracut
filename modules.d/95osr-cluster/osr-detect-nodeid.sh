#!/bin/sh
#
# Format:
#	nodeid=<nodeid>
# If nodeid is given take it or implicitly get it from initrd (see setup-cmdline.sh)
#
. /lib/dracut-lib.sh

if getarg rdnetdebug ; then
    exec >/tmp/osr-detect-nodeid.$1.$$.out
    exec 2>>/tmp/osr-detect-nodeid.$1.$$.out
    set -x
fi
if [ -f std-lib.sh ]; then
    . ./std-lib.sh
    libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr-detect-nodeid: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs $libdir

netif=$1

if ! repository_has_value "nodeid" ; then
    if [ ! -f "/tmp/osr-nodeids" ]; then
        die $(basename $0)": Could find nodeid repository /tmp/osr-nodeids. \
        To auto detect the nodeid this is required!! \
        Either specify nodeid as bootparameter or create a \
        valid /tmp/osr-nodeids file."
    fi

    # from the mac address we'll get the nodeid
    # TODO: make it more general later. Means there is a hardware id and the nodeid will be detected from it!
    nodeid=""
    hwaddr=$(cat /sys/class/net/$netif/address | tr '[:upper:]' '[:lower:]')
    while read nodeid2 hwaddr2s; do
        for hwaddr2 in $hwaddr2s; do
            hwaddr2=$(echo $hwaddr2 | tr '[:upper:]' '[:lower:]')
            if [ -n "$hwaddr2" ] && [ -n "$nodeid2" ] && [ $hwaddr = $hwaddr2 ]; then
                echo "[osr-detect-nodeid]"  hwaddr: $hwaddr \n
                echo vs ... \n
                echo "[osr-detect-nodeid]" hwaddr2: $hwaddr2 \n
                nodeid=$nodeid2
                info $(basename $0)": nodeid $nodeid detected for nic $netif"
            fi
        done
    done < /tmp/osr-nodeids
    # debug info...
    echo "[osr-detect-nodeid] /sys/class/net/\$netif/address:" \n
    echo "[osr-detect-nodeid]"
    cat /sys/class/net/$netif/address \n
    
    if [ -z "$nodeid" ]; then
        info $(basename $0)": Could not detect the nodeid for this interface $netif."
        echo > /tmp/osr.nonodeid_${netif}
    else
        info $(basename $0)": Detected nodeid $nodeid"
        repository_store_value "nodeid" $nodeid
    fi
fi
