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

# func rand.range <[int]min> <[int]max> => [int]
#
# Retorna um número inteiro pseudo-aleatório dentro do intervalo
# 'min' e 'max' especificado.
#
function rand.range()
{
	getopt.parse "min:int:+:$1" "max:int:+:$2"
	echo $((RANDOM%($2-$1)+$1))
	return 0
}

# func rand.int => [int]
#
# Retorna uma número inteiro positivo pseudo-aleatório entre 0 - 32767.
#
function rand.int()
{
	getopt.parse "-:null:-:$1"
	echo "$RANDOM"
	return 0
}

# func rand.long => [ulong]
#
# Retorna um número positivo longo pseudo-aleatório.
#
function rand.long()
{
	getopt.parse "-:null:-:$1"

	local seed=$(printf '%(%s)T')
	seed=$[RANDOM*seed]
	echo $((seed>>${#seed}^2))

	return 0
}
# func rand.achoice <[array]name> => [object]
#
# Retorna aleatóriamente um elemento em 'name'.
#
function rand.achoice()
{
	getopt.parse "name:array:+:$1"

	declare -n __ref=$1
	local __rnum

	__rnum=$(rand.range 0 ${#__ref[@]})
	echo "${__ref[$__rnum]}"

	return 0
}

# func rand.cchoice <[str]exp> => [char]
#
# Retorna aleatóriamente um caractere da sequência contida em 'exp'.
#
function rand.cchoice()
{
	getopt.parse "exp:str:+:$1"

	local rnum=$(rand.range 0 ${#1})
	echo "${1:$rnum:1}"

	return 0
}

# func rand.mchoice <[map]name> => [key|object]
#
# Retorna um item aleatório em 'map' represetado por 'chave' e 'objeto'.
#
function rand.mchoice()
{
	getopt.parse "name:map:+:$1"
	
	declare -n __map_ref=$1
	local __keys=("${!__map_ref[@]}")
	local __key=$(rand.achoice __keys)
	echo "$__key|${__map_ref[$__key]}"

	return 0
}

# func rand.wchoice <[str]exp> => [str]
#
# Retorna aleatóriamente uma palavra contida em 'exp'.
#
function rand.wchoice()
{
	getopt.parse "exp:str:-:$1"
	
	local words=($1)
	local word=$(rand.achoice words)
	echo "$word"
	
	return 0
}

readonly -f rand.range \
			rand.int \
			rand.mchoice \
			rand.achoice \
			rand.cchoice \
			rand.wchoice \
			rand.long

# /* __RAND_SRC */
