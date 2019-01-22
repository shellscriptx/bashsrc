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

[ -v __PATH_SH__ ] && return 0

readonly __PATH_SH__=1

source builtin.sh

# .FUNCTION path.stat <path[str]> <stat[map]> -> [bool]
#
# Obtém informações do arquivo.
#
function path.stat()
{
	getopt.parse 2 "pathname:str:$1" "stat:map:$2" "${@:3}"
	
	local __stat__
	local -n __ref__=$2

	__ref__=() || return 1

	[[ ! -r "$1" ]] && { error.error "'$1' não foi possível ler o arquivo"; return $?; }
	
	IFS='|' read -a __stat__ < <(stat -c '%d|%i|%a|%h|%u|%g|%s|%X|%Y|%Z' "$1")
	
	__ref__[st_dev]=${__stat__[0]}
	__ref__[st_ino]=${__stat__[1]}
	__ref__[st_mode]=${__stat__[2]}
	__ref__[st_nlink]=${__stat__[3]}
	__ref__[st_uid]=${__stat__[4]}
	__ref__[st_gid]=${__stat__[5]}
	__ref__[st_size]=${__stat__[6]}
	__ref__[st_atime]=${__stat__[7]}
	__ref__[st_mtime]=${__stat__[8]}
	__ref__[st_ctime]=${__stat__[9]}
	
	return $?	
}

# .FUNCTION path.glob <path[str]> -> [str]|[bool]
#
function path.glob()
{
	getopt.parse 1 "path:str:$1" "${@:2}"

	local path

	IFS=$'\t' read path _ < <(path.split "$1")
	printf '%s\n' "$path"${1##*/}
	
	return $?
}

# .FUNCTION path.scandir <path[str]> -> [str]|[bool]
#
# Retorna os arquivos contidos no caminho.
#
function path.scandir()
{
	getopt.parse 1 "path:str:$1" "${@:2}"

	local path
	
	if [[ ! -d "$1" ]]; then
		error.error "'$1' não é um diretório"
		return  $?
	elif [[ ! -x "$1" ]]; then
		error.error "'$1' permissão negada"
		return $?
	fi

	printf '%s\n' "${1%/}/".* "${1%/}/"*

	return $?
}

# .FUNCTION path.walk <path[str]> -> [str]|[bool]
#
# Retorna os arquivos contidos no diretório e sub-diretórios.
#
function path.walk()
{
	getopt.parse 1 "path:str:$1" "${@:2}"
	
	local path
	
	if [[ ! -d "$1" ]]; then
		error.error "'$1' não é um diretório"
		return $?
	elif [[ ! -x "$1" ]]; then
		error.error "'$1' permissão negada"
		return $?
	fi
	
	for path in "${1%/}/"* "${1%/}/".*; do
		path=${path%\/\*}
		[[ $1 == $path || ${path##*/} == @(.|..) ]] && continue
		echo "$path"
		[[ -d $path ]] && path.walk "$path"
	done

	return $?
}

# .FUNCTION path.fnwalk <path[str]> <func[function]> -> [str]|[bool]
#
# Escaneia os arquivos contidos no diretório e sub-diretórios, aplicando a 
# função filtro a cada iteração e retorna o caminho do arquivo somente se 
# o retorno da função for 'true'.
#
# == EXEMPLO ==
#
# source path.sh
#
# # Somente arquivos com extensão: '.conf' e '.desktop'
# filtro()
# {
#     [[ $1 =~ \.(conf|desktop)$ ]]
#     return $?
# }
#
# path.fnwalk '/etc' filtro
#
# == SAÍDA ==
#
# /etc/udev/udev.conf
# /etc/ufw/sysctl.conf
# /etc/ufw/ufw.conf
# /etc/xdg/autostart/gnome-keyring-pkcs11.desktop
# /etc/xdg/autostart/gnome-keyring-secrets.desktop
# /etc/xdg/autostart/gnome-keyring-ssh.desktop
# /etc/xdg/autostart/gnome-screensaver.desktop
# ...
#
function path.fnwalk()
{
	getopt.parse 2 "path:str:$1" "func:function:$2" "${@:3}"
	
	local path
	
	if [[ ! -d "$1" ]]; then
		error.error "'$1' não é um diretório"
		return $?
	elif [[ ! -x "$1" ]]; then
		error.error "'$1' permissão negada"
		return $?
	fi
	
	for path in "${1%/}/"* "${1%/}/".*; do
		path=${path%\/\*}
		[[ $1 == $path || ${path##*/} == @(.|..) ]] && continue
		"$2" "$path" && echo "$path"
		[[ -d $path ]] && path.fnwalk "$path" "$2"
	done

	return $?
}

# .FUNCTION path.ext <path[str]> -> [str]|[bool]
#
# Retorna a extensão do arquivo.
#
function path.ext()
{
	getopt.parse 1 "path:str:$1" "${@:2}"

	local ext
	IFS='.' read _ ext <<< ${1##*/}
	echo "${ext:+.$ext}"

	return $?	
}

# .FUNCTION path.split <path[str]> -> [str]|[bool]
#
# Divide o caminho imediatamente após o separador final, 
# separando-o em um diretório e um componente de nome de arquivo.
#
function path.split()
{
	getopt.parse 1 "path:str:$1" "${@:2}"

	local split path file

	IFS='/' read -a split <<< "$1"

	case ${#split[@]} in
		0);;
		1) file=$1;;
		*) path=${1%/*}; file=${1##*/}		
	esac

	printf '%s\n%s\n' "$path" "$file"

	return $?
}

# .FUNCTION path.basename <path[str]> -> [str]|[bool]
#
# Retorna o componente final de um nome de caminho.
#
function path.basename()
{
	getopt.parse 1 "path:str:$1" "${@:2}"
	
	echo "${1##*/}"
	return $?
}

# .FUNCTION path.dirname <path[str]> -> [str]|[bool]
#
# Retorna o componente de diretório de um nome de caminho.
#
function path.dirname()
{
	local dir
	IFS=$'\t' read dir _ < <(path.split "$1")
	echo "$dir"
	return $?
}

# .FUNCTION path.join <elem[str]> -> [str]|[bool]
#
# Junte dois ou mais componentes de nome de caminho, 
# inserindo '/' conforme necessário.
#
function path.join()
{
	getopt.parse -1 "elem:str:$1" ... "${@:2}"
	
	printf '%s/' "$@"; echo
	return $?
}

# .MAP stat
#
# Chaves:
#
# st_dev
# st_ino
# st_mode
# st_nlink
# st_uid
# st_gid
# st_size
# st_atime
# st_mtime
# st_ctime
#

# .TYPE path_t
#
# Implementa o objeto 'S" com os métodos:
#
# S.stat
# S.glob
# S.scandir
# S.walk
# S.fnwalk
# S.ext
# S.split
# S.basename
#
typedef path_t 	path.stat		\
				path.glob		\
				path.scandir	\
				path.walk		\
				path.fnwalk		\
				path.ext		\
				path.split		\
				path.basename	\
				path.dirname

# Função (somente leitura)
readonly -f path.stat		\
			path.glob		\
			path.scandir	\
			path.walk		\
			path.fnwalk		\
			path.ext		\
			path.split		\
			path.basename	\
			path.join		\
			path.dirname

# /* __PATH_SH__ */
