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

[[ $__ARRAY_SH ]] && return 0

readonly __ARRAY_SH=1

source builtin.sh

__TYPE__[array_t]='
array.append 
array.clear 
array.copy 
array.clone 
array.count 
array.items 
array.index 
array.insert 
array.pop 
array.remove 
array.removeall 
array.reverse 
array.len 
array.sort 
array.join 
array.item 
array.contains 
array.reindex 
array.slice
array.listindex
array.list
'

# func array.append <[array]name> <[str]object>
#
# Anexa 'object' no final de 'name'.
#
function array.append()
{
	getopt.parse 2 "name:array:+:$1" "object:str:-:$2" ${@:3}

	declare -n __arr=$1
	__arr+=("$2")
	return 0
}

# func array.clear <[array]name>
#
# Limpa todos os elementos de 'name'
#
function array.clear()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	unset $1
	return 0
}

# func array.clone <[array]src> <[array]dest>
#
# Clona todos os elementos de 'src' para 'dest', sobrescrevendo os elementos
# de 'dest' caso já exista.
#
function array.clone()
{
	getopt.parse 2 "src:array:+:$1" "dest:array:+:$2" ${@:3}
	
	unset $2

	declare -n __arr_src=$1 __arr_dest=$2
	__arr_dest=("${__arr_src[@]}")

	return 0
}

# func array.copy <[array]src> <[array]dest>
#
# Copia os elementos de 'src' para 'dest' anexando ao final do array. Os elementos
# de 'dest' são mantidos.
#
function array.copy()
{
	getopt.parse 2 "src:array:+:$1" "dest:array:+:$2" ${@:3}
	
	declare -n __arr_src=$1 __arr_dest=$2
	__arr_dest+=("${__arr_src[@]}") 

	return 0
}

# func array.count <[array]name> <[str]object> => [uint]
#
# Retorna 'N' ocorrências de 'object' em 'name'.
#
function array.count()
{
	getopt.parse 2 "src:array:+:$1" "object:str:-:$2" ${@:3}
	
	declare -n __arr=$1
	local __elem __c=0
	
	for __elem in "${__arr[@]}"; do
		[[ $__elem == $2 ]] && ((__c++))
	done
	
	echo $__c

	return 0
}

# func array.items <[array]name> => [str]
#
# Retorna uma lista iterável dos elementos de 'name'.
#
function array.items()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	declare -n __arr=$1
	printf "%s\n" "${__arr[@]}"

	return 0
}

# func array.index <[array]name> <[str]object> => [int]
#
# Retorna o índice da primeira ocorrência de 'object' em 'name'.
# Se 'object' não for encontrado, retorna '-1'.
#
function array.index()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	declare -n __arr=$1
	local __i __pos=-1
	
	for __i in ${!__arr[@]}; do
		if [[ $2 == ${__arr[$__i]} ]]; then
			__pos=$__i
			break
		fi
	done
	
	echo $__pos

	return 0
}

# func array.insert <[array]name> <[uint]index> <[str]object>
#
# Insere 'object' na posição 'index' de 'name'.
# A cada inserção o índice dos elementos é reindexado para uma
# ordem sequêncial crescente a partir do 'index' inserido.
function array.insert()
{
	getopt.parse 3 "name:array:+:$1" "index:uint:+:$2" "object:str:-:$3" ${@:4}
	
	declare -n __arr=$1
	__arr=([$2]="$3" "${__arr[@]}")
	
	return 0
}

# func array.pop <[array]name> <[int]index> => [object]
#
# Remove e retorna o item armazenado em 'index'. Se 'index' for igual a '-1'
# será retornado o último elemento.
#
function array.pop()
{
	getopt.parse 2 "name:array:+:$1" "index:int:+:$2" ${@:3}
	
	declare -n __arr=$1
		
	if [[ $2 -gt -2 ]]; then	
		echo "${__arr[$2]}"
		unset __arr[$2]
	fi

	return 0	
}

# func array.remove <[array]name> <[str]object>
#
# Remove a primeira ocorrência de 'object' em 'name'.
#
function array.remove()
{
	getopt.parse 2 "name:array:+:$1" "object:str:-:$2" ${@:3}
	
	declare -n __arr=$1
	local __i

	for __i in ${!__arr[@]}; do
		if [[ $2 == ${__arr[$__i]} ]]; then
			unset __arr[$__i]
			break
		fi
	done

	return 0
}

# func array.removeall <[array]name> <[str]object>
#
# Remove todas as ocorrências de 'object' em 'name'.
#
function array.removeall()
{
	getopt.parse 2 "name:array:+:$1" "object:str:-:$2" ${@:3}
	
	declare -n __arr=$1
	local __i

	for __i in ${!__arr[@]}; do
		if [[ $2 == ${__arr[$__i]} ]]; then
			unset __arr[$__i]
		fi
	done

	return 0
}

