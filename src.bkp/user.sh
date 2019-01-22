#!/bin/bash

[[ $__USER_SH ]] && return 0

readonly __USER_SH=1

source builtin.sh

readonly __USER_PATH_PASSWD='/etc/passwd'
readonly __USER_ERR_READ_PASS_FILE='falha ao ler o arquivo base'
readonly __USER_ERR_USER_NOT_FOUND='usuário não encontrado'

# type user
#
# Implementa 'S' com os métodos:
#
# S.pass => [str]
# S.uid => [uint]
# S.gid => [uint]
# S.gecos => [str]
# S.home => [str]
# S.shell => [str]
#

# func user.pass <[str]username> => [str]
#
# Retorna a senha criptografada ou asteriscos de 'username'.
#
function user.pass()
{
	getopt.parse "username:str:+:$1"
	user.__get_info "$1" pass
	return $?
}

# func user.uid <[str]username> = [uint]
#
# Retorna a identificação numérica de 'username'.
#
function user.uid()
{
	getopt.parse "username:str:+:$1"
	user.__get_info "$1" uid
	return $?
}

# func user.gid <[str]username> => [uint]
#
# Retorna a identificação do grupo primário de 'username'.
#
function user.gid()
{
	getopt.parse "username:str:+:$1"
	user.__get_info "$1" gid
	return $?
}

# func user.gecos <[str]username> => [str]
#
# Retorna as informações complementares de 'username'.
#
function user.gecos()
{
	getopt.parse "username:str:+:$1"
	user.__get_info "$1" gecos
	return $?
}

# func user.home <[str]username> => [str]
#
# Retorna o diretório pessoal de 'username'. ($HOME)
#
function user.home()
{
	getopt.parse "username:str:+:$1"
	user.__get_info "$1" home
	return $?
}

# func user.shell <[str]username> => [str]
#
# Retorna o interpretador de comando usado por 'username'.
#
function user.shell()
{
	getopt.parse "username:str:+:$1"
	user.__get_info "$1" shell
	return $?
}

# func user.getallusers => [str]
#
# Retorna uma lista iterável com todos os usuários do sistema.
#
function user.getallusers
{
	getopt.parse "-:null:-:$*"
	user.__get_info '' all
	return $?
}

# func user.getuser <[uint]uid> => [str]
#
# Retorna o usuário associado a identificação 'uid'.
#
function user.getuser()
{
	getopt.parse "uid:uint:+:$1"
	
	local username
	while read username; do
		[[ $(user.__get_info "$username" uid) -eq $1 ]] && echo "$username" && break
	done < <(user.__get_info '' all)
	return $?
}

user.__get_info()
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
			error.__exit 'user' 'str' "$1" "$__USER_ERR_USER_NOT_FOUND"
		fi	
	else
		error.__exit '' '' "$__USER_PATH_PASSWD" "$__USER_ERR_READ_PASS_FILE"
	fi

	return $?
}

# /* __USER_SH */
