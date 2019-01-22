#!/bin/bash

[[ $__TESTE_SH ]] && return 0

readonly __TESTE_SH=1

source builtin.sh

SRC_TYPE_IMPLEMENTS[inteiro]='
somar
diminuir
replace
'

somar(){
	echo $(($1+$2))
}

diminuir(){
	echo $(($1-$2))
}


replace(){
	echo oi
}
builtin.__INIT__

