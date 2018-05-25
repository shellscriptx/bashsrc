#!/bin/bash

#    Copyright 2018 Juliano Santos [SHAMAN]
#
#    This file is part of bashsrc.
#
#    bashsrc is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    bashsrc is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with bashsrc.  If not, see <http://www.gnu.org/licenses/>.

[[ $__ERROR_SH ]] && return 0

readonly __ERROR_SH=1

source builtin.sh

var error_t struct_t

error_t.__add__ \
	code 		uint \
	line 		uint \
	func		str \
	error 		str

# func error.resume <[bool]option>
#
# Habilita/Desabilita a rotina para tratamento de erro em tempo de execução.
#
# Flags:
#
# false - Se ocorrer um erro, uma mensagem é exibida contendo as informações da
# pilha de rastreamento e a execução do script é interrompida (padrão).
#
# true - Nâo interrompe a execução em caso de erro.
#
# Exemplo:
#
# #!/bin/bash
#
# source os.sh
# 
# var arq file_t
#
# # Desabilitando o tratamento de erro
# error.resume true
#
# # Tentando ler um arquivo que não existe.
# os.open arq '/home/usuario/arquivo_nao_existe.txt' $O_RDONLY
#
# # Testa o status do erro 
# if [ $(error.code) -ne 0 ]]; then
#     echo 'Ops !! Aconteceu algo !!'
#     echo "Encontrei o erro -> $(error.msg)"
#     echo "Aconteceu aqui -> $(error.func)"
# fi
#
# Restaurando o tratamento de erro
# error.resume false
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
	getopt.parse 1 "option:bool:+:$1" "${@:2}"
	__ON_ERROR_RESUME=$1
	return 0
}

# func error.strerror <[uint]code> <[str]error> => [str]
#
# Exibe a mensagem de erro em um formato de string curta
# com 'code' status.
#
function error.strerror()
{
	getopt.parse 2 "code:uint:+:$1" "error:str:+:$2" ${@:3}
	error.__output strerr "$1" "$2"
	return $?
}

# func error.warn <[uint]code> [str]error> => [str]
#
# Exibe a mensagem de erro no formato de string curta
# com 'code' status, aplicando a paleta de cor vermelha.
#
function error.warn()
{
	getopt.parse 2 "code:uint:+:$1" "error:str:+:$2" ${@:3}
	error.__output warn "$1" "$2"
	return $?
}

# func error.format <[uint]code> <[str]error> <[str]exp> ... => [str]
#
# Retorna uma mensagem de erro com 'code' status, substituindo os códigos
# de formato por 'exp' (se presente).
#
function error.format()
{
	getopt.parse -1 "code:uint:+:$1" "error:str:+:$2" "exp:str:-:$3" ... "${@:4}"
	error.__output fmt "$1" "$2" "${@:3}"
	return $?
}

# func error.errort <[error_t]struct> => [str]
#
# Retorna a mensagem de erro definida em 'struct'.
#
function error.errort()
{
	getopt.parse 1 "struct:error_t:+:$1" "${@:2}"
	error.__output error_t "$1"
	return $?
}

# func error.errortf <[error_t]struct> <[str]exp> ... => [str]
#
# Retorna a mensagem de erro definida em 'struct', substituindo
# os códigos de formato por 'exp' (se presente).
#
function error.errortf()
{
	getopt.parse -1 "struct:error_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	error.__output error_t "$1" "${@:2}"
	return $?
}

# func error.trace <[flag]format> <[str]argname> <[str]argtype> <[str]value> <[str]error> <[str]args> ... => [str]
#
# Imprime uma mensagem de erro detalhada no padrão 'format' com os argumentos especificados e a pilha de rastreamento da ocorrência.
#
# flags:
#
# def  - Formato padrão
# st   - Estrutura
# imp  - Implementação de tipos
# src  - Sources
# exa  - Excesso de argumentos
# deps - Dependências
#
function error.trace()
{
	getopt.parse -1 "flag:flag:+:$1" "argname:str:-:$2" "argtype:str:-:$3" "value:str:-:$4" "error:str:-:$5" "args:str:-:$6" ... "${@:7}"

	local i l t fn
	local stack

	[[ "${FUNCNAME[1]}" == "getopt.parse" ]] && fn=2 || fn=1

	t=(${FUNCNAME[@]:$fn})
	l=(${BASH_LINENO[@]:$fn})
	
	for ((i=${#t[@]}-1; i>=0; i--)); do
		stack+="[${l[$i]}:${t[$i]}] "
	done

	case $__ON_ERROR_RESUME in
		true)	
			__ERR__=1
			__ERR_STACK__=${stack% }
			__ERR_ARG__=$2
			__ERR_TYPE__=$3
			__ERR_VAL__=$4
			__ERR_MSG__=${5:-erro desconhecido}
			__ERR_FUNC__=${FUNCNAME[$fn]}
			__ERR_LINE__=${BASH_LINENO[$fn]}
			__ERR_ARGS__=${*:6}
			;;
		false)
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
					echo "Source: <$2>"
					echo "Dependência: [$3]"
					echo "Versão requerida: $4"
					;;
				st)
					echo "Estrutura: <$2>"
					echo "Membro: [$3]"
					echo "Tipo: $4"
					;;
				objp)
					echo "Objeto requerido: <$2>"
					echo "Atributo: [$3]"
					echo "Objeto: $4"
					;;
				*) return 1;;
			esac
		
			echo "Erro: ${5:-erro desconhecido}"
			echo "------------------------"
	
			exit 1
			;;
	esac	

	return 1
}

