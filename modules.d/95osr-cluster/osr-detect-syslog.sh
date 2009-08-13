#!/bin/sh
# This script detects syslog settings from node repository if available and write the data to the
# specified environment.

if [ -n "$dracutlib" ] && [ -f $dracutlib ]; then
	. $dracutlib
elif [ -f /lib/dracut-lib.sh ]; then
  . /lib/dracut-lib.sh
fi

if getarg rdnetdebug ; then
    exec >/tmp/osr-detect-syslog.$1.$$.out
    exec 2>>/tmp/osr-detect-syslog.$1.$$.out
    set -x
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

nodeid=$(repository_get_value nodeid)
. /etc/conf.d/osr-nodeidvalues-${nodeid}.conf
getarg "syslog" || repository_has_key "server" "syslog" || [ -z "$syslog_name" ]
if [ $? -ne 0 ]; then
  repository_store_value "server" "$syslog_name" "syslog"
  info "osr-detect-syslog: syslogserver: "$(repository_get_value "server" "syslog")
fi
getarg "sysloglevel" || repository_has_key "level" "syslog" || [ -z "$syslog_level" ] || repository_store_value "level" "$syslog_level" "syslog"
getarg "syslogsubsys" || repository_has_key "subsys" "syslog" || [ -z "$syslog_subsys" ] || repository_store_value "subsys" "$syslog_subsys" "syslog"
getarg "syslogtype" || repository_has_key "type" "syslog" || [ -z "$syslog_type" ] || repository_store_value "type" "$syslog_type" "syslog"
	