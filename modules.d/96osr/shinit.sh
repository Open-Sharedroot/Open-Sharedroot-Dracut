#!/bin/sh
#
# $Id: shinit.sh,v 1.2 2009-08-13 10:00:41 marc Exp $
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
set +x
export PS1="osr \! > " TERM=xterm

if [ -f ${libdir-.}/std-lib.sh ]; then
	libdir=${libdir-.}
	. ${libdir}/std-lib.sh
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
fi
#source  ${predir}/etc/hardware-lib.sh

# Load USB Modules so that USB keyboards work in Expertshell
#echo_local -n "Loading USB Modules.."
#usbLoad

sourceLibs ${libdir}
if repository_has_key rootfs; then
  sourceRootfsLibs ${libdir}
fi

logo=$(repository_get_value logofile)
shellissue=$(repository_get_value shellissue)
shellissuetmp=$(repository_get_value shellissuetmp)

setparameter() {
   repository_store_value $*
}
getparameter() {
   repository_get_value $*
}
delparameter() {
	repository_del_value $*
}
listparameters() {
   repository_list_items "="
}
drawline() {
	echo
	echo "-------------------------------------------------------------"
	echo
}
help() {
	local shellissue=$(repository_get_value shellissue)
    if [ -n "$shellissue" ] && [ -f "$shellissue" ]; then	
	  cat $shellissue >/dev/console
    fi
}
lastmessage() {
	local shellissuetmp=$(repository_get_value shellissuetmp)
    if [ -n "$shellissuetmp" ] && [ -f "$shellissuetmp" ]; then	
	  cat $shellissuetmp >/dev/console
    fi
}
messages() {
	if [ -n "$bootlog" ] && [ -f "$bootlog" ]; then
	  cat $bootlog
	fi
}
	
drawline
if [ -f "$logo" ]; then
  cat $logo
  drawline
fi
if [ -f "$shellissue" ]; then
  cat $shellissue
  drawline
fi
if [ -f "$shellissuetmp" ]; then
  cat $shellissuetmp
  drawline
fi

unset logo
unset shellissue
unset shellissuetmp
