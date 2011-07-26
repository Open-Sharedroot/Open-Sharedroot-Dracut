#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    # we require nfs
    # What if we either require nfs|ocfs2|gfs|glusterfs|ext3 ???
#     [ "$1" = "-d" ] && echo osr
    return 0
}

depends() {
    echo osr
    return 0
}

# installkernel() {
# 
# }

install() {

    if [ -f "$moddir"/lib/cluster-lib.sh ]; then
      . "$moddir"/lib/cluster-lib.sh
    else
      dwarning "osr-cluster: Cannot load cluster library. OSR-Cluster functionality will be reduced."
    fi


    [ -z "$osr_querymap" ] && osr_querymap=/etc/osr/query-map.cfg

    echo > /tmp/osr-nodeids
    for nodeid in `com-queryclusterconf nodeids`; do
        echo "$nodeid "`com-queryclusterconf -m $osr_querymap macs $nodeid` >> /tmp/osr-nodeids
        osr_generate_nodevalues $nodeid $osr_querymap > /tmp/osr-nodeidvalues-${nodeid}.conf
        inst_simple /tmp/osr-nodeidvalues-${nodeid}.conf /etc/conf.d/osr-nodeidvalues-${nodeid}.conf

        echo '--------------------------------------------------------------------\n'
        echo '...this value is set: \n'
        echo '/tmp/osr-nodeids \n'
        cat /tmp/osr-nodeids
        echo '\n /tmp/osr-nodeidvalues-${nodeid}.conf'
        cat /tmp/osr-nodeidvalues-${nodeid}.conf
        echo '\n'
        echo '--------------------------------------------------------------------\n'
    done

    dracut_install tr
    dracut_install expr
    dracut_install mkdir
    dracut_install basename
    dracut_install bash

    inst "$moddir/lib/cluster-lib.sh" /lib/osr/

    inst_simple /tmp/osr-nodeids
    inst_simple /tmp/osr-nodeidvalues-${nodeid}.conf /etc/conf.d/osr-nodeidvalues-${nodeid}.conf

    # Next the nodeid detection should be done as it can influence every other setting following afterwards.
    inst_simple "$moddir/osr-detect-nodeid.sh" "/sbin/osr-detect-nodeid"
    inst_simple "$moddir/osr-set-nodeconfig-net.sh" "/sbin/osr-set-nodeconfig-net"
    # ugly...
    inst_simple "$moddir/osr-detect-root.sh" "/sbin/osr-detect-root"
#    inst_simple "$moddir/osr-detect-root.sh" "/sbin/osrroot"
    inst_simple "$moddir/osr-detect-syslog.sh" "/sbin/osr-detect-syslog"

    inst_hook pre-udev 59 "$moddir/osr-net-genrules.sh"
#    inst_hook netroot  11 "$moddir/osr-detect-chroot.sh"
#    inst_hook netroot  50 "$moddir/osr-mount-chroot.sh"

    # Us
    # dracut -f -a "network nfs base osr osr-cluster" /boot/initrd_sr-$(uname -r).img $(uname -r)

}