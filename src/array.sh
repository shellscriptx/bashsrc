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

[ -v __ARRAY_SH__ ] && return 0

readonly __ARRAY_SH__=1

source builtin.sh

# .FUNCTION array.len <obj[array]> -> [uint]|[bool]
#
# Retorna o total de elementos contidos no array.
#
function array.len()
{
	getopt.parse 1 "obj:array:$1" "${@:2}"
	
	local -n __ref__=$1
	echo ${#__ref__[@]}
	return $?
}

# .FUNCTION array.append <obj[array]> <expr[str]> -> [bool]
#
# Anexa o elemento ao final do array.
#
function array.append()
{
	getopt.parse 2 "obj:array:$1" "expr:str:$2" "${@:3}"

	local -n __ref__=$1
	__ref__+=("$2")
	return $?
}

# .FUNCTION array.clear <obj[array]> -> [bool]
#
# Apaga todos os elementos do container.
#
function array.clear()
{
	getopt.parse 2 "obj:array:$1" "${@:2}"
	
	unset $1
	return $?
}

# .FUNCTION array.clone <src[array]> <dest[array]> -> [bool]
#
# Copia os elementos de origem para o container de destino
# sobrescrevendo os elementos já existentes.
#
# == EXEMPLO ==
#
# source array.sh
#
# arr1=(item1 item2 item3)
# arr2=(item4 item5 item6)
#
# echo 'arr1 ->' ${arr1[@]}
# echo 'arr2 ->' ${arr2[@]}
# echo ---
#
# array.clone arr1 arr2
# echo 'arr2 ->' ${arr2[@]}
#
# == SAÍDA ==
#
# arr1 -> item1 item2 item3
# arr2 -> item4 item5 item6
# ---
# arr2 -> item1 item2 item3
#
function array.clone()
{
	getopt.parse 2 "src:array:$1" "dest:array:$2" "${@:3}"
	
	local -n __ref1__=$1 __ref2__=$2
	__ref2__=("${__ref1__[@]}")
	return $?
}

# .FUNCTION array.copy <src[array]> <dest[array]> -> [bool]
#
# Anexa os elementos de origem no container de destino.
#
function array.copy()
{
	getopt.parse 2 "src:array:$1" "dest:array:$2" "${@:3}"

	local -n __ref1__=$1 __ref2__=$2
	__ref2__+=("${__ref1__[@]}")
	return $?
}

# .FUNCTION array.count <obj[array]> <expr[str]> -> [uint]|[bool]
#
# Retorna a quantidade de ocorrências do elemento no container.
#
# == EXEMPLO ==
#
# source array.sh
#
# arr=(item1 item2 item1 item1 item6 item7 item8)
# array.count arr 'item1'
#
# == SAÍDA ==
#
# 3
#
function array.count()
{
	getopt.parse 2 "obj:array:$1" "expr:str:$2" "${@:3}"

	local -n __ref__=$1
	local __c__ __elem__

	for __elem__ in "${__ref__[@]}"; do
		[[ $__elem__ == $2 ]] && ((++__c__))
	done

	echo ${__c__:-0}
	
	return $?
}

# .FUNCTION array.items <obj[array]> -> [str]|[bool]
#
# Retorna uma lista iterável dos elementos contidos no container.
#
function array.items()
{
	getopt.parse 1 "obj:array:$1" "${@:2}"

	local -n __ref__=$1
	printf '%s\n' "${__ref__[@]}"

	return $?
}

# .FUNCTION array.index <obj[array]> <expr[str]> -> [int]|[bool]
#
# Retorna o índice do elemento no container.
#
function array.index()
{
	getopt.parse 2 "obj:array:$1" "expr:str:$2" "${@:3}"

	local -n __ref__=$1
	local __ind__ __pos__

	for __ind__ in ${!__ref__[@]}; do
		[[ ${__ref__[$__ind__]} == $2 ]]	&&
		__pos__=$__ind__					&& 
		break
	done

	echo ${__pos__:--1}

	return $?
}

# .FUNCTION array.insert <obj[array]> <index[uint]> <expr[str]> -> [bool]
#
# Insere o elemento no índice do container, reidexando os elementos subsequentes
# a partir do índice especificado.
# 
# == EXEMPLO ==
#
# source array.sh
#
# arr=(item1 item2 item4 item5)
# echo ${arr[@]}
#
# array.insert arr 3 'item3'
# echo ${arr[@]}
#
# == SAÍDA ==
#
# item1 item2 item4 item5
# item1 item2 item3 item4 item5
#
function array.insert()
{
	getopt.parse 3 "obj:array:$1" "index:uint:$2" "expr:str:$3" "${@:4}"

	local -n __ref__=$1
	__ref__=("${__ref__[@]:0:$2}" [$2]="$3" "${__ref__[@]:$2}")
	
	return $?
}

# .FUNCTION array.pop <obj[array]> <index[int]> -> [str]|[bool]
#
# Retorna e remove o elemento do indice especificado. Utilize notação negativa
# para deslocamento reverso.
#
# == EXEMPLO ==
#
# source array.sh
#
# arr=(item1 item2 item3 item4 item5)
#
# echo "arr ->" ${arr[@]}
# echo ---
# array.pop arr 0     # Primeiro
# array.pop arr -1    # ùltimo
# echo ---
# echo "arr ->" ${arr[@]}
#
# == SAÍDA ==
#
# arr -> item1 item2 item3 item4 item5
# ---
# item1
# item5
# ---
# arr -> item2 item3 item4
#
function array.pop()
{
	getopt.parse 2 "obj:array:$1" "index:int:$2" "${@:3}"

	local -n __ref__=$1

	echo "${__ref__[$2]}"
	unset __ref__[$2]
	return $?
}

# .FUNCTION array.remove <obj[array]> <expr[str]> -> [bool]
#
# Remove a primeira ocorrência do elemento.
#
function array.remove()
{
	getopt.parse 2 "obj:array:$1" "expr:str:$2" "${@:3}"

	local -n __ref__=$1
	local __i__

	for __i__ in ${!__ref__[@]}; do
		[[ ${__ref__[$__i__]} == $2 ]] &&
		unset __ref__[$__i__] && break
	done

	return $?
}

# .FUNCTION array.reverse <obj[array]> -> [bool]
#
# Inverte a ordem dos elementos.
#
# == EXEMPLO ==
#
# source array.sh
#
# arr=(item1 item2 item3 item4 item5)
#
# echo ${arr[@]}
# array.reverse arr
# echo ${arr[@]}
#
# == SAÍDA ==
#
# item1 item2 item3 item4 item5
# item5 item4 item3 item2 item1
#
function array.reverse()
{
	getopt.parse 1 "obj:array:$1" "${@:2}"

	local -n __ref__=$1

	mapfile -t $1 < <(printf '%s\n' "${__ref__[@]}" | tac)
	return $?
}

# .FUNCTION array.sort <obj[array]> -> [str]|[bool]
#
# Define os elementos em uma ordem ascendente.
#
function array.sort()
{
	getopt.parse 1 "obj:array:$1" "${@:2}"

	local -n __ref__=$1

	mapfile -t $1 < <(printf '%s\n' "${__ref__[@]}" | sort -d)
	return $?
}

# .FUNCTION array.join <obj[array]> <sep[str]> -> [str]|[bool]
#
# Retorna uma string que é a concatenação das strings no iterável
# com o separador especificado.
#
function array.join()
{
	getopt.parse 2 "obj:array:$1" "expr:str:$2" "${@:3}"

	local -n __ref__=$1
	local __tmp__

	printf -v __tmp__ "%s${2//%/%%}" "${__ref__[@]}"
	echo "${__tmp__%$2}"

	return $?
}

# .FUNCTION array.item <obj[array]> <index[int]> -> [str]|[bool]
#
# Retorna o elemento armazenado no índice especificado.
# > Utilize notação negativa para deslocamento reverso.
#
function array.item()
{
	getopt.parse 2 "obj:array:$1" "index:int:$2" "${@:3}"

	local -n __ref__=$1
	echo "${__ref__[$2]}"

	return $?
}

# .FUNCTION array.contains <obj[array]> <expr[str]> -> [bool]
#
# Retorna 'true' se contém o elemento, caso contrário 'false'.
#
function array.contains()
{
	getopt.parse 2 "obj:array:$1" "expr:str:$2" "${@:3}"

	local -n __ref__=$1
	local __item__

	for __item__ in "${__ref__[@]}"; do
		[[ $__item__ == $2 ]] && break
	done

	return $?
}

# .FUNCTION array.reindex <obj[array]> -> [bool]
#
# Realiza a reindexação dos elementos.
#
function array.reindex()
{
	getopt.parse 1 "obj:array:$1" "${@:2}"

	local -n __ref__=$1

	__ref__=("${__ref__[@]}")
	return $?
}

# .FUNCTION array.slice <obj[array]> <slice[str]> -> [str]|[bool]
#
# Retorna uma substring resultante do elemento dentro de um container.
# O Slice é a representação do índice e intervalo que deve respeitar 
# o seguinte formato:
#
# [start:len]...
#
# start - Índice ou posição do elemento dentro do container.
# len   - comprimento a ser capturado a partir de 'start'.
#
# > Não pode conter espaços entre slices.
# > Utilize notação negativa para deslocamento reverso.
#
# Pode ser especificado mais de um slice na expressão, onde o primeiro slice
# representa a posição do elemento dentro do container e os slices subsequentes
# o intervalo da cadeia de caracteres a ser capturada.
#
# == EXEMPLO ==
#
# source array.sh
#
# arr=('Debian' 'Ubuntu' 'Manjaro' 'Fedora')
#
# array.slice arr '[0][:3]'    # Os três primeiros caracteres do 1º elemento'
# array.slice arr '[1][3:]'    # Os três últimos caracteres do 2º elemento.
# array.slice arr '[2][3:2]'   # Os dois caracteres a partir da posição '3' do 3º elemento.
# array.slice arr '[-1][:-2]'  # O último elemento exceto os dois últimos caracteres.
# array.slice arr '[:2]'       # Os dois primeiros elementos.
#
# == SAÍDA ==
#
# Deb
# ntu
# ja
# Fedo
# Debian
# Ubuntu
#
function array.slice()
{
	getopt.parse 2 "obj:array:$1" "slice:str:$2" "${@:3}"

	[[ $2 =~ ${__BUILTIN__[slice]} ]] || error.fatal "'$2' erro de sintaxe na expressão slice"

	local -n __ref__=$1
	local __slice__=$2
	local __arr__=("${__ref__[@]}")
	local __ini__ __len__

	while [[ $__slice__ =~ \[([^]]+)\] ]]; do
		IFS=':' read __ini__ __len__ <<< ${BASH_REMATCH[1]}

		__ini__=${__ini__:-0}

		[[ ${BASH_REMATCH[1]} != *@(:)* ]] && __len__=1

		# array
		if [[ ${#__arr__[@]} -gt 1 ]]; then
			[[ $__len__ -lt 0 ]] 	&& __arr__=() && break
			__len__=${__len__:-$((${#__arr__[@]}-$__ini__))}
			__arr__=("${__arr__[@]:$__ini__:$__len__}")
		else
		# string
			[[ ${__len__#-} -gt ${#__arr__} ]] && __arr__='' && break
			__len__=${__len__:-$((${#__arr__}-$__ini__))}
			__arr__=${__arr__:$__ini__:$__len__}
		fi
		__slice__=${__slice__/\[${BASH_REMATCH[1]}\]/}
	done

	printf '%s\n' "${__arr__[@]}"

	return $?
}

# .FUNCTION array.listindex <obj[array]> -> [uint]
#
# Retorna o índice dos elementos.
#
function array.listindex()
{
	getopt.parse 1 "obj:array:$1" "${@:2}"

	local -n __ref__=$1
	echo ${!__ref__[@]}
	return $?
}

# .FUNCTION array.list <obj[array]> -> [uint|str]|[bool]
#
# Retorna uma lista iterável dos elementos e seus respectivos
# indices no seguinte formato:
#
# index|item
#
function array.list()
{
	getopt.parse 1 "obj:array:$1" "${@:2}"

	local -n __ref__=$1
	local __i__

	for __i__ in ${!__ref__[@]}; do
		echo "$__i__|${__ref__[$__i__]}"
	done

	return $?
}

# .TYPE array_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.len
# S.append
# S.clear
# S.clone
# S.copy
# S.count
# S.items
# S.index
# S.insert
# S.pop
# S.remove
# S.reverse
# S.sort
# S.join
# S.item
# S.contains
# S.reindex
# S.slice
# S.listindex
# S.list
#
typedef array_t	\
		array.len		\
		array.append	\
		array.clear		\
		array.clone		\
		array.copy		\
		array.count		\
		array.items		\
		array.index		\
		array.insert	\
		array.pop		\
		array.remove	\
		array.reverse	\
		array.sort		\
		array.join		\
		array.item		\
		array.contains	\
		array.reindex	\
		array.slice		\
		array.listindex	\
		array.list

readonly -f	array.len 		\
			array.append	\
			array.clear		\
			array.clone		\
			array.copy		\
			array.count		\
			array.items		\
			array.index		\
			array.insert	\
			array.pop		\
			array.remove	\
			array.reverse	\
			array.sort		\
			array.join		\
			array.item		\
			array.contains	\
			array.reindex	\
			array.slice		\
			array.listindex	\
			array.list

# /* __ARRAY_SH__ */
