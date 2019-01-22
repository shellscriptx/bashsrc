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

[ -v __USER_SH__ ] && return 0

readonly __USER_SH__=1

source builtin.sh

# .FUNCTION user.getuid -> [uint]|[bool]
#
# Retorna o id do usuário atual.
#
function user.getuid()
{
	getopt.parse 0 "$@"
	
	echo $UID
	return $?
}

# .FUNCTION user.geteuid -> [uint]|[bool]
#
# Retorna o id efetivo do usuário atual.
#
function user.geteuid()
{
	getopt.parse 0 "$@"
	
	echo $EUID
	return $?
}

# .FUNCTION user.getpwall -> [uint]|[bool]
#
# Retorna todos os usuários do sistema.
#
function user.getpwall
{
	getopt.parse 0 "$@"

	local user

	while IFS=':' read user _; do
		echo $user
	done < /etc/passwd

	return $?
}

# .FUNCTION user.getpwnam <name[str]> <pwd[map]> -> [bool]
#
# Obtem informações do usuário.
#
# == EXEMPLO ==
#
# source user.sh
#
# # Mapa
# declare -A info=()
#
# user.getpwname 'colord' info
#
# echo ${info[pw_uid]}
# echo ${info[pw_name]}
# echo ${info[pw_dir]}
# echo ${info[pw_gecos]}
#
# == SAÍDA ==
#
# 113
# colord
# /var/lib/colord
# colord colour management daemon,,,
#
function user.getpwnam()
{
	getopt.parse 2 "name:str:$1" "pwd:map:$2" "${@:3}"
	
	local __name__ __passwd__ __uid__ __gid__ 
	local __gecos__ __dir__ __shell__
	local -n __ref__=$2
	
	__ref__=() || return 1
	
	while IFS=':' read	__name__	\
						__passwd__	\
						__uid__		\
						__gid__		\
						__gecos__	\
						__dir__		\
						__shell__; do
		[[ $1 == $__name__ ]] && break
	done < /etc/passwd

	(($?)) && { error.error "'$1' usuário não encontrado"; return $?; }

	__ref__[pw_name]=$__name__
	__ref__[pw_passwd]=$__passwd__
	__ref__[pw_uid]=$__uid__
	__ref__[pw_gid]=$__gid__
	__ref__[pw_gecos]=$__gecos__
	__ref__[pw_dir]=$__dir__
	__ref__[pw_shell]=$__shell__

	return $?
}

# .FUNCTION user.getpwuid <uid[uint]> <pwd[map]> -> [bool]
#
# Obtém informações do uid especificado.
#
# Inicializa o mapa 'S' com as chaves:
#
# S[pw_name]
# S[pw_passwd]
# S[pw_uid]
# S[pw_gid]
# S[pw_gecos]
# S[pw_dir]
# S[pw_shell]
#
function user.getpwuid()
{
	getopt.parse 2 "uid:uint:$1" "pwd:map:$2" "${@:3}"
	
	local __name__ __passwd__ __uid__ __gid__
	local __gecos__ __dir__ __shell__
	local -n __ref__=$2

	__ref__=() || return 1
	
	while IFS=':' read 	__name__	\
						__passwd__	\
						__uid__		\
						__gid__		\
						__gecos__	\
						__dir__		\
						__shell__; do
		[[ $1 == $__uid__ ]] && break
	done < /etc/passwd

	(($?)) && { error.error "'$1' id não encontrado"; return $?; }

	__ref__[pw_name]=$__name__
	__ref__[pw_passwd]=$__passwd__
	__ref__[pw_uid]=$__uid__
	__ref__[pw_gid]=$__gid__
	__ref__[pw_gecos]=$__gecos__
	__ref__[pw_dir]=$__dir__
	__ref__[pw_shell]=$__shell__

	return $?
}

# .MAP pwd
#
# Chaves:
#
# pw_name      /* Nome do usuário do sistema */
# pw_passwd    /* Senha criptografada ou asteriscos. */
# pw_uid       /* Identificação númerica do usuário */
# pw_gid       /* Identificação númerica do grupo primário */
# pw_gecos     /* Informações do usuário (opcional) */
# pw_dir       /* Diretório do usuário ($HOME). */
# pw_shell     /* Interpretador de comandos */
#

# Funções (somente leitura)
readonly -f	user.getuid		\
			user.geteuid	\
			user.getpwall	\
			user.getpwnam	\
			user.getpwuid

# /* __USER_SH__ */
