#!/bin/bash

#----------------------------------------------#
# Source:           array.sh
# Data:             14 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__ARRAY_SH ]] && return 0

readonly __ARRAY_SH=1

source builtin.sh

# type array
#
# Uma estrutura de dados que armazena uma coleção de elementos onde cada elemento
# é acessado utilizando uma índice ou vetor, demoninado de array indexado.
#
# Implementa 'S' com os métodos:
#
# S.append <[str]object>
# S.clear
# S.clone <[array]dest>
# S.copy <[array]dest>
# S.count <[str]object> => [uint]
# S.items => [str]
# S.index <[str]object> => [int]
# S.insert <[uint]index> <[str]object>
# S.pop <[int]index> => [object]
# S.remove <[str]object>
# S.removeall <[str]object>
# S.reverse
# S.len => [uint]
# S.sort
# S.join <[str]exp> => [str]
# S.item <[int]index> => [object]
# S.contains <[str]object> => [bool]
# S.reindex
# S.slice <[slice]slice> ... => [object]
# S.listindex => [uint]
# S.list => [uint|object]
#
# Obs: 'S' é uma variável válida.
#

# func array.append <[array]name> <[str]object>
#
# Anexa 'object' no final de 'name'.
#
function array.append()
{
	getopt.parse "name:array:+:$1" "object:str:-:$2"

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
	getopt.parse "name:array:+:$1"
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
	getopt.parse "src:array:+:$1" "dest:array:+:$2"
	
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
	getopt.parse "src:array:+:$1" "dest:array:+:$2"
	
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
	getopt.parse "src:array:+:$1" "object:str:-:$2"
	
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
	getopt.parse "name:array:+:$1"
	
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
	getopt.parse "name:array:+:$1"
	
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
	getopt.parse "name:array:+:$1" "index:uint:+:$2" "object:str:-:$3"
	
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
	getopt.parse "name:array:+:$1" "index:int:+:$2"
	
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
	getopt.parse "name:array:+:$1" "object:str:-:$2"
	
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
	getopt.parse "name:array:+:$1" "object:str:-:$2"
	
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
	getopt.parse "name:array:+:$1"
	
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
	getopt.parse "name:array:+:$1"
	
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
	getopt.parse "name:array:+:$1"
	
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
	getopt.parse "name:array:+:$1" "exp:str:-:$2"
	
	declare -n __arr=$1
	printf "%s$2" "${__arr[@]}"; echo
	return 0
}

# func array.item <[array]name> <[int]index> => [object]
#
# Retorna 'object' armazenado em 'index'. Se 'index' for igual a '-1'
# será retornado o último objeto.
#
function array.item()
{
	getopt.parse "name:array:+:$1" "index:int:+:$2"
	
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
	getopt.parse "name:array:+:$1" "object:str:-:$2"

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
	getopt.parse "name:array:+:$1"
	declare -n __arr=$1
	__arr=("${__arr[@]}")
	return 0
}

# func array.slice <[array]name> <[slice]slice> ... => [object]
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
# $ array.slice sys '[1][:2]'
# Li
#
function array.slice()
{
    getopt.parse "exp:array:+:$1" "slice:slice:+:$2"
	
	declare -n __arr=$1
    local __exp __slice __ini __start __length __delm

	__slice=$2
	__ini=0

    while [[ $__slice =~ \[([^]][0-9]*:?(-[0-9]+|[0-9]*))\] ]]
    do
        __start=${BASH_REMATCH[1]%:*}
        __length=${BASH_REMATCH[1]#*:}
        __delm=${BASH_REMATCH[1]//[0-9]/}

        [[ ! $__delm ]] && __length=1

		__start=${__start:-0}

		if [[ $__ini -eq 0 ]]; then
			__length=${__length:-${#__arr[@]}}
			__exp=${__arr[@]:$__start:$__length}
			__ini=1
		else
			__length=${__length:-${#__exp}}
			__exp=${__exp:$__start:$__length}
		fi
	
		__slice=${__slice/\[${BASH_REMATCH[1]}\]/}

    done

    echo  "$__exp"

    return 0
}

# func array.listindex <[array]name> => [uint]
#
# Retorna os índices dos objetos em 'name'.
#
function array.listindex()
{
	getopt.parse "name:array:+:$1"
	
	declare -n __arr=$1
	printf "%d " "${!__arr[@]}"; echo
	return 0
}

# func array.list <[array]name> => [uint|object]
#
# Retorna uma lista iterável de todos os objetos de 'name' 
# precedidos por seus respectivos índices.
function array.list()
{
	getopt.parse "name:array:+:$1"
	
	declare -n __arr=$1
	local __i

	for __i in ${!__arr[@]}; do
		printf "%d|%s\n" "$__i" "${__arr[$__i]}"
	done

	return 0
}

readonly -f array.append \
			array.clear \
			array.copy \
			array.clone \
			array.count \
			array.items \
			array.index \
			array.insert \
			array.pop \
			array.remove \
			array.removeall \
			array.reverse \
			array.len \
			array.sort \
			array.join \
			array.item \
			array.contains \
			array.reindex \
			array.slice \
			array.listindex \
			array.list 

# /* __ARRAY_SRC */