# func array.reverse <[array]name>
#
# Inverte a ordem dos elementos em 'name'.
#
function array.reverse()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	declare -n __arr=$1
	mapfile -t __arr < <(printf '%s\n' "${__arr[@]}" | sort -dr)
	return 0
}

# func array.len <[array]name> => [uint]
#
# Retorna o total de elementos em 'name'.
#
function array.len()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	declare -n __arr=$1
	echo ${#__arr[@]}
	return 0
}

# func array.sort <[array]name>
#
# Organiza os elementos de 'name' em ordem alfabética.
#
function array.sort()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	declare -n __arr=$1
	mapfile -t __arr < <(printf '%s\n' "${__arr[@]}" | sort -d)
	return 0
}

# func array.join <[array]name> <[str]exp> => [str]
#
# Retorna uma string contendo uma cópia de 'name' inserindo 'exp'
# entre os elementos.
#
function array.join()
{
	getopt.parse 2 "name:array:+:$1" "exp:str:-:$2" ${@:3}
	
	declare -n __arr=$1
	local tmp
	printf -v tmp "%s$2" "${__arr[@]}"; echo
	echo "${tmp%$2}"
	return 0
}

# func array.item <[array]name> <[int]index> => [object]
#
# Retorna 'object' armazenado em 'index'. Se 'index' for igual a '-1'
# será retornado o último objeto.
#
function array.item()
{
	getopt.parse 2 "name:array:+:$1" "index:int:+:$2" ${@:3}
	
	declare -n __arr=$1
	[[ $2 -gt -2 ]] && echo "${__arr[$2]}"
	return 0
}

# func array.contains <[array]name> <[str]object> => [bool]
#
# Retorna 'true' se 'name' contém 'object'. Caso contrário 'false'.
#
function array.contains()
{
	getopt.parse 2 "name:array:+:$1" "object:str:-:$2" ${@:3}

	declare -n __arr=$1
	local __item
	
	for __item in "${__arr[@]}"; do
		[[ $2 == $__item ]] && return 0
	done

	return 1
}

# func array.reindex <[array]name>
#
# Realiza a reindexação dos elementos contidos em 'name', iniciando
# a partir da posição '0'.
function array.reindex()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	declare -n __arr=$1
	__arr=("${__arr[@]}")
	return 0
}

# func array.slice <[array]name> <[slice]slice> => [str]
#
# Retorna um subconjunto de objetos em 'name' a partir do slice '[ini:len]'; Onde
# o primeiro slice refere-se a posição e o total de objetos a serem lidos, enquanto
# os slices subsequentes indicam o intervalo de caracteres a serem capturados.
#
# Se 'len' for omitido, lê o comprimento total de 'exp'.
# Se 'ini' for omitido, lê a partir da posição '0'.
#
# O slice é um argumento variável podendo conter um ou mais intervalos determinando
# o conjunto de captura do slice que o antecede.
#
# Exemplo:
# 
# source array.sh
# 
# # Adicionado objetos ao array 'sys'.
# $ array.append sys "Mac"
# $ array.append sys "Linux"
# $ array.append sys "Windows"
#
# # Capturando os dois primeiros caracteres do objeto na posição 1.
# $ array.slice sys [1][:2]
# Li
# 
#
function array.slice()
{
	getopt.parse 2 "exp:array:+:$1" "slice:slice:+:$2" "${@:3}"
	
	local -n __ptr=$1
	local __slice __arr __ini __len

	__slice=$2
	IFS=' ' __arr=("${__ptr[@]}")

	while [[ $__slice =~ \[([^]]+)\] ]]; do
		IFS=':' read __ini __len <<< ${BASH_REMATCH[1]}
		
		__ini=${__ini:-0}
		[[ ${BASH_REMATCH[1]} != *@(:)* ]] && __len=1

		if [[ ${#__arr[@]} -gt 1 ]]; then
        	[[ $__len -lt 0 ]] && __arr=() && break
			__len=${__len:-$((${#__arr[@]}-$__ini))}
			IFS=' ' __arr=("${__arr[@]:$__ini:$__len}")
		else
			[[ ${__len#-} -gt ${#__arr} ]] && __arr='' && break
			__len=${__len:-$((${#__arr}-$__ini))}
			__arr=${__arr:$__ini:$__len}
		fi
		__slice=${__slice/\[${BASH_REMATCH[1]}\]/}
	done
	
	printf '%s\n' "${__arr[@]}"

    return $?
}

# func array.listindex <[array]name> => [uint]
#
# Retorna os índices dos objetos em 'name'.
#
function array.listindex()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	declare -n __arr=$1
	echo "${!__arr[@]}"
	return 0
}

# func array.list <[array]name> => [uint|object]
#
# Retorna uma lista iterável de todos os objetos de 'name' 
# precedidos por seus respectivos índices.
function array.list()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	declare -n __arr=$1
	local __i

	for __i in ${!__arr[@]}; do
		printf "%d|%s\n" "$__i" "${__arr[$__i]}"
	done

	return 0
}

source.__INIT__
# /* __ARRAY_SH */

