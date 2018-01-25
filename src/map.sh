#!/bin/bash

#----------------------------------------------#
# Source:           map.sh
# Data:             22 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__MAP_SH ]] && return 0

readonly __MAP_SH=1

source builtin.sh

__SRC_TYPES[map.map]='
map.clone
map.copy
map.fromkeys
map.get
map.keys
map.items
map.list
map.remove
map.add
map.contains
map.pop
'

# func map.clear <[map]name>
#
# Limpa todos os elementos de 'name'.
#
function map.clear()
{
	getopt.parse 1 "name:map:+:$1" ${@:2}

	declare -n __map=$1
	local __key
	
	for __key in "${!__map[@]}"; do
		unset __map[$__key]
	done

	return 0
}

# func map.clone <[map]src> <[map]dest>
#
# Clona todos os elementos de 'src' para 'dest', sobrescrevendo todos
# os dados em 'dest'.
#
function map.clone()
{
	getopt.parse 2 "src:map:+:$1" "dest:map:+:$2" ${@:3}
	
	declare -n __map1=$1 __map2=$2
	local __key

	map.clear $2
	
	for __key in "${!__map1[@]}"; do
		__map2[$__key]=${__map1[$__key]}
	done	
	
	return 0
}

# func map.copy <[map]src> <[map]dest>
#
# Copia todos os elementos de 'src' para 'dest'. Sobrescreve
# somente as chaves duplicadas.
#
function map.copy()
{
	getopt.parse 2 "src:map:+:$1" "dest:map:+:$2" ${@:3}
	
	declare -n __map1=$1 __map2=$2
	local __key

	for __key in "${!__map1[@]}"; do
		__map2[$__key]=${__map1[$__key]}
	done	
	
	return 0
}

# func map.fromkeys <[map]name> <[str]key> ...
#
# Cria 'N' keys a partir da lista 'key ...'
#
function map.fromkeys()
{
	getopt.parse 1 "name:map:+:$1"

	declare -n __map=$1
	local __key

	for __key in "${@:2}"; do
		__map[$__key]=""
	done

	return 0
}

# func map.get <[map]name> <[str]key> => [object]
#
# Retorna o objeto armazenado em 'key'.
#
function map.get()
{
	getopt.parse 2 "name:map:+:$1" "key:str:+:$2" ${@:3}

	declare -n __map=$1
	echo "${__map[$2]}"
	return 0
}

# func map.keys <[map]name> => [key]
#
# Retorna uma lista iterável contendo as chaves de 'name'.
#
function map.keys()
{
	getopt.parse 1 "name:map:+:$1" ${@:2}
	
	declare -n __map=$1
	printf "%s\n" "${!__map[@]}"
	return 0
}

# func map.items <[map]name> => [object]
#
# Retorna uma lista iterável contendo os objetos de 'name'.
#
function map.items()
{
	getopt.parse 1 "name:map:+:$1" ${@:2}
	
	declare -n __map=$1
	printf "%s\n" "${__map[@]}"
	return 0
}

# func map.list <[map]name> => [key|object]
#
# Retorna uma lista iterável contendo os objetos em 'name' 
# representados por chave e objeto.
#
function map.list()
{
	getopt.parse 1 "name:map:+:$1" ${@:2}

	declare -n __map=$1
	local __key

	for __key in "${!__map[@]}"; do
		printf "%s|%s\n" "$__key" "${__map[$__key]}"
	done

	return 0
}

# func map.remove <[map]name> <[str]key>
#
# Remove o objeto armazenado em 'key'.
#
function map.remove()
{
	getopt.parse 2 "name:map:+:$1" "key:str:+:$2" ${@:3}
	
	declare -n __map=$1
	unset __map[$2]
	return 0	
}

# func map.add <[map]name> <[str]key> <[str]object>
#
# Adiciona 'object' em 'name' na chave 'key' especificada.
# Sobreescreve o item se 'key' já existir.
#
function map.add()
{
	getopt.parse 3 "name:map:+:$1" "key:str:+:$2" "object:str:-:$3" ${@:4}
	
	declare -n __map=$1
	__map[$2]=$3
	return 0
}

# func map.contains <[map]name> <[str]key> => [bool]
#
# Retorna 'true' se 'name' contém 'key'. Caso contrário 'false'.
#
function map.contains()
{
	getopt.parse 2 "name:map:+:$1" "key:str:+:$2" ${@:3}
	
	declare -n __map=$1
	local __key

	for __key in "${!__map[@]}"; do
		[[ $2 == $__key ]] && return 0
	done

	return 1
}

# func map.pop <[map]name> => [key|object]
#
# Retorna e remove o último elemento em 'name'.
# O objeto retornado é representado por chave e valor.
#
function map.pop()
{
	getopt.parse 1 "name:map:+:$1" ${@:2}
	
	declare -n __map=$1
	local __key

	for __key in "${!__map[@]}"; do :; done
	printf "%s|%s\n" "$__key" "${__map[$__key]}"
	unset __map[$__key]
	
	return 0
}

source.__INIT__
# /* __MAP_SH */
