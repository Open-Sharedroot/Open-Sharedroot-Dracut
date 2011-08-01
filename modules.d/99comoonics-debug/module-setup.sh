#!/bin/bash
# This module is only for debugging.

check() {

    # this module is not  included by default
#    return 1

    # this module is included by default
    return 0       
}

depends() {
    return 0
}

# installkernel() {
#     instmods nfs sunrpc ipv6
# }

install() {

    inst_hook cmdline     50 "$moddir/handler-cmdline.sh"
    inst_hook pre-udev    50 "$moddir/handler-pre-udev.sh"
    inst_hook pre-trigger 50 "$moddir/handler-pre-trigger.sh"
    inst_hook pre-mount   50 "$moddir/handler-pre-mount.sh"
    inst_hook mount       50 "$moddir/handler-mount.sh"
    inst_hook pre-piv     50 "$moddir/handler-pre-pivot.sh"
    
}