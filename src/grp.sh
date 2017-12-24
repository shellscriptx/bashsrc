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
readonly __GRP_ERR_READ_GROUP_FILE='falha ao ler o arquivo base'
readonly __GRP_ERR_GROUP_NOT_FOUND='grupo não encontrado'

# type group
#
# Implementa 'S' com os métodos:
#
# S.getgrgid
# S.getgrusers
# S.getgrpass
#

# func grp.getgrgid <[str]grpname> => [uint]
#
# Retorna o id associado a 'grpname'.
#
grp.getgrgid()
{
	getopt.parse "grpname:str:+:$1"
	grp.___get_info "$1" gid
	return $?
}

# func grp.getgrusers <[str]grpname> => [str]
#
# Retorna uma lista iterável com os usuários de 'grpname'.
#
grp.getgrusers()
{
	getopt.parse "grpname:str:+:$1"
	grp.___get_info "$1" users
	return $?
}

# func grp.getgrpass <[str]grpname> => [str]
#
# Retorna a flag de sinalização de senha
#
grp.getgrpass()
{
	getopt.parse "grpname:str:+:$1"
	grp.___get_info "$1" pass
	return $?
}

# func grp.getgrall => [str]
#
# Retorna uma lista iterável com todos os grupos do sistema.
#
grp.getgrall()
{
	getopt.parse "-:null:-:$*"
	grp.___get_info '' all
	return $?
}

grp.___get_info()
{
	local group info fields
	declare -A entry
	
	if while read group; do
		entry[${group%%:*}]=${group//:/ }
	done < $__GRP_PATH 2>/dev/null; then
		
		if [[ $2 == all ]]; then 
			printf '%s\n' ${!entry[@]}
			return 0
		fi

		if [[ ${entry[$1]} ]]; then

			fields=(${entry[$1]})

			case $2 in
				pass) info=${fields[1]};;
				gid) info=${fields[2]};;
				users) info=${fields[@]:3}; info=${info//,/ };;
				*) return 1;;
			esac

			printf '%s\n' $info

		else
			error.__exit 'group' 'str' "$1" "$__GRP_ERR_GROUP_NOT_FOUND"
		fi	
	else
		error.__exit '' '' "$__GRP_PATH" "$__GRP_ERR_READ_GROUP_FILE"
	fi

	return $?
}
# /* __GRP_SH */
