#
# $Id: rootfs-lib.sh,v 1.1 2009-08-13 09:25:46 marc Exp $
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

#****f* rootfs-lib.sh/rootfs_chroot_needed
#  NAME
#    rootfs_chroot_needed
#  SYNOPSIS
#    rootfs_chroot_needed "initrd"*|"init"
#  IDEAS
#    Should just cascade to ${rootfs_chroot_needed} $* and return 1 to indicate that
#    by a chroot is only needed in special environments. Defaults to not 0
rootfs_chroot_needed() {
  local rootfs=$fstype
  ${rootfs}_chroot_needed $* >/dev/null
  return $?
}
#***** rootfs_chroot_needed

#****f* rootfs-lib.sh/rootfs_get_userspace_procs
#  NAME
#    rootfs_get_userspace_procs
#  SYNOPSIS
#    function rootfs_get_userspace_procs(cluster_conf, nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
rootfs_get_userspace_procs() {
  local rootfs=$1
  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)

  ${rootfs}_get_userspace_procs 2>/dev/null
}
#******** rootfs_get_userspace_procs
