#!/bin/bash

# * Bibliioteca de teste tudo certo
#
# ** ** ação
# * tudo bem ?
# * assim asc oisas vao ficar numa boa
# * certo jovem ?
[[ $__TESTE_SH__ ]] && return 0

readonly __TESTE_SH__=1

# [src]
source builtin.sh
source string.sh

__DEPS__='links'

__NO_BUILTIN_T__='
calc_t
'

__TYPE__[cpu_t]='
somar
diminuir
dividir
multiplicar
mai
'

somar(){
	getopt.parse 2 "x:int:+:$1" "y:int:+:$2"
	echo $(($1+$2))
}

diminuir(){
	getopt.parse 2 "x:int:+:$1" "y:int:+:$2"
	echo $(($1-$2))
}

multiplicar(){
	getopt.parse 2 "x:int:+:$1" "y:int:+:$2"
	echo $(($1*$2))
}

dividir(){
	getopt.parse 2 "x:int:+:$1" "y:int:+:$2"
	echo $(($1/$2))
}

mai(){
	getopt.parse 1 "varname:var:+:$1"
	local -n __ptr=$1

	__ptr="$__ptr - SANTOS"
	return 0
}

source.__INIT__

