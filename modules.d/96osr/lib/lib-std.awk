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
## NAME:
##    std_getLibDir
## NAMESPACE:
##    std_
## DESCRIPTION:
##    Get back the lib dir path
## RETURNS:
##    Return path of lib as string.
#==============================================================================
function std_getLibDir()
{
    return "/lib/osr"
}

#=== FUNCTION ==================================================================
## NAME:
##    std_paramStore()
## SEMINAMESPACE:
##    std_
## DESCRIPTION:
##
## PARAMETER:
##    _key
## LOCAL:
##    ITEM: _var
##    ITEM: _isSuccess
##        return value of success from system()-function. (true or false)
##    ITEM: _returnVar
##        return value of success from system()-function. Or return an exception.
## RETURNS:
##    if an exception throw, then return an axception messages.
#==============================================================================
function std_paramStore(_key,_value, _var,_isSuccess,_bashCommand,_returnVar)
{
    # initialize private variable
    _var = ""
    _isSuccess = 0
    _bashCommand = ""
    _returnVar = ""

    _bashCommand = ". /lib/dracut-lib.sh; getarg " _key
    _returnVar = std_sysCommand( _bashCommand)
    if ( std_ExceptionHandler(_returnVar,_ex) )
    {
        return _returnVar
    }

    _bashCommand = ". /lib/osr/repository-lib.sh; repository_store_value " _key _returnVar
    _returnVar = std_sysCommand(_bashCommand)
    if ( std_ExceptionHandler(_returnVar,_ex) )
    {
        return _returnVar
    }

    if(_value != "")
    {
        _bashCommand = ". /lib/osr/repository-lib.sh; repository_store_value " _key _value
        _returnVar = std_sysCommand( _bashCommand)
        if ( std_ExceptionHandler(_returnVar,_ex) )
        {
            return _returnVar
        }
    }

}

#=== FUNCTION ==================================================================
## NAME:
##    osr_paramStore()
## NAMESPACE:
##    std_
## DESCRIPTION:
##   This function check if a file exist.
## PARAMETER:
##    ITEM _path:
##       a fiel path
## LOCAL:
##    ITEM: _command:
##        String for storage a bash command
## RETURNS:
##   If file exists, it returns "TRUE", else "FALSE"
#==============================================================================
function std_isFileExist(_path, _bashCommand, _returnVar)
{
    # initialize private variable
    _bashCommand = ""
    _returnVar = ""

    _bashCommand = "if [ -f " _path " ] ; then echo 'TRUE';  fi"
    _returnVar = std_sysCommand(_bashCommand)
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
##   This function executes a system command.
## PARAMETER:
##    ITEM: _bashCommand
##       a bash command.
## LOCAL:
##    ITEM: _returnVar
##        value of return from system-functions-call.
##    ITEM: _returnVarSum
##        the sum of all returns.
## RETURN:
##   The output of the bash command. Or returns a exception string.
##   for exception handling see std_ExceptionHandler()
## EXCEPTION:
##    ITEM: SystemException
##       If system-function not successful than return
##       "Exception@SystemException@[....]" string.
#==============================================================================
function std_sysCommand(_bashCommand, _returnVar,_returnVarSum)
{
    # initialize private variable
    _returnVar = ""
    _returnVarSum = ""

    while ((_bashCommand | getline  _returnVar) > 0) {
        _returnVarSum += _returnVar
    }
    if( close(_bashCommand) != 0 )
    {
        return "Exception@SystemException@process is not successfully ending."
    }
    return _returnVarSum
}

#=== FUNCTION ==================================================================
## NAME:
##    std_ExceptionHandler()
## NAMESPACE:
##    std_
## DESCRIPTION:
##   This function checks if a function return an value with a exception.
## PARAMETER:
##    ITEM: _returnValue
##       it's meaning 'function return value'
##       A value of a (other) function return. There is maybe an exception-info
##       as a string.
##   ITEM: _exception
##       Set a reference of (empty) array . If in parameter '_info'
##       there is an exception, in this array you can find the details:
##       '_exception["specification"]' is store the exception specification.
##       '_exception["message"]' is store the additional exception infos/messages.
## LOCAL:
##    ITEM: _array
##        Is for splitting the string.
## RETURNS:
##   If in parameter '_info' a exception, the function returns '1' (it's
##   meaning 'true'). And '0' for 'false'
#==============================================================================
function std_ExceptionHandler(_returnValue,_exception,  _array)
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