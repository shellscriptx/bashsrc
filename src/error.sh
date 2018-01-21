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
	local i l t fn
	local stack

	[[ "${FUNCNAME[1]}" == "getopt.parse" ]] && fn=2 || fn=1

	t=(${FUNCNAME[@]:$fn})
	l=(${BASH_LINENO[@]:$fn})
	
	for ((i=${#t[@]}-1; i>=0; i--)); do
		stack+="[${l[$i]}:${t[$i]}] "
	done
	
	set -e

	case $__EXIT_TRACE_ERROR in
		0)
			set +e
			declare -g	__ERR__=${6:-1} \
						__ERR_STACK__=${stack% } \
						__ERR_ARG__=$2 \
						__ERR_TYPE__=$3 \
						__ERR_VAL__=$4 \
						__ERR_MSG__=${5:-erro desconhecido} \
						__ERR_FUNC__=${FUNCNAME[$fn]}

			;;
		*)
			exec 1>&2
			stack=${stack// / => }
			echo "(Pilha de rastreamento)"
			echo "Script: ${0##*/}"
			echo
			echo "Chamada interna: ${FUNCNAME[0]}"
			echo "Função: ${FUNCNAME[1]}"
			echo
			echo -e "Pilha: ${stack% => }"

			case $1 in
				imp)
					echo "Tipo: $3"
					echo "Método: $4"
					;;
				src)
					echo "Source: $3"
					echo "Tipo: [$4]"
					;;
				def)
					echo "Argumento: <$2>"
					echo "Tipo: [$3]"
					echo "Valor: '$4'"
					;;
				exa)
					echo "Argumento(s): '$4'"
					;;
				deps)
					echo "Source: $3"
					echo "Dependência(s): $4"
					;;
			esac
			echo "Erro: ${5:-erro desconhecido}"
			echo "------------------------"
			exec 1<&-
			;;
	esac

	return ${6:-1}
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
	getopt.parse 1 "flag:str:+:$1" ${@:2}
	
	case $1 in
		on)		exec 2<&-; declare -g __EXIT_TRACE_ERROR=0;;
		off)	exec 2>/dev/tty; declare -g __EXIT_TRACE_ERROR=1;;
		*)		error.__trace def 'flag' 'str' "$1" "flag inválida"; return $?;;
	esac

	return 0
}

source.__INIT__
# /* __ERROR_SRC */
