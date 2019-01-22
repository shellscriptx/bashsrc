#!/bin/bash

#----------------------------------------------#
# Source:           grp.sh
# Data:             23 de dezembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__GRP_SH ]] && return 0

readonly __GRP_SH=1

source builtin.sh

readonly __GRP_PATH='/etc/group'
readonly __ERR_GRP_READ_GROUP_FILE='falha ao ler o arquivo base'
readonly __ERR_GRP_GROUP_NOT_FOUND='grupo não encontrado'

# type group
#
# Implementa 'S' com os métodos:
#
# S.getgrgid => [uint]
# S.getgrusers => [str]
# S.getgrpass => [str]
#

# func grp.getgrgid <[str]grpname> => [uint]
#
# Retorna o id associado a 'grpname'.
#
function grp.getgrgid()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_info "$1" gid
	return $?
}

# func grp.getgrusers <[str]grpname> => [str]
#
# Retorna uma lista iterável com os usuários de 'grpname'.
#
function grp.getgrusers()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_info "$1" users
	return $?
}

# func grp.getgrpass <[str]grpname> => [str]
#
# Retorna a flag de sinalização de senha
#
function grp.getgrpass()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_info "$1" pass
	return $?
}

# func grp.getgrpnam <[uint]gid> => [str]
#
# Retorna o nome do grupo associado ao 'gid'.
#
function grp.getgrnam()
{
	getopt.parse "gid:uint:+:$1"
	
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
	getopt.parse "-:null:-:$*"
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
			error.__trace def 'group' 'str' "$1" "$__ERR_GRP_GROUP_NOT_FOUND"; return $?
		fi	
	else
		error.__trace def '' '' "$__GRP_PATH" "$__ERR_GRP_READ_GROUP_FILE"; return $?
	fi

	return $?
}

readonly -f grp.getgrgid \
			grp.getgrusers \
			grp.getgrpass \
			grp.getgrnam \
			grp.getgrall \
			grp.__get_info

# /* __GRP_SH */
