#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    # we require nfs
    # What if we either require nfs|ocfs2|gfs|glusterfs|ext3 ???
#     [ "$1" = "-d" ] && echo "osr"
    return 0
}

depends() {
    # We depend on network modules being loaded
    echo network osr
    return 0
}

# installkernel() {
#     instmods nfs sunrpc ipv6
# }

install() {

#     . $dracutfunctions

    inst_simple "$moddir/lib/chroot-lib.sh" /lib/osr/

    # What do we need for mounting the chroot
    inst_hook pre-mount    11 "$moddir/osr-detect-chroot.sh"
#     inst_hook pre-pivot    50 "$moddir/osr-mount-chroot.sh"
    inst_hook pre-pivot    12 "$moddir/osr-mount-chroot.sh"
    inst_hook pre-pivot  51 "$moddir/osr-move-chroot.sh"
}