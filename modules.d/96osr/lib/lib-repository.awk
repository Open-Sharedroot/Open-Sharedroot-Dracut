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


#=== FUNTION ==================================================================
# NAME:
#    repository_getPrefix
# SEMINAMESPACE:
#    repository_
# DESCRIPTION:
#    Prefix for every variable found in the repository
# PARAMETER:
#
# LOCALE-VAR:
#
# RETUNS:
#
#==============================================================================
function repository_getPrefix()
{
    return ""
}

#=== FUNTION ==================================================================
# NAME:
#    repository_getPath
# SEMINAMESPACE:
#    repository_
# DESCRIPTION:
#    Where to store the repository
# PARAMETER:
#
# LOCALE-VAR:
#
# RETUNS:
#
#==============================================================================
function repository_getPath()
{
    return "/tmp"
}

#=== FUNTION ==================================================================
# NAME:
#    repository_getDefault
# SEMINAMESPACE:
#    repository_
# DESCRIPTION:
#    Repository name that is prefixed for any file used by the repository
#    followed by a "."
# PARAMETER:
#
# LOCALE-VAR:
#
# RETUNS:
#
#==============================================================================
function repository_getDefault()
{
    return "osr"
}

#=== FUNTION ==================================================================
# NAME:
#    repository_getFS
# SEMINAMESPACE:
#    repository_
# DESCRIPTION:
#    
# PARAMETER:
#
# LOCALE-VAR:
#    
# RETUNS:
#
#==============================================================================
function repository_getFS()
{
    return "_"
}

#=== FUNTION ==================================================================
# NAME:
#    repository_getValue()
# SEMINAMESPACE:
#    repository_
# DESCRIPTION: repository_get_value()
#    origin bash function
#    return the value from the repository with the name repository_name
# PARAMETER:
#    _key:
#       key of value
#    _repository:
#
# LOCALE-VAR:
#    _value:
#        store a value.
#    _path:
#    _bashComand:
#       store a bash command.
#    _bashVariable:
#       store a bash variable.
# RETUNS:
#    if the function found the the file with date auf key, then it's
#    get back this value and set this as bash variable.
#    else get back "EXCEPTION@file no found".
#==============================================================================
function repository_getValue(_key,_repository, _value,_path,_bashComand,_bashVariable)
{
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
    return "EXCEPTION@file no found"
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



#=== FUNTION ==================================================================
# NAME:
#    repository_normalizeValue()
# SEMINAMESPACE:
#    repository_
# DESCRIPTION:
#    normalizes a value
# PARAMETER:
#    _value:
#       value
# LOCALE-VAR:
#    
# RETUNS:
#
#==============================================================================
function repository_normalizeValue(_value)
{
    gsub("-", "_", _value)
    return _value
}

