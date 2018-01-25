#!/bin/bash

#----------------------------------------------#
# Source:           getopt.sh
# Data:             12 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__GETOPT_SH ]] && return 0

readonly __GETOPT_SH=1

source builtin.sh

readonly __ERR_GETOPT_TYPE_ARG='o argumento esperado é do tipo'
readonly __ERR_GETOPT_TYPE_INVALID='tipo do objeto inválido'
readonly __ERR_GETOPT_FLAG='flag não suportada'
readonly __ERR_GETOPT_DIR_NOT_FOUND='diretório não encontrado'
readonly __ERR_GETOPT_FILE_NOT_FOUND='arquivo não encontrado'
readonly __ERR_GETOPT_PATH_NOT_FOUND='arquivo ou diretório não encontrado'
readonly __ERR_GETOPT_FD_NOT_EXISTS='o descritor do arquivo não existe'
readonly __ERR_GETOPT_TOO_MANY_ARGS='excesso de argumentos'
readonly __ERR_GETOPT_KEYWORD='operador/argumento requerido'
readonly __ERR_GETOPT_ARG_NAME='nome do argumento inválido'
readonly __ERR_GETOPT_ARG_REQUIRED='o argumento requerido'

# func getopt.parse <[uint]nargs> <[str]name:type:flag:value> ... ${@:nargs+1} -> [bool]
#
# Trata a lista de parâmetros em 'name:type:flag:value' verificando as configurações
# especificadas para cada argumento posicional e se possui 'N'args na chamada da função.
# Retorna true se todos os argumentos satisfazem os critérios determinados, caso contrário
# retorna false e finaliza a função.
# 
# nargs - número máximo de argumentos. (Utilize '-1' para definir uma função variádica).
#
# name - nomenclatura do parâmetro. Caracteres suportados. [a-zA-Z0-9_=-]
#
# type - tipo de dado aceito pelo parâmetro.
#
# flag - atributo que determina o comportamento do parâmetro. Utilize o 
# caractere '-' (hifen) para especificar que o argumento é opcional
# ou '+' para obrigatório.
#            
# value - valor a ser verificado pela função com base no tipo definido.
#
# ${@:total_args+1} - array de argumentos posicionais a partir do índice 'total_args + 1'.
#
# types:
#
# uint		- inteiro sem sinal.
# int		- inteiro com sinal.
# zone		- fuso horário.
# char		- caractere único.
# str		- uma cadeia de caracteres.
# bool		- booleano (true ou false).
# var		- identificador de uma variável válida.
# array		- array indexado.
# map		- array associativo.
# func		- identificador de uma função válida.
# funcname	- identificador válido suportado para referênciar uma função.
# bin		- número binário (base 2).
# hex		- número hexadecimal (base 16).
# oct		- número octal (base 8).
# size		- unidade de armazenamento. (12KB, 1MB, 10G, 2TB ...)
# 12h		- hora no formato 12 horas. (HH:MM -> 1..12)
# 24h		- hora no formato 24 horas. (HH:MM -> 0..23)
# date		- data. (DD/MM/YYYY) 
# hour		- hora. (0..23)
# min		- minutos. (0..59)
# sec		- segundos. (0..59)
# mday		- dia do mês. (1..31)
# mon		- dia da semana. (1..12)
# year		- ano. inteiro positivo com 4 ou mais digitos.
# yday		- dias do ano. (1..366)
# wday		- dias da semana. (1..7)
# url		- endereço web. (http|https|ftp|smtp)://....
# email		- endereço de email.
# ipv4		- protocolo ipv4 (32 bits)
# ipv6		- protocolo ipv6 (128 bits)
# mac		- endereço MAC Address (xx:xx:xx:xx:xx:xx)
# slice		- intervalo númerico positivo. (x:x)
# uslice    - intervalo número. (x:x)
# keyword	- palavra chave.
# dir		- diretório válido.
# file		- arquivo padrão.
# path		- caminho válido.
# fd		- inteiro positivo que representa um descritor de arquivo.
# type		- objeto de implementação válido.
#
# Exemplo 1:
#
# #!/bin/bash
# # script: soma.sh
#
# source getopt.sh
#
# soma()
# {
#     # verifica os valores passados na função
#     getopt.parse 2 "x:int:+:$1" "y:int:+:$2" ${@:3}
#
#     echo $(($1+$2))
# }
#
# soma 10 20
# soma 10 af
# # FIM
#
# $ ./soma.sh
# 30
# ./teste.sh: erro: linha 14: soma: y: 'af' o argumento esperado é do tipo int
#
#
# Exemplo 2:
#
# # Protótipo da função variádica 'sum' que realiza a soma de todos os elementos e
# # que recebe uma quantidade indeterminada de argumentos inteiros.
#
# $ getopt.parse -1 "num:int:+:$1" ... "${@:2}"
#
# # O nome, flag e tipo dos argumentos variádicos subsequentes serão iguais ao 
# # argumento que precede as reticências '...'
#
function getopt.parse()
{
	local name ctype flag value flags attr param app vargs lparam rep
	
	if ! [[ $1 =~ ${__HASH_TYPE[getopt_nargs]} ]]; then
		error.__trace def "nargs" "int" "$1" "$__ERR_GETOPT_TYPE_ARG 'int'"
		return $?
	elif [[ $1 -eq -1 ]]; then
		vargs=1
	elif [[ $((${#@}-1)) -gt $1 ]]; then
		error.__trace exa '' '' "${*:$(($1+2))}" "$__ERR_GETOPT_TOO_MANY_ARGS"
		return $?
	fi

	if [[ ${FUNCNAME[1]} != getopt.@(nargs|args|params|values|value|type|flag) ]]; then
		 __GETOPT_PARSE=()
		app=1
	fi

	for param in "${@:2}" 
	do
		rep=${rep:+$lparam:$param}
		IFS=':' read name ctype flag value <<< "${rep:-$param}"
		
		if [[ ! $rep && $vargs && $param == ... ]]; then
			rep=_
			continue
		fi
		
		if ! [[ $name =~ ${__HASH_TYPE[getopt_pname]} ]]; then
			error.__trace def "name" 'str' "$name" "$__ERR_GETOPT_ARG_NAME"
			return $?
		elif ! [[ $flag =~ ${__HASH_TYPE[getopt_flag]} ]]; then
			error.__trace def "flag" 'str' "$flag" "$__ERR_GETOPT_FLAG"
			return $?
		elif [[ $flag == + && ! $value ]]; then
			error.__trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_ARG_REQUIRED"
			return $?
		fi

		if [[ $flag == + ]] || [[ $flag == - && $value ]]; then
			case $ctype in
				uint|int|zone|char|str| \
				bool|var|array| \
				bin|hex|oct|size| \
				12h|24h|date|hour| \
				min|sec|mday|mon| \
				year|yday|wday|url| \
				email|ipv4|ipv6|mac| \
				slice|uslice|funcname) [[ $value =~ ${__HASH_TYPE[$ctype]} ]];;
				map)		IFS=' ' read _ attr _ < <(declare -p $value 2>/dev/null); [[ $attr =~ A ]];;
   	        	func) 		declare -Fp "$value" &>/dev/null;;
				keyword) 	[[ $value == $name ]] || { error.__trace def "$name" "$ctype" "$value" "'$name' $__ERR_GETOPT_KEYWORD"; return $?; };;
				dir) 		[[ -d $value ]] || { error.__trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_DIR_NOT_FOUND"; return $?; };;
				file) 		[[ -f $value ]] || { error.__trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_FILE_NOT_FOUND"; return $?; };;
				path) 		[[ -e $value ]] || { error.__trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_PATH_NOT_FOUND"; return $?; };;
				fd) 		[[ -e /dev/fd/$value ]] || { error.__trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_FD_NOT_EXISTS"; return $?; };;
				type)		[[ ${__INIT_SRC_TYPES[$value]} ]];;
				*)			[[ ${__INIT_SRC_TYPES[$ctype]} ]] || { error.__trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_TYPE_INVALID"; return $?; }
							[[ ${__VAR_REG_LIST[$value]%%|*} == $ctype ]];;
   	    	esac || {
				error.__trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_TYPE_ARG '$ctype'"
				return $?
			}
		fi
		lparam="$name:$ctype:$flag"
		[[ $app ]] && __GETOPT_PARSE+=("$name:$ctype:$flag:$value")
	done
	
	return $?
}

