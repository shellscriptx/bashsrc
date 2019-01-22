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

[ -v __MAP_SH__ ] && return 0

readonly __MAP_SH__=1

source builtin.sh

# .FUNCTION map.clone <src[map]> <dest[map]> -> [bool]
#
# Copia as chaves de origem para o map de destino apagando
# todos os dados já existentes.
#
function map.clone()
{
	getopt.parse 2 "src:map:$1" "dest:map:$2" "${@:3}"

	local -n __ref1__=$1 __ref2__=$2
	local __key__

	# Limpa o map.
	__ref2__=()

	for __key__ in "${!__ref1__[@]}"; do
		__ref2__[$__key__]=${__ref1__[$__key__]}
	done

	return $?
}

# .FUNCTION map.copy <src[map]> <dest[map]> -> [bool]
#
# Copia as chaves de origem para o map de destino sobrescrevendo
# as chaves já existentes.
#
function map.copy()
{
	getopt.parse 2 "src:map:$1" "dest:map:$2" "${@:3}"

	local -n __ref1__=$1 __ref2__=$2
	local __key__

	for __key__ in "${!__ref1__[@]}"; do
		__ref2__[$__key__]=${__ref1__[$__key__]}
	done

	return $?
}

# .FUNCTION map.fromkeys <obj[map]> <value[str]> <key[str]> ... -> [bool]
#
# Inicializa as chaves do container com o valor especificado.
# > Pode ser especificada mais de uma chave.
#
# == EXEMPLO ==
#
# source map.sh
#
# # Declarando o map
# declare -A m1=()
#
# map.fromkeys m1 '10' nome sobrenome idade
#
# # Listando chaves.
# for key in "${!m1[@]}"; do
#     echo "m1[$key]=${m1[$key]}
# done
#
# == SAÍDA ==
#
# m1[nome]=10
# m1[idade]=10
# m1[sobrenome]=10
#
function map.fromkeys()
{
	getopt.parse -1 "obj:map:$1" "value:str:$2" "key:str:$3" ... "${@:3}"

	local -n __ref__=$1
	local __key__

	for __key__  in "${@:3}"; do
		__ref__[$__key__]=$2
	done
	return $?
}

# .FUNCTION map.get <obj[map]> <key[str]> -> [str]|[bool]
#
# Retorna o valor da chave.
#
function map.get()
{
	getopt.parse 2 "obj:map:$1" "key:str:$2" "${@:3}"

	local -n __ref__=$1
	echo "${__ref__[$2]}"
	return $?
}

# .FUNCTION map.keys <obj[map]> -> [str]|[bool]
#
# Retorna todas as chaves do container.
#
function map.keys()
{
	getopt.parse 1 "obj:map:$1" "${@:2}"

	local -n __ref__=$1
	printf '%s\n' "${!__ref__[@]}"
	return $?
}

# .FUNCTION map.sortkeys <obj[map]> -> [str]|[bool]
#
# Retorna todas as chaves em ordem alfabética.
#
function map.sortkeys()
{
	getopt.parse 1 "obj:map:$1" "${@:2}"

	local -n __ref__=$1
	printf '%s\n' "${!__ref__[@]}" | sort -d
	return $?
}

# .FUNCTION map.items <obj[map]> -> [str]|[bool]
#
# Retorna o valores do container.
#
function map.items()
{
	getopt.parse 1 "obj:map:$1" "${@:2}"

	local -n __ref__=$1
	printf '%s\n' "${__ref__[@]}"
	return $?
}

# .FUNCTION map.list <obj[map]> -> [str|str]|[bool]
#
# Retorna uma lista iterável que é representação dos elementos
# no container no seguinte formato:
#
# key|value
#
function map.list()
{
	getopt.parse 1 "obj:map:$1" "${@:2}"

	local -n __ref__=$1
	local __key__

	for __key__ in "${!__ref__[@]}"; do
		printf '%s|%s\n' "$__key__" "${__ref__[$__key__]}"
	done
	return $?
}

# .FUNCTION map.remove <obj[map]> <key[str]> -> [bool]
#
# Remove a chave do container.
#
function map.remove()
{
	getopt.parse 2 "obj:map:$1" "key:str:$2" "${@:3}"

	unset $1[$2]
	return $?
}

# .FUNCTION map.add <obj[map]> <key[str]> <value[str]> -> [bool]
#
# Adiciona uma nova chave ao container.
#
# == EXEMPLO ==
#
# source map.sh
#
# # Declarando o tipo map
# declare -A usuario=()
#
# # Atribuindo chave/valor
# map.add usuario 'nome' 'Juliano'
# map.add usuario 'sobrenome' 'Santos'
# map.add usuario 'idade' '35'
#
# echo "${usuario[nome]}"
# echo "${usuario[sobrenome]}"
# echo "${usuario[idade]}"
#
# == SAÍDA ==
#
# Juliano
# Santos
# 35
#
function map.add()
{
	getopt.parse 3 "obj:map:$1" "key:str:$2" "value:str:$3" "${@:4}"

	local -n __ref__=$1
	__ref__[$2]=$3
	return $?
}

# .FUNCTION map.contains <obj[map]> <key[str]> -> [bool]
#
# Retorna 'true' se contém a chave especificada, caso contrário 'false'.
#
function map.contains()
{
	getopt.parse 2 "obj:map:$1" "key:str:$2" "${@:3}"
	
	[[ -v $1[$2] ]]
	return $?
}

# .FUNCTION map.pop <obj[map]> <key[str]> -> [str]|[bool]
#
# Retorna e remove do container a chave especificada.
#
function map.pop()
{
	getopt.parse 2 "obj:map:$1" "key:str:$2" "${@:3}"

	local -n __ref__=$1	
	echo "${__ref__[$2]}"
	unset $1[$2]
	return $?
}

# .TYPE map_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.clone
# S.copy
# S.fromkeys
# S.get
# S.keys
# S.items
# S.list
# S.remove
# S.add
# S.contains
# S.pop
#
typedef map_t		\
		map.clone		\
		map.copy		\
		map.fromkeys	\
		map.get			\
		map.keys		\
		map.sortkeys	\
		map.items		\
		map.list		\
		map.remove		\
		map.add			\
		map.contains	\
		map.pop

# Funções (somente leitura)
readonly -f	map.clone		\
			map.copy		\
			map.fromkeys	\
			map.get			\
			map.keys		\
			map.sortkeys	\
			map.items		\
			map.list		\
			map.remove		\
			map.add			\
			map.contains	\
			map.pop

# /* __MAP_SH__ */
