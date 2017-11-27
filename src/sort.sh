#!/bin/bash

#----------------------------------------------#
# Source:           sort.sh
# Data:             1 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__SORT_SRC ]] && return 0

readonly __SORT_SRC=1

# func sort.int <[array]name> => [int]
#
# Retorna uma cópia dos elementos de 'name' em uma
# lista iterável em ordem crescente.
#
function sort.int()
{
	getopt.parse "name:array:+:$1"
	
	declare -n __arr=$1
	printf "%d\n" "${__arr[@]}" | sort -n
	return 0
}

# func sort.str <[array]name> => [str]
#
# Retorna uma cópia dos elementos de 'name' em uma
# lista iterável em ordem alfabética.
#
function sort.str()
{
	getopt.parse "name:array:+:$1"
	
	declare -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -d
	return 0
}

# func sort.intsorted <[array]name> => [bool]
#
# Retorna 'true' se os elementos em 'name' estão em ordem crescente.
# Caso contrário 'false'.
#
function sort.intsorted()
{
	getopt.parse "name:array:+:$1"
	
	declare -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -nC
	return $?
}

# func sort.strsorted <[array]name> => [bool]
#
# Retorna 'true' se os elementos em 'name' estão em ordem alfabética.
# Caso contrário 'false'.
#
function sort.strsorted()
{
	getopt.parse "name:array:+:$1"
	
	declare -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -dC
	return $?
}

# func sort.intrev <[array]name> => [int]
#
# Retorna uma cópia dos elementos de 'name' em uma lista iterável em
# ordem decrescente.
#
function sort.intrev()
{
	getopt.parse "name:array:+:$1"
	
	declare -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -nr
	return 0
}

# func sort.strrev <[array]name> => [str]
#
# Retorna uma cópia dos elementos de 'name' em uma lista iterável em
# ordem alfabética inversa.
#
function sort.strrev()
{
	getopt.parse "name:array:+:$1"
	
	declare -n __arr=$1
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
	getopt.parse "name:array:+:$1"

	declare -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -h
	return 0
}

# func sort.sizerev <[array]name> => [size]
#
# Retorna uma cópia dos elementos de 'name' em uma lista iterável em
# ordem computacional decrescente.
#
function sort.sizerev()
{
	getopt.parse "name:array:+:$1"

	declare -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -hr
	return 0
}

# func sort.sizesorted <[array]name> => [bool]
#
# Retorna 'true' se os elementos de 'name' estão em ordem
# computacional crescente. Caso contrário 'false'.
#
# Exemplo: 10K, 1M, 5G, 2T ...
#
function sort.sizesorted()
{
	getopt.parse "name:array:+:$1"

	declare -n __arr=$1
	printf "%s\n" "${__arr[@]}" | sort -hr
	return 0
}

# func sort.expstr <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com a sequência em ordem alfabética.
#
function sort.expstr()
{
	getopt.parse "exp:str:-:$1"
	echo $(printf "%s\n" $1 | sort -d)
	return 0
}

# func sort.expstrrev <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com a sequência em ordem alfabética inversa.
#
function sort.expstrrev()
{
	getopt.parse "exp:str:-:$1"
	echo $(printf "%s\n" $1 | sort -dr)
	return 0
}

# func sort.expint <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com a sequência de números em ordem crescente.
#
function sort.expint()
{
	getopt.parse "exp:str:-:$1"
	echo $(printf "%s\n" $1 | sort -n)
	return 0
}

# func sort.expintrev <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com a sequência de números em ordem decrescente.
#
function sort.expintrev()
{
	getopt.parse "exp:str:-:$1"
	echo $(printf "%s\n" $1 | sort -nr)
	return 0
}

readonly -f sort.int \
			sort.str \
			sort.intsorted \
			sort.strsorted \
			sort.intrev \
			sort.strrev \
			sort.size \
			sort.sizerev \
			sort.sizesorted \
			sort.expstr \
			sort.expstrrev \
			sort.expint \
			sort.expintrev 

# /* __SORT_SRC */
