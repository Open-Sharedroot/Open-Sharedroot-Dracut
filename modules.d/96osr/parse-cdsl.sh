#!/bin/sh
#
# Parse the cdsl settings. Normally defaults should be ok. But if need be to overwrite it the do it.
# Format:
#   cdsltree=<dirinroot> default: /cluster/cdsl
#   cdsllink=<wheretobindmountto> default: /cdsl.local
#   cdslsharedtree=<wheretoreshareto> default: /cluster/shared
# TODO: Should be autocreated at initrd buildtime and parsed from /var/lib/cdsl/cdsl_inventory.xml
#

# We'll use the dracut library
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

echo "[parse-cdsl] jump in..."
info  "[parse-cdsl] jump in..."

osr_param_store "cdsltree" "/cluster/cdsl"
osr_param_store "cdslsharedtree" "/cluster/shared"
osr_param_store "cdsllink" "/cdsl.local"
