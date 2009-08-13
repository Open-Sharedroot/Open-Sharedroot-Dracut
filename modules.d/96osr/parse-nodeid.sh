#!/bin/sh
#
# Format:
#	nodeid=<nodeid>
# If nodeid is given take it or implicitly get it from initrd (see setup-cmdline.sh)
#

. /lib/dracut-lib.sh

if [ -f std-lib.sh ]; then
	. ./std-lib.sh
	libdir="."
elif [ -f /lib/osr/std-lib.sh ]; then 
    .  /lib/osr/std-lib.sh
    libdir="/lib/osr"
else
    die "osr: Could not find library boot-lib.sh but it is required for OSR module to be working"
fi
sourceLibs $libdir

# first get the default nodeid if already set (might be from module osr-cluster)
osr_param_store "nodeid"

# We will later (in validate.sh) check if all parameters and prerequsits needed are available 
if [ -n "$nodeid" ]; then
	info "osr: found nodeid $osr_nodeid."
else
    info "osr: No nodeid given as bootparameter."
fi
