#!/bin/awk -f
#==============================================================================
# FILE:
#       lib-std.awk
# DESCRIPTION:
#       Standart Lib for com.oonics-dracut-module
# AUTORS:
#       Olaf Radicke <radicke@atix.de>
# COMPANY:
#       ATIX AG
# LIZENZ:
#
#==============================================================================


#=== FUNTION ==================================================================
# NAME:
#       osr_param_store()
# DESCRIPTION:
#
# PARAMETER:
#       key
# LOCALE-VAR:
#       var
#==============================================================================

osr_param_store(key var) {

    system(". /lib/dracut-lib.sh; getarg $key 2>/dev/null" | getline var)
# todo...    
    var=$(getarg $key 2>/dev/null) && repository_store_value $key $var
    if [ $? -ne 0 ] && [ -n "$2" ]; then
        repository_store_value "$key" "$2"
    fi
}