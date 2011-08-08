#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    # If hostonly was requested, fail the check if we are not actually
    # booting from root.
    [ "$1" = "-h" ] && ! egrep -q '/ nfs[34 ]' /proc/mounts && exit 1
    return 0
}

depends() {
    return 0
}

# installkernel() {
# 
# }

install() {
    # Install all libraries we need
    for osrlib \
        in \
            boot-lib.sh \
            defaults.sh \
            repository-lib.sh \
            rootfs-lib.sh \
            shinit.sh \
            std-lib.sh; \
        do
      dinfo "Installing $moddir/lib/$osrlib => /lib/osr"
      mkdir  -p ${initdir}/lib/osr
      inst_simple "$moddir/lib/$osrlib" /lib/osr/$osrlib
    done


    inst_simple "$moddir/issue" /etc
    #inst_simple "$moddir/shinit.sh" /sbin

    # We should not need this because as of version 0.7 we only need to write to /etc/cmdline in order to
    # influence those persistent or somewhere else the /proc/cmdline parameters.
    # This should go first as it might overwrite some cmdline options
#     inst_hook cmdline  1  "$moddir/setup-osrenv.sh"
    
    inst_hook cmdline  1  "$moddir/hook-setup-osrenv.sh"


    
    # Next the nodeid detection should be done as it can influence every other setting following afterwards.
    inst_hook cmdline  2  "$moddir/parse-nodeid.sh"

    # Put this at the end as it is not depedent on anything
    inst_hook cmdline 99  "$moddir/parse-cdsl.sh"

    # Shouldn't it go into the mount hook but after root mount? Root mount is already number 99 ;-(.
    # So I'll put it in pre-pivot as first thing to do.
#     inst_hook pre-pivot 1 "$moddir/mount-cdsl.sh"
    inst_hook pre-pivot 60 "$moddir/mount-cdsl.sh"

    inst_hook pre-pivot 90 "$moddir/write-xfiles.sh"

    #inst_hook emergency 1 "$moddir/emergencyenv.sh"

    dracut_install cut
    dracut_install tr
    dracut_install expr
    dracut_install mkdir
    dracut_install basename
    dracut_install awk

    # AWK-Test ###############################################################

    # like gawk but do @include processing
    inst_simple "/usr/bin/igawk" /usr/bin
    inst_simple "$moddir/lib/setup-osrenv.awk" /lib/osr/setup-osrenv.awk
    # AWK-Hook-Wrapper
    inst_hook cmdline  1  "$moddir/hook-setup-osrenv.sh"
    
}