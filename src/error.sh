#!/bin/bash

#----------------------------------------------#
# Source:           error.sh
# Data:             9 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__ERROR_SH ]] && return 0

source builtin.sh

readonly __ERROR_SH=1

function error.__trace()
{
	# prototype 
	# error.__trace flag "arg_name" "arg_type" "arg_value" "err_msg" "err_no"; return $?
	local i l t fn
	local stack
	local flag=$1
	local arg_name=$2
	local arg_type=$3
	local arg_val=$4
	local err_msg=${5:-erro desconhecido}
	local errno=${6:-1}

	[[ "${FUNCNAME[1]}" == "getopt.parse" ]] && fn=2 || fn=1

	t=(${FUNCNAME[@]:$fn})
	l=(${BASH_LINENO[@]:$fn})
	
	for ((i=${#t[@]}-1; i>=0; i--)); do
		stack+="[${l[$i]}:${t[$i]}] "
	done
	
	
	case $__EXIT_TRACE_ERROR in
		0)
			declare -g __ERR__=$errno \
						__ERR_STACK__=${stack% } \
						__ERR_ARG__=$arg_name \
						__ERR_TYPE__=$arg_type \
						__ERR_VAL__=$arg_val \
						__ERR_MSG__=$err_msg \
						__ERR_FUNC__=${FUNCNAME[1]}

			;;
		*)
			exec 1>&2
			stack=${stack// / => }
			echo "(Pilha de rastreamento)"
			echo "Arquivo: $0"
			echo
			echo "Chamada interna: ${FUNCNAME[0]}"
			echo "Função: ${FUNCNAME[1]}"
			echo
			echo -e "Pilha: ${stack% => }"

			case $flag in
				imp)
					echo "Tipo: $arg_type"
					echo "Implementação: $arg_val"
					echo "Composição: ${arg_name:+$arg_name.${arg_val##*.}}"
					echo "Método: $arg_val"
					echo "Erro: $err_msg"
					;;
				src)
					echo "Source: $arg_type"
					echo "Tipo: [$arg_val]"
					echo "Erro: $err_msg"
					;;
				def)
					echo -e "Argumento: <$arg_name>"
					echo -e "Tipo: [$arg_type]"
					echo -e "Valor: '$arg_val'"
					echo -e "Erro: $err_msg"
					;;
			esac
			echo "------------------------"
			exec 1<&-
			exit $errno
			;;
	esac

	return $errno
}

function error.__clear()
{ 
	unset __ERR__ \
			__ERR_STACK__ \
			__ERR_ARG__ \
			__ERR_TYPE__ \
			__ERR_VAL__ \
			__ERR_MSG__ \
			__ERR_FUNC__
	
	return 0
}

function error.__depends()
{
	local fncall srcname dep
	
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

# func error.resume <[str]flag>
#
# Habilita/Desabilita a rotina para tratamento de erro em tempo de execução.
#
# Flags:
#
# off - Se ocorrer um erro, uma mensagem é exibida contendo as informações da
# pilha de rastreamento e a execução do script é interrompida (padrão).
#
# on - Se ocorrer um erro, serão inicializadas as variáveis de rastreamento 
# '__ERR_*' e o script continuará seu fluxo de execução.
#
# Variáveis de rastreamento:
#
# __ERR__ - Status do erro
# __ERR_STACK__ - Funções de desencadeamento
# __ERR_ARG__ - Argumento da função
# __ERR_TYPE__ - Tipo de dado do argumento
# __ERR_VAL__ - Valor do argumento
# __ERR_MSG__ - Mensagem de erro
# __ERR_FUNC__ - Função que provocou o erro
# 
# Obs: A função fecha o descritor de erro '2' afetando quaisquer redirecionamento
# para o mesmo, podendo ser restaurada utilizando a flag 'off'. 
#
# Exemplo:
#
# #!/bin/bash
#
# source os.sh
# 
# var arq os.file
#
# # Desabilitando o tratamento de erro
# error.resume on
#
# # Tentando ler um arquivo que não existe.
# os.open arq '/home/usuario/arquivo_nao_existe.txt' $O_RDONLY
#
# # Testa o status do erro 
# if [ $__ERR__ ]; then
#     echo 'Ops !! Aconteceu algo !!'
#     echo "Encontrei o erro -> $__ERR_MSG__"
#     echo "Aconteceu aqui -> $__ERR_FUNC__"
# fi
#
# Restaurando o tratamento de erro
# error.resume off
#
# ----------------------
# Saida:
#
# Ops !! Aconteceu algo !!
# Encontrei o erro -> erro ao criar o descritor '3'
# Aconteceu aqui -> os.open
#
function error.resume()
{
	getopt.parse "flag:str:+:$1"
	
	case $1 in
		on)		exec 2<&-; declare -g __EXIT_TRACE_ERROR=0;;
		off)	exec 2>/dev/tty; declare -g __EXIT_TRACE_ERROR=1;;
		*)		error.__trace def 'flag' 'str' "$1" "flag inválida"; return $?;;
	esac

	return 0
}

readonly -f error.resume \
			error.__trace \
			error.__depends 

# /* __ERROR_SRC */
