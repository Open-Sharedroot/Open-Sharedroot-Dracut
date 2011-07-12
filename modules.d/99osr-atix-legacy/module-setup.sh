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
    echo "osr"
    return 0
}

# installkernel() {
# 
# }

install() {
    inst "$moddir/atix-logo.txt" /etc
}