# func error.code => [uint]
#
# Retorna o código do erro.
#
error.code(){ getopt.parse 0 "$@"; echo "${__ERR__:-0}"; return 0; }

# func error.stack => [str]
#
# Retorna a pilha de rastreamento.
#
error.stack(){ getopt.parse 0 "$@"; echo "$__ERR_STACK__"; return 0; }

# func error.arg => [str]
# 
# Retorna o argumento.
#
error.arg(){ getopt.parse 0 "$@"; echo "$__ERR_ARG__"; return 0; }

# func error.type => [str]
#
# Retorna o tipo do argumento.
#
error.type(){ getopt.parse 0 "$@"; echo "$__ERR_TYPE__"; return 0; }

# func error.value => [str]
#
# Retorna o valor do argumento.
#
error.value(){ getopt.parse 0 "$@"; echo "$__ERR_VAL__"; return 0; }

# func error.msg => [str]
#
# Retorna a mensagem de erro.
#
error.msg(){ getopt.parse 0 "$@"; echo "$__ERR_MSG__"; return 0; }

# func error.func => [str]
#
# Retorna a função que disparou o erro.
#
error.func(){ getopt.parse 0 "$@"; echo "$__ERR_FUNC__"; return 0; }

# func error.line => [uint]
#
# Retorna o número da linha.
#
error.line(){ getopt.parse 0 "$@"; echo "$__ERR_LINE__"; return 0; }

# func error.args => [str]
#
# Retorna a lista de argumentos.
#
error.args(){ getopt.parse 0 "$@"; echo "$__ERR_ARGS__"; return 0; }

function error.__output()
{
	local c_def c_red code line func err

	if [[ $1 == error_t ]]; then
		if [[ $($2.__typeof__) == $1 ]]; then
			code=$($2.code)
			line=$($2.line)
			func=$($2.func)
			err=$($2.error)
			
			[[ $code ]] || { error.trace st "$1" 'code' 'uint' "$__ERR_STRUCT_VAL_MEMBER"; return $?; } 
			[[ $line ]] || { error.trace st "$1" 'line' 'uint' "$__ERR_STRUCT_VAL_MEMBER"; return $?; } 
			[[ $func ]] || { error.trace st "$1" 'funcname' 'str' "$__ERR_STRUCT_VAL_MEMBER"; return $?; } 
			[[ $err ]] || { error.trace st "$1" 'error' 'str' "$__ERR_STRUCT_VAL_MEMBER"; return $?; }
		else
			error.trace def
			return $?
		fi
	fi

	case $__ON_ERROR_RESUME in
		true)	
			__ERR__=${code:-$2}
			__ERR_MSG__=${err:-$3}
			__ERR_FUNC__=${func:-${FUNCNAME[2]}}
			__ERR_LINE__=${line:-${BASH_LINENO[1]}}
			;;
		false)
			exec 1>&2
			case $1 in
				strerr)		err=$3;;
				warn)		c_red='\033[0;31m'; c_def='\033[0;m'; err=$3;;
				fmt)		err=$3; printf -v err "$err" "${@:4}";;
				error_t) 	printf -v err "$err" "${@:3}";;
				*)			error.trace def; return $?;;
			esac
				
			echo -e "${c_red}${0##*/}: erro: linha ${line:-${BASH_LINENO[1]}}: ${func:-${FUNCNAME[2]}}: ${code:-$2}: $err ${c_def}"
			exit ${code:-$2}
			;;
	esac
	
	return ${code:-$2}
}

source.__INIT__
# /* __ERROR_SH */
