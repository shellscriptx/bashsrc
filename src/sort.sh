#!/bin/bash

#----------------------------------------------#
# Source:           sort.sh
# Data:             1 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__SORT_SH ]] && return 0

readonly __SORT_SH=1

source builtin.sh

__TYPE__[asort_t]='
sort.array.int
sort.array.str
sort.array.intsorted
sort.array.strsorted
sort.array.intrev
sort.array.strrev
'

__TYPE__[szsort_t]='
sort.size
sort.size.rev
sort.size.sorted
'

__TYPE__[ssort_t]='
sort.str
sort.str.rev
sort.str.int
sort.str.intrev
'

# func sort.array.int <[array]name> => [int]
#
# Retorna uma cópia dos elementos de 'name' em uma
# lista iterável em ordem crescente.
#
function sort.array.int()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	local -n __arr=$1
	printf "%d\n" "${__arr[@]}" | sort -n
	return 0
}

# func sort.array.str <[array]name> => [str]
#
# Retorna uma cópia dos elementos de 'name' em uma
# lista iterável em ordem alfabética.
#
function sort.array.str()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	local -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -d
	return 0
}

# func sort.array.intsorted <[array]name> => [bool]
#
# Retorna 'true' se os elementos em 'name' estão em ordem crescente.
# Caso contrário 'false'.
#
function sort.array.intsorted()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	local -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -C
	return $?
}

# func sort.array.strsorted <[array]name> => [bool]
#
# Retorna 'true' se os elementos em 'name' estão em ordem alfabética.
# Caso contrário 'false'.
#
function sort.array.strsorted()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	local -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -C
	return $?
}

# func sort.array.intrev <[array]name> => [int]
#
# Retorna uma cópia dos elementos de 'name' em uma lista iterável em
# ordem decrescente.
#
function sort.array.intrev()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	local -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -nr
	return 0
}

# func sort.array.strrev <[array]name> => [str]
#
# Retorna uma cópia dos elementos de 'name' em uma lista iterável em
# ordem alfabética inversa.
#
function sort.array.strrev()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}
	
	local -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -dr
	return 0
}

# func sort.size <[array]name> => [size]
#
# Retorna uma cópia dos elementos de 'name' em uma lista iterável em
# ordem computacional crescrente.
#
# Exemplo: 10K, 1M, 5G, 2T ...
#
function sort.size()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}

	local -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -h
	return 0
}

# func sort.size.rev <[array]name> => [size]
#
# Retorna uma cópia dos elementos de 'name' em uma lista iterável em
# ordem computacional decrescente.
#
function sort.size.rev()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}

	local -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -hr
	return 0
}

# func sort.size.sorted <[array]name> => [bool]
#
# Retorna 'true' se os elementos de 'name' estão em ordem
# computacional crescente. Caso contrário 'false'.
#
# Exemplo: 10K, 1M, 5G, 2T ...
#
function sort.size.sorted()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}

	local -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -hr
	return 0
}

# func sort.str <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com a sequência em ordem alfabética.
#
function sort.str()
{
	getopt.parse 1 "exp:str:-:$1" ${@:2}
	echo $(printf '%s\n' $1 | sort -d)
	return 0
}

# func sort.str.rev <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com a sequência em ordem alfabética inversa.
#
function sort.str.rev()
{
	getopt.parse 1 "exp:str:-:$1" ${@:2}
	echo $(printf '%s\n' $1 | sort -dr)
	return 0
}

# func sort.str.int <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com a sequência de números em ordem crescente.
#
function sort.str.int()
{
	getopt.parse 1 "exp:str:-:$1" ${@:2}
	echo $(printf '%s\n' $1 | sort -n)
	return 0
}

# func sort.str.intrev <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com a sequência de números em ordem decrescente.
#
function sort.str.intrev()
{
	getopt.parse 1 "exp:str:-:$1" ${@:2}
	echo $(printf '%s\n' $1 | sort -nr)
	return 0
}

source.__INIT__
# /* __SORT_SH */
