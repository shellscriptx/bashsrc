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
#

[ -v __LOG_SH__ ] && return 0

readonly __LOG_SH__=1

# .FUNCTION log.open <file[str]> <fmt[str]> <args[str]> ... -> [bool]
#
# Grava no arquivo o log com o formato e argumentos especificados.
#
function log.open()
{
	getopt.parse -1 "file:str:$1" "fmt:str:$2" "args:str:$3" ... "${@:4}"
	
	local fmt

	if [ -d "$1" ]; then
		error.fatalf "'%s' é um diretório\n" "$1"
	elif [ -e "$1" -a ! -w "$1" ]; then
		error.fatalf "'%s' permissão negada\n" "$1"
	fi

	printf -v fmt  '%s: %(%d/%m/%Y %H:%M:%S)T' "${0##*/}"
	printf "%s: $2\n" "$fmt" "${@:3}" >> "${1:-/dev/null}" 2>/dev/null ||
	error.errorf "'%s' formato inválido\n" "$2"
	
	return $?
}

# .FUNCTION log.new <log[log_t]> <file[str]> <fmt[str]> -> [bool]
#
# Cria e define as configurações do objeto log.
#
function log.new()
{
	getopt.parse 3 "log:log_t:$1" "file:str:$2" "fmt:str:$3" "${@:4}"

	printf  -v $1 '%s|%s' "${@:2}"
	return $?	
}

# .FUNCTION log.write <log[log_t]> <args[str]> -> [bool]
#
# Grava as informações no log.
#
function log.write()
{
	getopt.parse -1 "log:log_t:$1" "args:str:$2" ... "${@:3}"

	local __opts__
	IFS='|' read -ra __opts__ <<< "${!1}"
	log.open "${__opts__[@]}" "${@:2}"
	return $?
}

# .TYPE log_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.new
# S.write
#
typedef log_t 	log.new \
				log.write

# Funções (somente-leitura)
readonly -f log.open 	\
			log.new		\
			log.write
# /* __LOG_SH__ */	
