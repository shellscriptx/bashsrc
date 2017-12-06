#!/bin/bash

#----------------------------------------------#
# Source:           os.sh
# Data:             29 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__OS_SH ]] && return 0

readonly __OS_SH=1

source builtin.sh

# errors
readonly __OS_ERR_DIR_NOT_FOUND='diretório não encontrado'
readonly __OS_ERR_DIR_ACCESS_DENIED='permissão negada'
readonly __OS_ERR_NOT_DIR='não é um diretório'

# constantes
readonly stdin=/dev/stdin
readonly stdout=/dev/stdout
readonly stderr=/dev/stderr

# func os.chdir <[str]dir>
#
# Altera o diretório atual para 'dir'
#
function os.chdir()
{
	getopt.parse "dir:str:+:$1"
	
	local dir=$1
	
	if [ -f "$dir" ]; then
		error.__exit 'dir' 'str' "$dir" "$__OS_ERR_NOT_DIR"
	elif [ ! -d "$dir" ]; then
		error.__exit 'dir' 'str' "$dir" "$__OS_ERR_DIR_NOT_FOUND"
	elif [ ! -r "$dir" ]; then
		error.__exit 'dir' 'str' "$dir" "$__OS_ERR_DIR_ACCESS_DENIED"
	fi
	
	cd "$dir"

	return 0
}

# func os.stackdir <[var]stack> <[str]dir>
#
# Anexa em 'stack' o diretório especificado
#
function os.stackdir()
{
	getopt.parse "stack:array:+:$1" "dir:str:+:$1"

	declare -n __stack_dir=$1
	local __dir=$2
	
	[ ! -d "$__dir" ] && error.__exit 'dir' 'str' "$__dir" "$__OS_ERR_DIR_NOT_FOUND"
	__stack_dir+=("$__dir")
	
	return 0
}

# func os.exists <[str]filepath> => [bool]
#
# Verifica se o arquivo ou diretório em 'filepath' existe. Retorna 'true'
# se existe, caso contrário 'false'
#
function os.exists()
{
	getopt.parse "filepath:str:+:$1"
	[[ -e "$1" ]]
	return $?
}

# func os.environ => [str]
#
# Retorna uma lista iterável de variáveis de ambiente.
#
function os.environ()
{
	getopt.parse "-:null:-:$*"

	while read _ _ env; do
		echo "${env%%=*}"
	done < <(declare -xp)
	
	return 0
}
