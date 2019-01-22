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

[ -v __ERROR_SH__ ] && return 0

readonly __ERROR_SH__=1

source builtin.sh

# .FUNCTION error.fatal <error[str]> -> [str]|[bool]
#
# Retorna uma mensagem de erro e finaliza o script com status '1'.
#
function error.fatal()
{
	getopt.parse 1 "error:str:$1" "${@:2}"

	echo "erro: linha ${BASH_LINENO[-2]:--}: ${FUNCNAME[-2]:--}: ${1:-fatal}" 1>&2
	exit 1
}

# .FUNCTION error.fatalf <fmt[str]> <args[str]> ... -> [str]|[bool]
function error.fatalf()
{
	getopt.parse -1 "fmt:str:$1" "args:str:$2" ... "${@:3}"
	
	printf "erro: linha %d: %s: ${1:-fatal}"	\
			"${BASH_LINENO[-2]:--}"				\
			"${FUNCNAME[-2]:--}"				\
			"${@:2}"							1>&2

	exit 1
}

# .FUNCTION error.error <error[str]> -> [str]|[bool]
function error.error()
{
	getopt.parse 1 "error:str:$1" "${@:2}"

	echo "${FUNCNAME[-2]:--}: ${1:-error}" 1>&2
	return 1
}

# .FUNCTION error.errorf <fmt[str]> <args[str]> ... -> [str]|[bool]
function error.errorf()
{
	getopt.parse -1 "fmt:str:$1" "args:str:$2" ... "${@:3}"
	
	printf "${FUNCNAME[-2]:--}: ${1:-error}" "${@:2}" 1>&2
	return 1
}

# .FUNCTION error.warn <error[str]> -> [str]|[bool]
function error.warn()
{
	getopt.parse 1 "error:str:$1" "${@:2}"

	echo -e "\e[0;31m${FUNCNAME[-2]:--}: ${1:-warn}\e[0;m" 1>&2
	return 1
}

# .FUNCTION error.warnf <fmt[str]> <args[str]> ... -> [str]|[bool]
function error.warnf()
{
	getopt.parse -1 "error:str:$1" "args:str:$2" ... "${@:3}"

	printf "\e[0;31m${FUNCNAME[-2]:--}: ${1:-warn}\e[0;m" "${@:2}" 1>&2
	return 1
}

# .TYPE error_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.fatal
# S.fatalf
# S.error
# S.errorf
# S.warn
# S.warnf
#
typedef error_t	\
		error.fatal		\
		error.fatalf	\
		error.error 	\
		error.errorf	\
		error.warn		\
		error.warnf

readonly -f error.fatal		\
			error.fatalf	\
			error.error 	\
			error.errorf	\
			error.warn		\
			error.warnf

# /* __ERROR_SH__ */
