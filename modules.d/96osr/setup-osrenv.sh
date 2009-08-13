#!/bin/dash
#
# Just sets up the environment for the open sharedroot.
#
# Some parameters might be setup inside this initrd not by the bootloader. This would lead to the usage
# of a shared boot with also shared boot parameters. 
# This feature is important e.g. for sharedroot clusters using a common bootloader configuration.

#[ "$CMDLINE" ] || read CMDLINE </proc/cmdline
if [ -n "$dracutlib" ] && [ -f $dracutlib ]; then
	. $dracutlib
elif [ -f /lib/dracut-lib.sh ]; then
  . /lib/dracut-lib.sh
fi

if [ -f std-lib.sh ]; then
	. ./std-lib.sh
	libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr-detect-root: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs ${libdir} 

#CMDLINE="$CMDLINE"

#export CMDLINE
# don't fail fi root is not ok.
[ -z "$rootok" ] && rootok=1
[ -z "$root" ] && root=autodetect
[ -z "$netroot" ] && netroot=true

osr_param_store logofile "/etc/atix-logo.txt"
osr_param_store shellrcfile ${libdir}/shinitrc
osr_param_store shellissue ${predir}/etc/issue
osr_param_store shellissuetmp ${predir}/tmp/issue
osr_param_store shell "/bin/bash --rcfile $(repository_get_value shellrcfile)"
osr_param_store sysctlfile "${predir}/etc/sysctl.conf"
osr_param_store xtabfile /etc/xtab
osr_param_store xrootfsfile /etc/xrootfs
osr_param_store xkillallprocsfile /etc/xkillallprocs
