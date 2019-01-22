#!/bin/bash

#----------------------------------------------#
# Source:           user.sh
# Data:             15 de outubro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

#* source: user.sh
#*
#* Tipos:
#*
#* [user] => .groups
#*           .gids
#*           .id
#*

[[ $__USER_SH ]] && return 0

readonly __USER_SH=1

source builtin.sh

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
	local filedb=/etc/group
	
	if [ -r "$filedb" ]; then	
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
		done < $filedb
	else
		error.__exit '' '' '' "'$filedb' não foi possível ler o arquivo base"
	fi

	[[ $info ]] && printf '%s\n' "${info[@]}"

	return $?
}

# /* __USER_SH */
