#!/bin/bash

#----------------------------------------------#
# Source:           rand.sh
# Data:             17 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__RAND_SH ]] && return 0

readonly __RAND_SH=1

source builtin.sh

__SRC_TYPES[arand]='
rand.achoice
'

__SRC_TYPES[mrand]='
rand.mchoice
'

__SRC_TYPES[srand]='
rand.cchoice
rand.wchoice
'

# func rand.range <[int]min> <[int]max> => [int]
#
# Retorna um número inteiro pseudo-aleatório dentro do intervalo
# 'min' e 'max' especificado.
#
function rand.range()
{
	getopt.parse 2 "min:int:+:$1" "max:int:+:$2" ${@:3}
	echo $((RANDOM%($2-$1)+$1))
	return 0
}

# func rand.nrange <[uint]count> => [uint]
#
# Gera 'N' números pseudo-aleatórios.
#
function rand.nrange()
{
	getopt.parse 1 "count:uint:+:$1" ${@:2}
	for ((i=0;i < $1; i++)); do echo "$RANDOM"; done
	return 0
}

# func rand.int => [int]
#
# Retorna uma número inteiro positivo pseudo-aleatório entre 0 - 32767.
#
function rand.int()
{
	getopt.parse 0 ${@:1}
	echo "$RANDOM"
	return 0
}

# func rand.long => [ulong]
#
# Retorna um número positivo longo pseudo-aleatório.
#
function rand.long()
{
	getopt.parse 0 ${@:1}

	local seed=$(printf '%(%s)T')
	seed=$[RANDOM*seed]
	echo $((seed>>${#seed}^2))

	return 0
}
# func rand.achoice <[array]name> => [str]
#
# Retorna aleatóriamente um elemento em 'name'.
#
function rand.achoice()
{
	getopt.parse 1 "name:array:+:$1" ${@:2}

	declare -n __ref=$1
	echo "${__ref[$((RANDOM%${#__ref[@]}))]}"
	return 0
}

# func rand.cchoice <[str]exp> => [str]
#
# Retorna aleatóriamente um caractere da sequência contida em 'exp'.
# Se 'exp' for uma lista iterável, retorna um caractere de cada elemento.
#
function rand.cchoice()
{
	getopt.parse 1 "exp:str:+:$1" ${@:2}
	
	local exp
	while read exp; do 
		echo "${exp:$((RANDOM % ${#exp})):1}"
	done <<< "$1"

	return 0
}

# func rand.mchoice <[map]name> => [str|str]
#
# Retorna um item aleatório em 'map' represetado por 'chave' e 'objeto'.
#
function rand.mchoice()
{
	getopt.parse 1 "name:map:+:$1" ${@:2}
	
	declare -n __map_ref=$1
	local __keys=("${!__map_ref[@]}")
	local __key=${__keys[$((RANDOM % ${#__keys[@]}))]}
	echo "$__key|${__map_ref[$__key]}"
	return 0
}

# func rand.wchoice <[str]exp> => [str]
#
# Retorna aleatóriamente uma palavra contida em 'exp'.
#
function rand.wchoice()
{
	getopt.parse 1 "exp:str:-:$1" ${@:2}

	local exp words
	while read exp; do
		exp=($exp)
		echo "${exp[$(($RANDOM % ${#exp[@]}))]}"
	done <<< "$1"	
	return 0
}

source.__INIT__
# /* __RAND_SH */
