#!/bin/bash

#----------------------------------------------#
# Source:           error.sh
# Data:             9 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__ERROR_SH ]] && return 0

readonly __ERROR_SH=1

# errors
readonly __ERROR_VAR_READONLY='possui atributo somente leitura'

function error.__exit()
{
	local i l t fn
	local stack

	[[ ${FUNCNAME[1]} == getopt.parse ]] && fn=2 || fn=1

	t=(${FUNCNAME[@]:$fn})
	l=(${BASH_LINENO[@]:$fn})
	
	for ((i=${#t[@]}-1; i>=0; i--)); do
		stack+="[${l[$i]}:${t[$i]}] => "
	done

	exec 1>&2

	echo "(Pilha de rastreamento)"
	echo "Arquivo: $0"
	echo
	echo "Chamada interna: ${FUNCNAME[0]}"
	echo "Analise: ${FUNCNAME[1]}"
	echo
	echo -e "Pilha: ${stack% => }"
	echo -e "Argumento: <${1:--}>"
	echo -e "Tipo: [${2:--}]"
	echo -e "Valor: '${3:--}'"
	echo -e "Erro: ${4:-erro desconhecido}"
	echo ------------------------

	exec 1<&-
		
    exit 1
}

function error.__depends()
{
	local fcall srcname dep
	
	fncall=$1
	srcname=$2
	dep=${3// /, }

	exec 1>&2

	echo "(Verificação de dependência)"	
	echo "source: $srcname"
	echo "Chamada: $fncall"
	echo "Erro: pacote(s) requerido(s) não encontrado(s)"
	echo "Dependência(s): ${dep%,}"
	echo ------------------------
	
	exec 1<&-
	
	exit 1
}

readonly -f error.__exit \
			error.__depends

# /* __ERROR_SRC */
