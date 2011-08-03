#!/usr/bin/igawk -f
#==============================================================================
# FILE:
#       lib-std.awk
# SEMINAMESPACE:
#       std_
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
#       osr_paramStore()
# SEMINAMESPACE:
#       std_
# DESCRIPTION:
#
# PARAMETER:
#       _key
# LOCALE-VAR:
#       _var
#==============================================================================

std_osr_paramStore(_key, _var) {

    system(". /lib/dracut-lib.sh; getarg $key 2>/dev/null" | getline _var)
# todo...    
    _var=$(getarg $key 2>/dev/null) && repository_store_value $key $_var
    if [ $? -ne 0 ] && [ -n "$2" ]; then
        repository_store_value "$key" "$2"
    fi
}