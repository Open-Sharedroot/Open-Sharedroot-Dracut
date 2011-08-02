#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

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
osr_param_store() {
	key=$1
	var=$(getarg $key 2>/dev/null) && repository_store_value $key $var
	if [ $? -ne 0 ] && [ -n "$2" ]; then
		repository_store_value "$key" "$2"
	fi
}
#****f* boot-lib.sh/sourceLibs
#  NAME
#    sourceLibs
#  SYNOPSIS
#    function sourceLibs(predir) {
#  DESCRIPTION
#    Sources the libraries needed. Sets up clutype and distribution in repository.
#  IDEAS
#  SOURCE
#
sourceLibs() {
	if [ -n "$OSR_LIBSSOURCED" ] && [ $OSR_LIBSSOURCED -eq 1 ]; then
		return 0
	fi
	local libdir=$1

	OSR_LIBSSOURCED=1

    . ${libdir}/repository-lib.sh
    #. ${libdir}/errors.sh
    . ${libdir}/boot-lib.sh
    #. ${libdir}/hardware-lib.sh
    #. ${libdir}/network-lib.sh
    . ${libdir}/rootfs-lib.sh
    #. ${libdir}/stdfs-lib.sh
    . ${libdir}/defaults.sh
    [ -e ${libdir}/cluster-lib.sh ] && . ${libdir}/cluster-lib.sh
    [ -e ${libdir}/chroot-lib.sh ] && . ${libdir}/chroot-lib.sh
    #. ${libdir}/xen-lib.sh
    #[ -e ${libdir}/iscsi-lib.sh ] && source ${libdir}/iscsi-lib.sh
    #[ -e ${libdir}/drbd-lib.sh ] && source ${libdir}/drbd-lib.sh

    #local clutype=$(getCluType)
    #[ -e ${libdir}/${clutype}-lib.sh ] && . ${libdir}/${clutype}-lib.sh

    # including all distribution dependent files
    local distribution=$(getDistribution)
    local temp
    temp=$(getDistributionList)
    local shortdistribution=$(echo "$temp" | cut -f1 -d" ")

    for _distribution in $shortdistribution $distribution; do
      [ -e ${libdir}/${_distribution}/boot-lib.sh ] && source ${libdir}/${_distribution}/boot-lib.sh
      #[ -e ${libdir}/${_distribution}/hardware-lib.sh ] && source ${libdir}/${_distribution}/hardware-lib.sh
      #[ -e ${libdir}/${_distribution}/network-lib.sh ] && source ${libdir}/${_distribution}/network-lib.sh
      [ -e ${libdir}/${_distribution}/cluster-lib.sh ] && source ${libdir}/${_distribution}/clusterfs-lib.sh
      [ -e ${libdir}/${_distribution}/rootfs-lib.sh ] && source ${libdir}/${_distribution}/clusterfs-lib.sh
      #[ -e ${libdir}/${_distribution}/${clutype}-lib.sh ] && source ${libdir}/${_distribution}/${clutype}-lib.sh
      #[ -e ${libdir}/${_distribution}/xen-lib.sh ] && source ${libdir}/${_distribution}/xen-lib.sh
      #[ -e ${libdir}/${_distribution}/iscsi-lib.sh ] && source ${libdir}/${_distribution}/iscsi-lib.sh
      #[ -e ${libdir}/${_distribution}/drbd-lib.sh ] && source ${libdir}/${_distribution}/drbd-lib.sh
    done
    unset _distribution
    
    # store the data to repository
    repository_store_value distribution $distribution
    repository_store_value shortdistribution $shortdistribution
}
#********** sourceLibs
#****f* boot-lib.sh/sourceRootfsLibs
#  NAME
#    sourceLibs
#  SYNOPSIS
#    function sourceRootfsLibs(predir) {
#  DESCRIPTION
#    Sources the libraries needed for the specific roots. Sets up rootfs in repository.
#  IDEAS
#  SOURCE
#
sourceRootfsLibs() {
	if [ -n "$OSR_ROOTFSLIBSSOURCED" ] && [ $OSR_ROOTFSLIBSSOURCED -eq 1 ]; then
		return 0
	fi
	OSR_ROOTFSLIBSSOURCED=1
	local libdir=$1
	. /tmp/root.info
    local rootfs=$fstype
    local shortdistribution=$(repository_get_value shortdistribution)
    local distribution=$(repository_get_value distribution)

	[ -e ${libdir}/${rootfs}-lib.sh ] && . ${libdir}/${rootfs}-lib.sh
	[ -e ${libdir}/${shortdistribution}/${rootfs}-lib.sh ] && . ${libdir}/${shortdistribution}/${rootfs}-lib.sh
	[ -e ${libdir}/${distribution}/${rootfs}-lib.sh ] && . ${libdir}/${distribution}/${rootfs}-lib.sh
	# special case for nfs4
	if [ $(expr substr $rootfs 1 3) = "nfs" ]; then
	   [ -e ${libdir}/nfs-lib.sh ] && . ${libdir}/nfs-lib.sh
	   [ -e ${libdir}/${shortdistribution}/nfs-lib.sh ] && . ${libdir}/${shortdistribution}/nfs-lib.sh
       [ -e ${libdir}/${distribution}/nfs-lib.sh ] && . ${libdir}/${distribution}/nfs-lib.sh
    fi
    repository_store_value rootfs $rootfs
}
#********** sourceRootfsLibs

