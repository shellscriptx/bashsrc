#!/bin/bash

[[ $__TESTE_SH ]] && return 0

readonly __TESTE_SH=1

source builtin.sh

SRC_TYPE_IMPLEMENTS[rege]='
funcao1
funcao2
fg
'

funcao1(){
	echo 1-$1
}

funcao2(){
	echo 2-$1
}

funcao3(){
	echo 3-$1
}

f(){
	echo oi
}


builtin.__INIT__
