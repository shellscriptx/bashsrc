#!/bin/bash

#----------------------------------------------#
# Source:           user.sh
# Data:             15 de outubro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__USER_SH ]] && return 0

readonly __USER_SH=1

source builtin.sh

readonly __USER_GROUP=/etc/group

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

function user.current()
{
	getopt.parse "-:null:-:$*"
	user.__get_info user $UID
	return $?	
}

function user.__get_info()
{
	local match tmp id line info
	local flag=$1 user=$2
	
	if [ -r "$__USER_GROUP" ]; then	
		while read line; do
			case $flag in
				id) 	if [[ "$user" == "${line%%:*}" ]]; then
							info=${line%:*}; info=${info##*:}
							match=1
							break
						fi
						;;
				groups)	users=${line##*:}; users=${users//,/|}
						if [[ $user =~ ^($users)$ ]]; then
							info=($user ${info[@]:1} ${line%%:*})
							match=1
						fi
						;;
				gids)	users=${line##*:}; users=${users//,/|}
						tmp=${line%:*}; tmp=${tmp##*:}
						if [[ "$user" == "${line%%:*}" ]]; then
							info=($tmp ${info[@]}); match=1
						elif [[ $user =~ ^($users)$ ]]; then
							info+=($tmp); match=1
						fi
						;;
				user)	id=${line%:*}; id=${id##*:}
						if [[ "$2" == "$id" ]]; then
							info=${line%%:*}; match=1
							break
						fi
						;;
			esac
		done < $__USER_GROUP
	else
		error.__exit '' '' '' "'$__USER_GROUP' não foi possível ler o arquivo base"
	fi
		
	[ "$match" ] && echo "${info[@]}"

	return $?
}

# /* __USER_SH */
