#
# $Id: chroot-lib.sh,v 1.1 2009-08-13 09:25:45 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH, 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#****f* boot-lib.sh/build_chroot
#  NAME
#    move chroot environment
#  SYNOPSIS
#    function build_chroot(clusterconf, nodename) {
#  MODIFICATION HISTORY
#  USAGE
#
#  IDEAS
#
#  SOURCE
#
mount_chroot () {
    local chroot_fstype=$1
    local chroot_dev=$2
    local chroot_mount=$3
    local chroot_path=$4
    local chroot_options=$5

    info "osr_mount_chroot: Creating chroot environment"
    mkdir -p $chroot_mount
    mount -t $chroot_fstype -o $chroot_options $chroot_dev $chroot_mount

    [ -n "$chroot_mount" ] && mount | grep "$chroot_mount" >/dev/null 2>/dev/null
    # method3 fallback to tmpfs
    if [ $? -ne 0 ]; then
        info "osr_mount_chroot: Mounting chroot failed. Using default values"
        #Fallback values
        # Filesystem type for the chroot device
        chroot_fstype="tmpfs"
        # chroot device name
        chroot_dev="none"
        # Mountpoint for the chroot device
        chroot_mount=$DFLT_CHROOT_MOUNT
        # Path where the chroot environment should be build
        chroot_path=$DFLT_CHROOT_PATH
        # Mount options for the chroot device
        chroot_options="defaults"
        mkdir -p $chroot_mount
        mount -t $chroot_fstype -o $chroot_options $chroot_dev $chroot_mount
        echo $chroot_fstype > /tmp/osr.chrootenv_fstype
        echo $chroot_dev > /tmp/osr.chrootenv_device
        echo $chroot_mount > /tmp/osr.chrootenv_mountpoint
        echo $chroot_path > /tmp/osr.chrootenv_chrootdir
        echo $chroot_options > /tmp/osr.chrootenv_options
    fi
}
#************** build_chroot
#****f* boot-lib.sh/create_chroot
#  NAME
#    create_chroot build a chroot environment
#  SYNOPSIS
#    function create_chroot($chroot_source $chroot_path) {
#  MODIFICATION HISTORY
#  USAGE
#  create_chroot
#  IDEAS
#
#  SOURCE
#
create_chroot() {
  local chroot_source=$1
  local chroot_path=$2

  cp -axf $chroot_source $chroot_path
  rm -rf $chroot_path/var/run/*
  mkdir -p $chroot_path/tmp
  chmod 755 $chroot_path
#  exec_local mount --bind /dev $chroot_path/dev
  mount -t tmpfs none $chroot_path/dev
  cp -a /dev $chroot_path/
  mount -t devpts none $chroot_path/dev/pts
  mount -t proc proc $chroot_path/proc
  mount -t sysfs sysfs $chroot_path/sys
}
#************ create_chroot

#****f* boot-lib.sh/move_chroot
#  NAME
#    move chroot environment
#  SYNOPSIS
#    function move_chroot(chroot_path, new_chroot_path) {
#  MODIFICATION HISTORY
#  USAGE
#
#  IDEAS
#
#  SOURCE
#
move_chroot() {
  local chroot_mount=$1
  local new_chroot_mount=$2

  exec_local chroot $new_dir mkdir -p $new_chroot_mount
  exec_local mount --move $chroot_mount $new_chroot_mount
}
#************ move_chroot


######################
# $Log: chroot-lib.sh,v $
# Revision 1.1  2009-08-13 09:25:45  marc
# initial revision
#