#****f* boot-lib.sh/exec_local
#  NAME
#    exec_local
#  SYNOPSIS
#    function exec_local() {
#  DESCRIPTION
#    execs the given parameters in a subshell and returns the
#    error_code
#  IDEAS
#
#  SOURCE
#
exec_local() {
  local debug=$(cat /tmp/osr.debug)
  local do_exec=1
  local dstep_ans=
  local output=
  if [ -n "$(cat /tmp/osr.dstep)" ]; then
  	echo -n "$* (Y|n|c)? " >&2
  	read dstep_ans
  	[ "$dstep_ans" == "n" ] && do_exec=0
  	[ "$dstep_ans" == "c" ] && dstepmode=""
  fi
  if [ $do_exec -eq 1 ]; then
  	output=$($*)
  else
  	output="skipped"
  fi
  return_c=$?
  if [ ! -z "$debug" ]; then
    info "osr: cmd: $*" >&2
    info "osr: OUTPUT: $output" >&2
  fi
#  echo "cmd: $*" >> $bootlog
  echo -n "$output"
  return $return_c
}
#************ exec_local

#****f* boot-lib.sh/step
#  NAME
#    step
#  SYNOPSIS
#    function step( info ) {
#  MODIFICATION HISTORY
#  IDEAS
#    Modify or debug a running skript
#  DESCRIPTION
#    If stepmode step asks for input.
#  SOURCE
#
step() {
   local __the_step=""
   local __message="$1"
   local __name="$2"
   local __stepmode=$(repository_get_value step)
   local steps
   if [ -n "$__stepmode" ] && [ "$__stepmode" == "__set__" ]; then
   	 echo -n "osr: $__message: "
     echo -n "osr: Press <RETURN> to continue (timeout in $step_timeout secs) [quit|break|continue|list]"
     read -t$step_timeout __the_step
     case "$(echo $__the_step | tr A-Z a-z)" in
       "q" | "qu" | "qui" |"quit")
         exit 2
         ;;
       "c" | "co" | "con" | "cont" | "conti" | "contin" | "continu" | "continue")
         __stepmode=""
         ;;
       "b" | "br" | "bre"  | "brea" | "break")
         echo_local "Break detected forking a shell"
         breakp
         return 0
         ;;
       "l" | "li" | "lis" | "list")
         echo_local "List of breakpoints:"
         listBreakpoints
         echo
         step "List done!" "$__name"
         return 0
         ;;
       *)
         if [ -n "$__the_step" ]; then
         	for _pb in $(listBreakpoints); do
         		if [ $__the_step = $_pb ]; then
         			echo_local "Setting breakpoint to \"$__the_step\".."
         			__stepmode=$__the_step
         			break
         		fi
         	done
         	echo
         fi
         ;;
     esac
     if [ -z "$__the_step" ]; then
       echo
     fi
     if [ -n "$__the_step" ] && [ "$__the_step" != "$(repository_get_value step)" ]; then
       repository_store_value step "$__stepmode"
     fi
   elif [ -n "$__stepmode" ] && [ -n "$__name" ] && [ "$__name" == "$__stepmode" ]; then
     # reseting if came from a breakpoint.
     __stepmode="__set__"
     echo "$__stepmode" > /tmp/osr.stepmode
     echo_local "Breakpoint \"$__name\" detected forking a shell"
     breakp
   else
     return 0
   fi
}
#************ step

#****f* boot-lib.sh/listBreakpoints
#  NAME
#    listBreakpoints
#  SYNOPSIS
#    function listBreakpoints() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
listBreakpoints() {
	for file in $(find ./ -name "*.sh"); do 
		awk '
/step[[:space:]]+"/ && $0 !~ /__name/ { 
	step=$0; 
	sub(/step[[:space:]]+/, "", step); 
	gsub(/"/, "", step); split(step, steps); 
	print steps[NF-1];
}' < $file; done
}
#************ listBreakpoints

#****f* boot-lib.sh/breakp
#  NAME
#    break
#  SYNOPSIS
#    function breakp( info ) {
#  MODIFICATION HISTORY
#  IDEAS
#    Modify or debug a running skript
#  DESCRIPTION
#  SOURCE
#
breakp() {
    local shell=$(cat /tmp/osr.shell)
    local issuetmp=$(cat /tmp/osr.shellissuetmp)
    [ -z "$shell" ] && shell="/bin/sh"
    echo -e "$*" >  $issuetmp
    echo "Type exit to continue work.." >> $issuetmp
    if [ -n "$simulation" ] && [ $simulation ]; then
        $shell
    else
        TERM=xterm $shell &>/dev/console
    fi
    echo_local "Back to work.."
    #rm -f $rcfile
}
#*********** breakp

#****f* boot-lib.sh/echo_local
#  NAME
#    echo_local
#  SYNOPSIS
#    function echo_local() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
echo_local() {
   info $@
}
#************ echo_local
