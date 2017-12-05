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

# func os.chdir <[str]dir>
#
# Altera o diretório atual para 'dirname'.
#
os.chdir()
{
	getopt.parse "dir:str:+:$1"
	
	local dir=$1

	if [ ! -d "$dir" ]; then
		error.__exit "dir" "str" "$dir" "$__OS_ERR_DIR_NOT_FOUND"
	elif [ ! -r "$dir" ]; then
		error.__exit "dir" "str" "$dir" "$__OS_ERR_DIR_ACCESS_DENIED"
	fi
	
	cd "$dir"

	return 0
}
