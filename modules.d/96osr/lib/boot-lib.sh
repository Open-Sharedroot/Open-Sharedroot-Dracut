
#****f* boot-lib.sh/getBootParm
#  NAME
#    getBootParm
#  SYNOPSIS
#    function getBootParm(param, [default])
#  DESCRIPTION
#    Gets the given parameter from the bootloader command line. If not
#    found default or the empty string is echoed.
#    If the parameter has been found or default is given 0 is returned 1 otherwise.
#  SOURCE
#
getBootParm() {
   local parm="$1"
   local default="$2"
   if [ -z "$3" ] && [ -z "$CMDLINE" ]; then
     local _cmdline=""
     read _cmdline </proc/cmdline
   elif [ -n "$CMDLINE" ]; then
     local _cmdline="$CMDLINE" 
   else
     local _cmdline="$3"
   fi
   local found=1
   local out=""

   for param in $_cmdline; do
     local name=$(echo $param | cut -f1 -d=)
     local value=$(echo $param | cut -f2- -d=)
     
     if [ -n "$name" ] && [ "$name" = "$parm" ]; then
     	if [ "$name" = "$value" ]; then
     	  out=""
        else
          out=$value
        fi
    	found=0
     fi 
   done
   if [ -z "$out" ] && [ -n "$default" ]; then 
   	 out="$default"
   	 found=0
   fi
   #out=`expr "$cmdline" : ".*$parm=\([^ ]*\)" 2>/dev/null`
   #if [ -z "$out" ]; then
   #	  if [ $(expr "$cmdline" : ".*$parm" 2>/dev/null) -gt 0 ]; then out=1; fi
   #   if [ -z "$out" ]; then out="$default"; fi
   #fi
   echo -n "$out"
   #if [ -z "$out" ]; then
   #    return 1
   #else
   #    return 0
   #fi
   return $found
}
#************ getBootParm

#****f* boot-lib.sh/getDistribution
#  NAME
#    getDistribution
#  SYNOPSIS
#    funtion getDistribution
#  DESCRIPTION
#    Returns the shortdescription of this distribution. Valid return strings are
#    e.g. rhel4, rhel5, sles10, fedora9, ..
#  SOURCE
getDistribution() {
    local temp
	temp=$(getDistributionList)
	echo $temp | tr -d " "
}
#**** getDistribution

#****f* boot-lib.sh/getDistributionList
#  NAME
#    getDistributionList
#  SYNOPSIS
#    funtion getDistributionList
#  DESCRIPTION
#    returns the shortname of the Linux Distribution and version as 
# defined in the /etc/..-release files. E.g. rhel 4 7 is returned for the redhat enterprise 
# linux verion 4 U7. 
#  SOURCE
getDistributionList() {
	if [ -e /etc/redhat-release ] || [ -e /etc/fedora-release ]; then
	    [ -e /etc/redhat-release ] && releasefile=/etc/redhat-release
	    [ -e /etc/fedora-release ] && releasefile=/etc/fedora-release
		awk '
		   BEGIN { shortname="unknown"; version=""; }
	       tolower($0) ~ /red hat enterprise linux/ || tolower($0) ~ /centos/ || tolower($0) ~ /scientific/ || tolower($0) ~ /enterprise linux enterprise linux/ { 
	       	  shortname="rhel";
	       	  match($0, /release ([[:digit:]]+)/, _version);
	       	  version=_version[1] 
	       }
	       tolower($0) ~ /fedora/ {
	       	  shortname="fedora"
	       	  match($0, /release ([[:digit:]]+)/, _version);
	       	  version=_version[1] 
	       }
	       {
	       	 next;
	       } 
	       END {
	       	 print shortname,version;
	       }' < $releasefile
#		
#    	if cat /etc/redhat-release | grep -i "release 4" &> /dev/null; then
#     		echo "rhel4"
#   	 	elif cat /etc/redhat-release | grep -i "release 5" &> /dev/null; then
#   	 		echo "rhel5"
#    	else
#    	    echo "rhel5"
#    	fi
    elif [ -e /etc/SuSE-release ]; then
        awk -vdistribution=sles '
        /VERSION[[:space:]]*=[[:space:]]*[[:digit:]]+/ { 
        	print distribution,$3;
        }' /etc/SuSE-release
	else
		echo "unknown"
    	return 2
   	fi
}
#**** getDistributionList

#****f* boot-lib.sh/create_xtab
#  NAME
#    create_xtab build a chroot environment
#  SYNOPSIS
#    function create_xtab($xtabfile, $dirs) {
#  MODIFICATION HISTORY
#  USAGE
#  create_xtab
#  IDEAS
#
#  SOURCE
#
create_xtab() {
	local xtabfile="$1"
	local _dir
	shift
	# truncate
	echo -n > $xtabfile
	for _dir in $*; do
	  echo "$_dir" >> $xtabfile
	done
}
#************** create_xtab

#****f* boot-lib.sh/create_xrootfs
#  NAME
#    create_xrootfs build a chroot environment
#  SYNOPSIS
#    function create_xrootfs($xrootfsfile, $rootfss) {
#  MODIFICATION HISTORY
#  USAGE
#  create_xrootfs
#  IDEAS
#
#  SOURCE
#
create_xrootfs() {
	local xrootfsfile="$1"
	local _rootfs
	shift
	# truncate
	echo -n > $xrootfsfile
	for _rootfs in $*; do
	  echo "$_rootfs" >> $xrootfsfile
	done
}
#************** create_xrootfs

#****f* boot-lib.sh/create_xkillall_procs
#  NAME
#    create_xkillall_procs build a chroot environment
#  SYNOPSIS
#    function create_xkillall_procs($xkillall_procsfile, $rootfss) {
#  MODIFICATION HISTORY
#  USAGE
#  create_xkillall_procs
#  IDEAS
#
#  SOURCE
#
create_xkillall_procs() {
	local xkillall_procsfile="$1"
	local _clutype="$2"
	local _rootfs="$3"
	local _proc=
	shift
	# truncate
	echo -n > $xkillall_procsfile
#	for _proc in $(cc_get_userspace_procs $_clutype); do
#	  echo "$_proc" >> $xkillall_procsfile
#	done
	if [ "$_clutype" != "$_rootfs" ]; then
	  for _proc in $(rootfs_get_userspace_procs $_rootfs); do
	    echo "$_proc" >> $xkillall_procsfile
	  done
	fi
}
#************** create_xkillall_procs
