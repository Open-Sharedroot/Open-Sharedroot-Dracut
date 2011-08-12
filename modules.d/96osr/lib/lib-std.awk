#!/usr/bin/awk -f
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
#    std_getLibDir
# SEMINAMESPACE:
#    std_
# DESCRIPTION:
#    Get back the lib dir path
# PARAMETER:
#
# LOCALE-VAR:
#
# RETUNS:
#
#==============================================================================
function std_getLibDir()
{
    return "/lib/osr"
}

#=== FUNTION ==================================================================
# NAME:
#    osr_paramStore()
# SEMINAMESPACE:
#    std_
# DESCRIPTION:
#
# PARAMETER:
#    _key
# LOCALE-VAR:
#    _var:
#    _isSuccess:
#        return value of success from system()-funtion. (true or false)
# RETUNS:
#    
#==============================================================================
function std_paramStore(_key,_value, _var,_isSuccess,_bashComand)
{
    # initialize private variable
    _var = ""
    _isSuccess = 0
    _bashComand = ""

    _bashComand = ". /lib/dracut-lib.sh; getarg " _key
    _isSuccess = system( _bashComand | getline _var)
    if(_isSuccess)
    {
        _bashComand = ". /lib/osr/repository-lib.sh; repository_store_value " _key _var
        _isSuccess = system(_bashComand)
    }
    if(_isSuccess)
    {
        if(_value != "")
        {
            _bashComand = ". /lib/osr/repository-lib.sh; repository_store_value " _key _value
            _isSuccess = system(_bashComand)
        }
    }
}

#=== FUNTION ==================================================================
# NAME:
#    osr_paramStore()
# SEMINAMESPACE:
#    std_
# DESCRIPTION:
#   This function check if a file exist.
# PARAMETER:
#    _path:
#       a fiel path
# LOCALE-VAR:
#    _command:
#        Strin for storage a bash komand
# RETUNS:
#   If file exist, it's return "TRUE", else "FALSE"
#==============================================================================
function std_isFileExist(_path, _bashComand, _returnVar)
{
    # initialize private variable
    _bashComand = ""
    _returnVar = ""
    
    _command = "if [ -f " _path " ] ; then echo 'TRUE';  fi"
    system( _bashComand | getline _returnVar)
    if( _returnVar != "TRUE")
    {
        _returnVar = "FALSE"
    }
    return _returnVar
}