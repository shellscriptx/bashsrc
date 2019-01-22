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

[ -v __RAND_SH__ ] && return 0

readonly __RAND_SH__=1

source builtin.sh

# .FUNCTION rand.random -> [uint]|[bool]
#
# Gera um inteiro pseudo-aleatório entre 0 e 32767.
#
function rand.random()
{
	getopt.parse 0 "$@"
	echo $RANDOM
	return $?
}

# .FUNCTION rand.range <min[int]> <max[int]> -> [int]|[bool]
#
# Retorna um número inteiro pseudo-aleatório
# dentro do intervalo especificado.
#
function rand.range()
{
	getopt.parse 2 "min:int:$1" "max:int:$2" "${@:3}"
	
	shuf -i $1-$2 -n1	
	return $?
}

# .FUNCTION rand.choice <list[array]> -> [str]|[bool]
#
# Escolhe um elemento aleatório de uma sequência.
#
function rand.choice()
{
	getopt.parse 1 "list:array:$1" "${@:2}"
	
	local -n __ref__=$1
	local __list__
	
	[[ ${__ref__[@]} ]]											&&	
	__list__=("${__ref__[@]}")									&&
	echo "${__list__[$(shuf -i 0-$((${#__list__[@]}-1)) -n1)]}"

	return $?
}

# .FUNCTION rand.shuffle <list[array]> -> [bool]
#
# Embaralha os elementos da lista.
#
function rand.shuffle()
{
	getopt.parse 1 "list:array:$1" "${@:2}"

	local -n __ref__=$1
	mapfile $1 < <(printf '%s\n' "${__ref__[@]}" | shuf)	
	return $?
}

# .TYPE rand_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.choice
# S.shuffle
#
typedef rand_t	rand.choice \
				rand.shuffle

# Funções (somente-leitura)
readonly -f rand.random	\
			rand.range	\
			rand.choice	\
			rand.shuffle

# /* __RAND_SH__ */
