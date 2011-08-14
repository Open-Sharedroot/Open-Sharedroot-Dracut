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



#=== FUNCTION ==================================================================
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

#=== FUNCTION ==================================================================
# NAME:
#    std_paramStore()
# SEMINAMESPACE:
#    std_
# DESCRIPTION:
#
# PARAMETER:
#    _key
# LOCALE-VAR:
#    _var:
#    _isSuccess:
#        return value of success from system()-function. (true or false)
#    _returnVar:
#        return value of success from system()-function. Or return a exception.
# RETUNS:
#    maybe if a exception throw, then is give back.
#==============================================================================
function std_paramStore(_key,_value, _var,_isSuccess,_bashComand,_returnVar)
{
    # initialize private variable
    _var = ""
    _isSuccess = 0
    _bashComand = ""
    _returnVar = ""

    _bashComand = ". /lib/dracut-lib.sh; getarg " _key
    _returnVar = std_sysCommand( _bashComand)
    if ( std_ExceptionHandler(_returnVar,_ex) )
    {
        return _returnVar
    }

    _bashComand = ". /lib/osr/repository-lib.sh; repository_store_value " _key _returnVar
    _returnVar = std_sysCommand(_bashComand)
    if ( std_ExceptionHandler(_returnVar,_ex) )
    {
        return _returnVar
    }

    if(_value != "")
    {
        _bashComand = ". /lib/osr/repository-lib.sh; repository_store_value " _key _value
        _returnVar = std_sysCommand( _bashComand)
        if ( std_ExceptionHandler(_returnVar,_ex) )
        {
            return _returnVar
        }
    }

}

#=== FUNCTION ==================================================================
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
#        String for storage a bash vcmand
# RETUNS:
#   If file exist, it's return "TRUE", else "FALSE"
#==============================================================================
function std_isFileExist(_path, _bashComand, _returnVar)
{
    # initialize private variable
    _bashComand = ""
    _returnVar = ""

    _bashComand = "if [ -f " _path " ] ; then echo 'TRUE';  fi"
    _returnVar = std_sysCommand(_bashComand)
    if ( std_ExceptionHandler(_returnVar,_ex) )
    {
        return _returnVar
    }
    if ( _returnVar != "TRUE")
    {
        return "FALSE"
    }    
    return _returnVar
}


#=== FUNCTION ==================================================================
## NAME:
##    std_sysCommand()
## NAMESPACE:
##    std
## DESCRIPTION:
##   This function execute a system command.
## PARAMETER:
##    ITEM: _bashComand
##       a bash command.
## LOCALE:
##    ITEM: _returnVar
##        value of return from system-functions-call.
##    ITEM: _returnVarSum
##        the sum of all returns.
## RETURN:
##   The output of the bash command. Or return a exception string.
##   for exception handling see std_ExceptionHandler()
## EXCEPTION:
##    ITEM: SystemException
##       If system-function not successful than return
##       "Exception@SystemException@[....]" string.
#==============================================================================
function std_sysCommand(_bashComand, _returnVar,_returnVarSum)
{
    # initialize private variable
    _returnVar = ""
    _returnVarSum = ""

    while ((_bashComand | getline  _returnVar) > 0) {
        _returnVarSum += _returnVar
    }
    if( close(_bashComand) != 0 )
    {
        return "Exception@SystemException@process is not successful ending."
    }
    return _returnVarSum
}

#=== FUNCTION ==================================================================
# NAME:
#    std_ExceptionHandler()
# SMEINAMESPACE:
#    std_
# DESCRIPTION:
#   This function checked is a function return a value with a exception.
# PARAMETER:
#    _frv:
#       it's meaning 'function return value'
#       A value of a (other) function return. Ther is maybe a exception-info
#       as string.
#   _exception:
#       Set a reference of (empty) array . If in parameter '_info' a exception,
#       in this array you can find the details:
#       '_exception["specification"]' is store the exception specification.
#       '_exception["message"]' is store the additional exception infos/messages.
# LOCALE-VAR:
#    _array:
#        Is for splitting string.
# RETURNS:
#   If in parameter '_info' a exception, the function returns '1' (it's
#   meaning 'true'). And '0' for 'false'
#==============================================================================
function std_ExceptionHandler(_returnValue,_exception, _array)
{
    if( index(_returnValue, "Exception@") != 0)
    {
        split(_returnValue, _array, "@")
        _exception["specification"] = _array[2]
        _exception["message"] = _array[3]
        return 1
    }
    return 0
}