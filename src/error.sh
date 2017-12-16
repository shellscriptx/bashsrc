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
	local nmsg=$5

	[[ "${FUNCNAME[1]}" == "getopt.parse" ]] && fn=2 || fn=1

	t=(${FUNCNAME[@]:$fn})
	l=(${BASH_LINENO[@]:$fn})
	
	for ((i=${#t[@]}-1; i>=0; i--)); do
		stack+="[${l[$i]}:${t[$i]}] "
	done
	
	case $__EXIT_TRACE_ERROR in
		0)
			declare -g ERR=1 \
						ERR_STACK=${stack% } \
						ERR_ARG=$1 \
						ERR_TYPE=$2 \
						ERR_VAL=$3 \
						ERR_MSG=$4 \
						ERR_FUNC=${FUNCNAME[1]}

			return 1
			;;
		*)
			stack=${stack// / => }
			echo "(Pilha de rastreamento)"
			echo "Arquivo: $0"
			echo
			echo "Chamada interna: ${FUNCNAME[0]}"
			echo "Função: ${FUNCNAME[1]}"
			echo
			echo -e "Pilha: ${stack% => }"

			case $nmsg in
				1)
					echo "Tipo: $2"
					echo "Implementação: $3"
					echo "Composição: $1.${3##*.}"
					echo "Método: $3"
					echo "Erro: ${4:-erro desconhecido}"
					echo "------------------------"
					;;
				*)
					echo -e "Argumento: <${1:--}>"
					echo -e "Tipo: [${2:--}]"
					echo -e "Valor: '${3:--}'"
					echo -e "Erro: ${4:-erro desconhecido}"
					echo ------------------------
					;;
			esac
			exit 1
			;;
	esac
}

function error.__clear(){ unset ERR ERR_STACK ERR_ARG ERR_TYPE ERR_VAL ERR_MSG ERR_FUNC; return 0; }

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
# 'ERR*' e o script continuará seu fluxo de execução.
#
# Variáveis de rastreamento:
#
# ERR - Status do erro
# ERR_STACK - Funções de desencadeamento
# ERR_ARG - Argumento da função
# ERR_TYPE - Tipo de dado do argumento
# ERR_VAL - Valor do argumento
# ERR_MSG - Mensagem de erro
# ERR_FUNC - Função que provocou o erro
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
# if [ $ERR ]; then
#     echo 'Ops !! Aconteceu algo !!'
#     echo "Encontrei o erro -> $ERR_MSG"
#     echo "Aconteceu aqui -> $ERR_FUNC"
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
		off)	exec 2>/dev/tty; exec 1>&2; declare -g __EXIT_TRACE_ERROR=1;;
		*)		error.__exit 'flag' 'str' "$1" "flag inválida";;
	esac

	return 0
}

readonly -f error.resume \
			error.__exit \
			error.__depends 

# /* __ERROR_SRC */
