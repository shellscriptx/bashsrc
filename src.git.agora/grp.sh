#!/bin/bash

#    Copyright 2018 Juliano Santos [SHAMAN]
#
#    This file is part of bashsrc.
#
#    bashsrc is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    bashsrc is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with bashsrc.  If not, see <http://www.gnu.org/licenses/>.

[[ $__GRP_SH ]] && return 0

readonly __GRP_SH=1

source builtin.sh

__TYPE__[group_t]='
grp.getgrgid
grp.getgrusers
grp.getgrpass
'

readonly __GRP_PATH='/etc/group'
readonly __ERR_GRP_READ_GROUP_FILE='falha ao ler o arquivo base'
readonly __ERR_GRP_GROUP_NOT_FOUND='grupo não encontrado'

# func grp.getgrgid <[str]grpname> => [uint]
#
# Retorna o id associado a 'grpname'.
#
function grp.getgrgid()
{
	getopt.parse 1 "grpname:str:+:$1" ${@:2}
	grp.__get_info "$1" gid
	return $?
}

# func grp.getgrusers <[str]grpname> => [str]
#
# Retorna uma lista iterável com os usuários de 'grpname'.
#
function grp.getgrusers()
{
	getopt.parse 1 "grpname:str:+:$1" ${@:2}
	grp.__get_info "$1" users
	return $?
}

# func grp.getgrpass <[str]grpname> => [str]
#
# Retorna a flag de sinalização de senha
#
function grp.getgrpass()
{
	getopt.parse 1 "grpname:str:+:$1" ${@:2}
	grp.__get_info "$1" pass
	return $?
}

# func grp.getgrpnam <[uint]gid> => [str]
#
# Retorna o nome do grupo associado ao 'gid'.
#
function grp.getgrnam()
{
	getopt.parse 1 "gid:uint:+:$1" ${@:2}
	
	local grpname
	while read grpname; do
		[[ $(grp.__get_info "$grpname" gid) -eq $1 ]] && echo "$grpname" && break
	done < <(grp.__get_info '' all)
	
	return $?
}

# func grp.getgrall => [str]
#
# Retorna uma lista iterável com todos os grupos do sistema.
#
function grp.getgrall()
{
	getopt.parse 0 ${@:1}
	grp.__get_info '' all
	return $?
}

function grp.__get_info()
{
	local group info fields flag=$2
	declare -A entry
	
	if while read group; do
		entry[${group%%:*}]=${group//:/ }
	done < $__GRP_PATH 2>/dev/null; then
		
		if [[ $flag == all ]]; then 
			printf '%s\n' ${!entry[@]}
		elif [[ ${entry[$1]} ]]; then

			fields=(${entry[$1]})

			case $flag in
				pass) info=${fields[1]};;
				gid) info=${fields[2]};;
				users) info=${fields[@]:3}; info=${info//,/ };;
				*) return 1;;
			esac

			printf '%s\n' $info

		else
			error.trace def 'group' 'str' "$1" "$__ERR_GRP_GROUP_NOT_FOUND"; return $?
		fi	
	else
		error.trace def '' '' "$__GRP_PATH" "$__ERR_GRP_READ_GROUP_FILE"; return $?
	fi

	return $?
}

source.__INIT__
# /* __GRP_SH */
