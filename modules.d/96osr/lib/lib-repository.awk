#!/usr/bin/awk -f
#==============================================================================
# FILE:
#       lib-repository.awk
# SEMINAMESPACE:
#       repository_
# DESCRIPTION:
#       
# AUTORS:
#       Olaf Radicke <radicke@atix.de>
# COMPANY:
#       ATIX AG
# LIZENZ:
#
#==============================================================================


#=== FUNCTION ==================================================================
## NAME:
##    repository_getPrefix
## NAMESPACE:
##    repository_
## DESCRIPTION:
##    Prefix for every variable found in the repository
## RETURN:
##    A prefix.
#==============================================================================
function repository_getPrefix()
{
    return ""
}

#=== FUNCTION ==================================================================
## NAME:
##    repository_getPath
## NAMESPACE:
##    repository_
## DESCRIPTION:
##    Where to store the repository
# PARAMETER:
#
# LOCALE:
#
## RETURN:
##
#==============================================================================
function repository_getPath()
{
    return "/tmp"
}

#=== FUNCTION ==================================================================
## NAME:
##    repository_getDefault
## NAMESPACE:
##    repository_
## DESCRIPTION:
##    Repository name that is prefixed for any file used by the repository
##    followed by a "."
# PARAMETER:
#
# LOCALE:
#
## RETURN:
##    Repository name as string.
#==============================================================================
function repository_getDefault()
{
    return "osr"
}

#=== FUNCTION ==================================================================
## NAME:
##    repository_getFS
## NAMESPACE:
##    repository_
## DESCRIPTION:
##    Get back a '_'
# PARAMETER:
#
# LOCALE:
#    
## RETURN:
##    Get back a '_'
#==============================================================================
function repository_getFS()
{
    return "_"
}

#=== FUNCTION ==================================================================
## NAME:
##    repository_getValue()
## SEMINAMESPACE:
##    repository_
## DESCRIPTION: repository_get_value()
##    origin bash function
##    return the value from the repository with the name repository_name
## PARAMETER:
##    ITEM: _key
##       key of value
##    ITEM: _repository
##
## LOCALE:
##    ITEM: _value
##        store a value.
##    ITEM: _path
##    ITEM: _bashComand
##       store a bash command.
##    ITEM: _bashVariable
##       store a bash variable.
## RETURN:
##    if the function found the the file with date auf key, then it's
##    get back this value and set this as bash variable.
## EXCEPTION:
##     ITEM: FileException
##         Forme like "EXCEPTION@FileException@file no found"
## TODO:
##   Replace system()-function with std_sysCommand()-function
#==============================================================================
function repository_getValue(_key,_repository, _value,_path,_bashComand,_bashVariable,_isSuccess)
{
    # initialize private variable
    _value = ""
    _path = ""
    _bashComand = ""
    _bashVariable = ""
    _isSuccess = ""
    
    _key = repository_normalizeValue(_key)
    if(_repository == "")
    {
        _repository = repository_getDefault()
    }
    _path = repository_getPath() "/" repository_getPrefix() _repository "." _key
    if( std_isFileExist(_path) == "TRUE")
    {
        _bashComand = "cat " _path
        _isSuccess = system( _bashComand | getline _value)
        _bashVariable = repository_getPrefix() _repository repository_getFS() _key
        _bashComand = _bashVariable  "=\"" _value "\""
        system( _bashComand )
        return _value
    }
    return "EXCEPTION@FileException@file no found"
}

#****f* repository-lib.sh/repository_get_value
#  NAME
#    repository_get_value
#  SYNOPSIS
#    function repository_get_value(key, repository_name)
#  DESCRIPTION
#    return the value from the repository with the name repository_name
#  IDEAS
#  SOURCE
#
    # repository_get_value() {
    #     local key=$(repository_normalize_value $1)
    #     local repository="$2"
# TODO
    #     [ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
    #     local value=
    #     if [ -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key ]; then
    #         value=$(cat ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key)
    #         eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=\"$value\""
    #         echo $value
    #         return 0
    #     fi
    #     return 1
    # }
#******* repository_get_value



#=== FUNCTION ==================================================================
## NAME:
##    repository_normalizeValue()
## SEMINAMESPACE:
##    repository
## DESCRIPTION:
##    normalizes a value
## PARAMETER:
##    ITEM: _value
##       value
## LOCALE:
##    
## RETURN:
##
#==============================================================================
function repository_normalizeValue(_value)
{
    gsub("-", "_", _value)
    return _value
}