# func getopt.nargs => [uint]
#
# Retorna o número de argumentos da função na chamada de 'getopt.parse'.
#
function getopt.nargs()
{ 
	getopt.parse 0 $@

	echo ${#__GETOPT_PARSE[@]}
	return 0
}

# func getopt.args => [str]
#
# Retorna o nome dos argumentos.
#
function getopt.args()
{
	getopt.parse 0 $@

	local arg
	for arg in "${__GETOPT_PARSE[@]}"; do
		IFS=':' read arg _ _ _ <<< "$arg"
		echo "$arg"
	done
}

# func getopt.values => [str]
#
# Retorna os valores dos argumentos.
#
function getopt.values()
{
	getopt.parse 0 $@
	
	local val
	for val in "${__GETOPT_PARSE[@]}"; do
		IFS=':' read _ _ _ val <<< "$val"
		echo "$val"
	done
}

# func getopt.value <[str]argname> => [str]
#
# Retorna o valor de 'argname'.
#
function getopt.value()
{
	getopt.parse 1 "argname:str:+:$1" ${@:2}
	getopt.__get_param $1 val
	return $?
}

# func getopt.type <[str]argname> => [str]
#
# Retorna o tipo suportado por 'argname'.
#
function getopt.type()
{
	getopt.parse 1 "argname:str:+:$1" ${@:2}
	getopt.__get_param $1 type
	return $?
}

# func getopt.flag <[str]argname> => [str]
#
# Retorna a flag de 'argname'.
#
function getopt.flag()
{
	getopt.parse 1 "argname:str:+:$1" ${@:2}
	getopt.__get_param $1 flag
	return $?
}

function getopt.__get_param()
{
	local param name val
	for param in "${__GETOPT_PARSE[@]}"; do
		IFS=':' read name _ _ _ <<< "$param"
		if [[ $1 == $name ]]; then
			case $2 in
				type) 	IFS=':' read _ val _ _ <<< "$param";;
				flag) 	IFS=':' read _ _ val _ <<< "$param";;
				val) 	IFS=':' read _ _ _ val <<< "$param";;
				*) return 1;;
			esac
			echo "$val"
			return 0
		fi
	done

	error.__trace def 'argname' 'str' "$1" "$__ERR_GETOPT_ARG_NAME"

	return $?
}

# func getopt.params => [str]
#
# Retorna os parâmetros da função em um formato utilizável.
#
function getopt.params()
{
	getopt.parse 0 $@

	local param name ctype flag
	for param in "${__GETOPT_PARSE[@]}"; do
		IFS=':' read name ctype flag _ <<< "$param"
		echo "$name:$ctype:$flag:"
	done
	return 0
}

source.__INIT__
# /* __GETOPT_SH */
