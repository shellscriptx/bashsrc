#!/bin/bash

#----------------------------------------------#
# Source:           user.sh
# Data:             15 de outubro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

# * tipos/implementação:
# *
# *  user
# *      .groups
# *      .gids
# *      .id
# *
[[ $__USER_SH ]] && return 0

readonly __USER_SH=1

source builtin.sh

readonly __USER_ERR_READ_BASE_FILE='não foi possível ler o arquivo base'
readonly __USER_GROUP=/etc/group

# func user.getgrall => [str]
#
# Retorna uma lista iterável com o nome de todos os grupos do sistema.
#
function user.getgrall()
{
	getopt.parse "-:null:-:$*"
	
	local grp IFSbkp m

	if [ -r "$__USER_GROUP" ]; then
		IFSbkp=$IFS
		IFS=':'; while read grp _ _ _; do
			echo "$grp"
		done < $__USER_GROUP
		IFS=$IFSbkp
	else
		error.__exit '' '' '' "'$__USER_GROUP' $__USER_ERR_READ_BASE_FILE"
	fi

	return $?
}

function user.groups()
{
	getopt.parse "username:str:+:$1"
	user.__get_info groups "$1"
	return $?
}

function user.gids()
{
	getopt.parse "username:str:+:$1"
	user.__get_info gids "$1"
	return $?
}

function user.id()
{
	getopt.parse "username:str:+:$1"
	user.__get_info id "$1"
	return $?	
}

function user.getname()
{
	getopt.parse "uid:uint:+:$1"
	user.__get_info user $1
	return $?
}

function user.current()
{
	getopt.parse "-:null:-:$*"
	user.__get_info user $UID
	return $?	
}

function user.__get_info()
{
	local tmp id line info users
	local flag=$1 user=$2
	
	if [ -r "$__USER_GROUP" ]; then	
		while read line; do
			case $flag in
				id) 	if [[ "$user" == "${line%%:*}" ]]; then
							info=${line%:*}; info=${info##*:}
							break
						fi
						;;
				groups)	users=${line##*:}; users=${users//,/|}
						if [[ $user =~ ^($users)$ ]]; then
							info=($user ${info[@]:1} ${line%%:*})
						fi
						;;
				gids)	users=${line##*:}; users=${users//,/|}
						tmp=${line%:*}; tmp=${tmp##*:}
						if [[ "$user" == "${line%%:*}" ]]; then
							info=($tmp ${info[@]})
						elif [[ $user =~ ^($users)$ ]]; then
							info+=($tmp)
						fi
						;;
				user)	id=${line%:*}; id=${id##*:}
						if [[ "$2" == "$id" ]]; then
							info=${line%%:*}
							break
						fi
						;;
			esac
		done < $__USER_GROUP
	else
		error.__exit '' '' '' "'$__USER_GROUP' $__USER_ERR_READ_BASE_FILE"
	fi

	[[ $info ]] && printf '%s\n' "${info[@]}"

	return $?
}

# /* __USER_SH */
