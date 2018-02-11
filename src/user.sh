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

[[ $__USER_SH ]] && return 0

readonly __USER_SH=1

source builtin.sh

__TYPE__[user_t]='
user.pass
user.uid
user.gid
user.gecos
user.home
user.shell
'

readonly __USER_PATH_PASSWD='/etc/passwd'
readonly __ERR_USER_READ_PASS_FILE='falha ao ler o arquivo base'
readonly __ERR_USER_USER_NOT_FOUND='usuário não encontrado'

# func user.pass <[str]username> => [str]
#
# Retorna a senha criptografada ou asteriscos de 'username'.
#
function user.pass()
{
	getopt.parse 1 "username:str:+:$1" ${@:2}
	user.__get_info "$1" pass
	return $?
}

# func user.uid <[str]username> = [uint]
#
# Retorna a identificação numérica de 'username'.
#
function user.uid()
{
	getopt.parse 1 "username:str:+:$1" ${@:2}
	user.__get_info "$1" uid
	return $?
}

# func user.gid <[str]username> => [uint]
#
# Retorna a identificação do grupo primário de 'username'.
#
function user.gid()
{
	getopt.parse 1 "username:str:+:$1" ${@:2}
	user.__get_info "$1" gid
	return $?
}

# func user.gecos <[str]username> => [str]
#
# Retorna as informações complementares de 'username'.
#
function user.gecos()
{
	getopt.parse 1 "username:str:+:$1" ${@:2}
	user.__get_info "$1" gecos
	return $?
}

# func user.home <[str]username> => [str]
#
# Retorna o diretório pessoal de 'username'. ($HOME)
#
function user.home()
{
	getopt.parse 1 "username:str:+:$1" ${@:2}
	user.__get_info "$1" home
	return $?
}

# func user.shell <[str]username> => [str]
#
# Retorna o interpretador de comando usado por 'username'.
#
function user.shell()
{
	getopt.parse 1 "username:str:+:$1" ${@:2}
	user.__get_info "$1" shell
	return $?
}

# func user.getallusers => [str]
#
# Retorna uma lista iterável com todos os usuários do sistema.
#
function user.getallusers
{
	getopt.parse 0 ${@:1}
	user.__get_info '' all
	return $?
}

# func user.getuser <[uint]uid> => [str]
#
# Retorna o usuário associado a identificação 'uid'.
#
function user.getuser()
{
	getopt.parse 1 "uid:uint:+:$1" ${@:2}
	
	local username
	while read username; do
		[[ $(user.__get_info "$username" uid) -eq $1 ]] && echo "$username" && break
	done < <(user.__get_info '' all)
	return $?
}

function user.__get_info()
{
	local account info fields flag=$2
	declare -A entry
	
	if while read account; do
		entry[${account%%:*}]=${account//:/ }
	done < $__USER_PATH_PASSWD 2>/dev/null; then

		if [[ $flag == all ]] ; then
			printf '%s\n' ${!entry[@]}
		elif [[ ${entry[$1]} ]]; then
		
			fields=(${entry[$1]})

			case $flag in
				pass) info=${fields[1]};;
				uid) info=${fields[2]};;
				gid) info=${fields[3]};;
				gecos) info=${fields[@]:4}; info=${info%%/*};;
				home) info=${fields[-2]};;
				shell) info=${fields[-1]};;
				*) return 1;;
			esac
			
			printf '%s\n' "$info"
		else
			error.trace def 'user' 'str' "$1" "$__ERR_USER_USER_NOT_FOUND"; return $?
		fi	
	else
		error.trace def '' '' "$__USER_PATH_PASSWD" "$__ERR_USER_READ_PASS_FILE"; return $?
	fi

	return $?
}

source.__INIT__
# /* __USER_SH */
