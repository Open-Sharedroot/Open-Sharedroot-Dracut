#
# $Id: repository-lib.sh,v 1.1 2009-08-13 09:25:46 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH, 2008 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
#****h* comoonics-bootimage/repository-lib.sh
#  NAME
#    repository-lib.sh
#    $id$
#  DESCRIPTION
#    Library for std operations
#*******

# Prefix for every variable found in the repository
[ -z "$REPOSITORY_PREFIX" ] && REPOSITORY_PREFIX=""
# Where to store the repository
[ -z "$REPOSITORY_PATH" ] && REPOSITORY_PATH="/tmp"
# Repository name that is prefixed for any file used by the repository followed by a "."
[ -z "$REPOSITORY_DEFAULT" ] && REPOSITORY_DEFAULT="osr"
[ -z "$REPOSITORY_FS" ] && REPOSITORY_FS="_"

#****f* repository-lib.sh/repository_load
#  NAME
#    repository_load
#  SYNOPSIS
#    function repository_load(name)
#  DESCRIPTION
#    loads the repository into environment.
#  IDEAS
#  SOURCE
#
repository_load() {
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	for file in ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.*; do
	  repository_get_value ${file#${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.} $repository
    done
}
#******* repository_load


#****f* repository-lib.sh/repository_normalize_value
#  NAME
#    repository_normalize_value
#  SYNOPSIS
#    function repository_normalize_value(value)
#  DESCRIPTION
#    normalizes a value
#  IDEAS
#  SOURCE
#
repository_normalize_value() {
	echo $1 | tr '-' '_'
}
#******* repository_store_value

#****f* repository-lib.sh/repository_store_value
#  NAME
#    repository_store_value
#  SYNOPSIS
#    function repository_store_value(key, value, repository_name)
#  DESCRIPTION
#    stores the key/value pair into the repository apropriate file with the name repository_name.key. 
#    If repository name is not given REPOSITORY_DEFAULT is used.
#    It also sets the environment variable ${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=$value
#  IDEAS
#  SOURCE
#
repository_store_value() {
	local key=$(repository_normalize_value $1)
	local value="__set__"
	if [ $# -gt 1 ]; then
		value="$2"
	fi
	local repository="$3"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=\"$value\""
	echo -n "$value" > ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key
	[ -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key ]
}
#******* repository_store_value

#****f* repository-lib.sh/repository_append_value
#  NAME
#    repository_append_value
#  SYNOPSIS
#    function repository_append_value(key, value, repository_name)
#  DESCRIPTION
#    appends the key/value pair into the repository with the name repository_name. 
#    If repository name is not give REPOSITORY_DEFAULT is used.
#  IDEAS
#  SOURCE
#
repository_append_value() {
	local key=$(repository_normalize_value $1)
	local repository="$3"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local value=$(repository_get_value $key $repository)
	eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=${value}\"$2\""
	echo -n "$2" >> ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key
}
#******* repository_append_value

#****f* repository-lib.sh/repository_list_keys
#  NAME
#    repository_list_keys
#  SYNOPSIS
#    function repository_list_keys(repository_name)
#  DESCRIPTION
#    return a list of all variablenames found in the given repository
#  IDEAS
#  SOURCE
#
repository_list_keys() {
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local values=""
	local key
#	repository_load $repository
	for key in ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.*; do
		key=${key#${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.}
		echo ${key}
   	done		
}
#******* repository_list_keys

#****f* repository-lib.sh/repository_list_values
#  NAME
#    repository_list_values
#  SYNOPSIS
#    function repository_list_values(repository_name)
#  DESCRIPTION
#    return a list of all variablevalues found in the given repository
#  IDEAS
#  SOURCE
#
repository_list_values() {
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local index=0
	local key
	for key in ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.*; do
		key=${key#${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.}
		echo $(repository_get_value $key $repository)
   	done		
}
#******* repository_list_values

#****f* repository-lib.sh/repository_list_items
#  NAME
#    repository_list_items
#  SYNOPSIS
#    function repository_list_items(ofs, ls, repository_name)
#  DESCRIPTION
#    return a list of all variablevalues found in the given repository
#  IDEAS
#  SOURCE
#
repository_list_items() {
	local repository="$3"
	local OFS=" "
	local LS="\n"
	[ -n "$1" ] && OFS="$1"
	[ -n "$2" ] && LS="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local values=""
	local key
	for key in $(repository_list_keys $repository); do
		if repository_has_key $key $repository; then
	      values=${values}${LS}${key}${OFS}$(repository_get_value $key $repository)
		fi
  	done		
 	echo -e $values
}
#******* repository_list_items

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
repository_get_value() {
	local key=$(repository_normalize_value $1)
	local repository="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local value=
	if [ -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key ]; then
		value=$(cat ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key)
		eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}${key}=\"$value\""
		echo $value
		return 0
	fi
	return 1
}
#******* repository_get_value

#****f* repository-lib.sh/repository_has_key
#  NAME
#    repository_has_key
#  SYNOPSIS
#    function repository_has_key(key, repository_name)
#  DESCRIPTION
#    return if the key exists in repository
#  IDEAS
#  SOURCE
#
repository_has_key() { 
	local key=$(repository_normalize_value $1)
	local repository="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	[ -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key ]
	return $?
}
#******* repository_has_key

#****f* repository-lib.sh/repository_del_value
#  NAME
#    repository_del_value
#  SYNOPSIS
#    function repository_del_value(key, repository_name)
#  DESCRIPTION
#    remove the given key from the repository.
#  IDEAS
#  SOURCE
#
repository_del_value() { 
	local key=$(repository_normalize_value $1)
	local repository="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	val=$(repository_get_value $key $repository)
	if [ $? -eq 0 ]; then
		eval "unset ${repository}${REPOSITORY_FS}${key}"
		rm -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.$key
	fi
}
#******* repository_del_value

#*****f* repository-lib.sh/repository_clear
#  NAME
#    repository_clear
#  SYNOPSIS
#    function repository_clear(repository_name)
#  DESCRIPTION
#    clears the given repository from disk
#  IDEAS
#  SOURCE
#
repository_clear() {
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
  	for key in $(repository_list_keys $repository); do
  		repository_del_value $key $repository
   	done
}
#******** repository_clear

#############
# $Log: repository-lib.sh,v $
# Revision 1.1  2009-08-13 09:25:46  marc
# initial revision
#
# Revision 1.3  2009/01/28 12:55:50  marc
# - some bugfixes
# - cleaned the code
# - added functions to make better use of it (clean, del, append)
#