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

[[ $__GETOPT_SH ]] && return 0

readonly __GETOPT_SH=1

source builtin.sh

readonly __ERR_GETOPT_TYPE_ARG='o argumento esperado é do tipo'
readonly __ERR_GETOPT_FLAG='flag não suportada'
readonly __ERR_GETOPT_DIR_NOT_FOUND='diretório não encontrado'
readonly __ERR_GETOPT_FILE_NOT_FOUND='arquivo não encontrado'
readonly __ERR_GETOPT_PATH_NOT_FOUND='arquivo ou diretório não encontrado'
readonly __ERR_GETOPT_FD_NOT_EXISTS='o descritor do arquivo não existe'
readonly __ERR_GETOPT_TOO_MANY_ARGS='excesso de argumentos'
readonly __ERR_GETOPT_KEYWORD='operador/argumento requerido'
readonly __ERR_GETOPT_ARG_NAME='nome do argumento inválido'
readonly __ERR_GETOPT_ARG_REQUIRED='o argumento requerido'
readonly __ERR_GETOPT_INDEX_OUT_RANGE='comprimento inválido: o índice está fora do intervalo da matriz'
readonly __ERR_GETOPT_CTYPE='o tipo do argumento é inválido'
readonly __ERR_GETOPT_OBJ_ATTR='objeto inválido: o atributo do objeto é incompatível com o tipo requerido'

# func getopt.parse <[uint]nargs> <[str]name:type:flag:value> ... ${@:nargs+1} -> [bool]
#
#
# Trata a lista de parâmetros em 'name:type:flag:$N' verificando as configurações
# especificadas para cada argumento posicional e se possui 'N'args na chamada da função.
# 
# Retorna true se todos os argumentos satisfazem os critérios determinados, caso contrário
# retorna false e finaliza a função.
# 
#  nargs    - O total de argumentos requeridos. Utilize -1 para funções variáticas.
#  ${@:N+1} - Array de argumentos posicionais a partir do índice 'N+1', onde 'N' é o
#             número do último argumento posicional. (É recomendado especificá-lo para 
#             verificação da quantidade de argumentos recebidos para detecção de valores
#             excedidos. 
#  ...      - Argumentos variáticos, utilize somente quando 'nargs' for igual à -1. 
# 
# A configuração do argumento posicional é uma string contendo 4 parâmetros delimitados por 
# ':' (dois-pontos), que especifica a forma como o argumento é tratado na chamada da função 
# e que deve ser especificado no seguinte padrão: 
# 
# 'name:type:flag:$N'
# 
#  name - Nomenclatura do argumento. Caracteres suportados. [a-zA-Z0-9_=+-] 
#  type - O tipo de dado suportado pelo argumento. Pode ser uma 'Flag type', 'Struct' ou um 
#        'Objeto' de implementação válido. 
#  flag - Atributo de prioridade que especifica se é obrigatório ou opcional ([-\ +]). Use 
#         '-' (hífen) para opcional ou '+' para obrigatório. 
#  $N   - Argumento posicional ($1, $2, $3 ...) cujo valor será verificado com base no tipo
#         especificado. 
# 
# #### Flag type ####
# 
# O Flag type é um dado mapeado a partir de um expressão de comprimento variável cujo tipo 
# é determinado pela aplicação de um padrão (regex).
# 
# A nomenclatura indica o tipo de dado suportado pelo argumento cujo valor precisa atender
# aos critérios de validação.
# 
#  Flag/Critérios 
#
#  uint     - Inteiro sem sinal. 
#  int      - Inteiro com sinal. 
#  zone     - Fuso horário. 
#  char     - Caractere único. 
#  str      - Uma cadeia de caracteres. 
#  bool     - Booleano (true ou false). 
#  var      - Identificador de uma variável válida ou vetor. 
#  array    - Array indexado. 
#  map      - Array associativo. 
#  funcname - Nomenclatura de função válida. 
#| func     - Identificador de uma função válida. 
#  bin      - Número binário (base 2). 
#  hex      - Número hexadecimal (base 16). 
#  oct      - Número octal (base 8). 
#  size     - Unidade de armazenamento. (12KB, 1MB, 10G, 2TB ...) 
#  12h      - Hora no formato 12 horas. (HH:MM -> 1..12) 
#  24h      - Hora no formato 24 horas. (HH:MM -> 0..23) 
#  date     - Data no formato. (DD/MM/YYYY) 
#  hour     - Hora. (0..23) 
#  min      - Minutos. (0..59) 
#  sec      - Segundos. (0..59) 
#  mday     - Dia do mês. (1..31) 
#  mon      - Dia da semana. (1..12) 
#  year     - Ano. inteiro positivo com 4 ou mais dígitos.
#  yday     - Dias do ano. (1..366) 
#  wday     - Dias da semana. (1..7) 
#  url      - Endereço web. (http https ftp smtp)://.... 
#  email    - Endereço de email. 
#  ipv4     - protocolo ipv4 (32 bits) 
#  ipv6     - protocolo ipv6 (128 bits) 
#  mac      - Endereço MAC Address (xx:xx:xx:xx:xx:xx) 
#  slice    - Intervalo numérico. ([-]N:[-]N) 
#  uslice   - Intervalo numérico positivo (N:N) 
#  keyword  - Palavra chave que indica que 'type' tem que ser igual a 'name'. 
#  dir      - Diretório válido. 
#  file     - Arquivo padrão. 
#  path     - Caminho válido. 
#  fd       - Inteiro positivo que representa um descritor de arquivo. 
# 
#
# Exemplo 1:
# 
# Criando a função soma que recebe dois inteiros.
# 
# #!/bin/bash
# 
# source getopt.sh
# 
# soma()
# {
#     getopt.parse 2 "x:int:+:$1" "y:int:+:$2" "${@:3}"
# 
#     # Retorno da soma
#     echo $(($1+$2))
# }
# 
# # chama a função
# soma 10 20
#
# Saída:
#
# 30
# 
# Exemplo 2:
# 
# Criando uma função variática 'soma' que irá receber uma quantidade
# indeterminada de inteiros.
# 
# #!/bin/bash
# 
# source getopt.sh
# 
# soma(){
#     getopt.parse -1 "num:int:+:$1" ... "${@:2}"
# 
#     for num in $@; do
#         total=$((total+$num))
#     done
# 
#     echo "$total"
# }
# 
# # Chama a função
# soma 10 20 30 40 50 60 70 80
#
# Saída:
#
# 360
#
# O atributo do argumento posicional subsequente será igual ao atributo do
# último argumento especificado: "num:int:+:"
# 
# Exemplo 3:
# 
# Criando uma função que reverte a sequência de caracteres e que recebe como 
# argumento um objeto implementado por 'string_t'.
# 
# #!/bin/bash
# 
# source getopt.sh
# source string.sh
# 
# reverter(){
#     getopt.parse 1 "meu_objeto:string_t:+:$1" "${@:2}"
# 
#     # Chama o método 'reverse' do objeto.
#     $1.reverse
# }
# 
# # Implementa 'texto' com o tipo 'string_t'
# var texto string_t
# 
# texto='Seja Livre, use Linux !!'
# 
# # chama a função passando o objeto implementado.
# reverter texto
#
# Saída:
#
# !! xuniL esu ,erviL ajeS
#
# Se na chamada da função for especificado um objeto que não é implementado por
# 'string_t', será retornada uma mensagem de erro:
# 
# ------------------------
# (Pilha de rastreamento)
# Script: script.sh
# 
# Chamada interna: error.trace
# Função: getopt.parse
# 
# Pilha: [0:main] => [19:reverter]
# Argumento: <meu_objeto>
# Tipo: [string_t]
# Valor: 'texto'
# Erro: o argumento esperado é do tipo 'string_t'
# ------------------------
# 
function getopt.parse()
{
	local name ctype flag value flags attr param app vargs lparam rep re
	
	if ! [[ $1 =~ ${__FLAG_TYPE[getopt_nargs]} ]]; then
		error.trace def "nargs" "int" "$1" "$__ERR_GETOPT_TYPE_ARG 'int'"
		return $?
	elif [[ $1 -eq -1 ]]; then
		vargs=1
	elif [[ $((${#@}-1)) -gt $1 ]]; then
		error.trace exa '' '' "${*:$(($1+2))}" "$__ERR_GETOPT_TOO_MANY_ARGS"
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
		
		if ! [[ $name =~ ${__FLAG_TYPE[getopt_pname]} ]]; then
			error.trace def "name" 'str' "$name" "$__ERR_GETOPT_ARG_NAME"
			return $?
		elif ! [[ $ctype =~ ${__FLAG_TYPE[getopt_ctype]} ]]; then
			error.trace def  "ctype" "str" "$ctype" "$__ERR_GETOPT_CTYPE"
			return $?	
		elif ! [[ $flag =~ ${__FLAG_TYPE[getopt_flag]} ]]; then
			error.trace def "flag" 'str' "$flag" "$__ERR_GETOPT_FLAG"
			return $?
		elif [[ $flag == + && ! $value ]]; then
			error.trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_ARG_REQUIRED"
			return $?
		fi

		if [[ $flag == + ]] || [[ $flag == - && $value ]]; then
			case $ctype in
				map)		IFS=' ' read _ attr _ < <(declare -p $value 2>/dev/null); [[ $attr =~ A ]];;
				array)		IFS=' ' read _ attr _ < <(declare -p $value 2>/dev/null); [[ $attr =~ a ]];;
   	        	func) 		declare -Fp "$value" &>/dev/null;;
				keyword) 	[[ $value == $name ]] || { error.trace def "$name" "$ctype" "$value" "'$name' $__ERR_GETOPT_KEYWORD"; return $?; };;
				dir) 		[[ -d $value ]] || { error.trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_DIR_NOT_FOUND"; return $?; };;
				file) 		[[ -f $value ]] || { error.trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_FILE_NOT_FOUND"; return $?; };;
				path) 		[[ -e $value ]] || { error.trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_PATH_NOT_FOUND"; return $?; };;
				fd) 		[[ -e /dev/fd/$value ]] || { error.trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_FD_NOT_EXISTS"; return $?; };;
				*)	
					if [[ ${__FLAG_TYPE[$ctype]} ]]; then
						[[ $value =~ ${__FLAG_TYPE[$ctype]} ]]
					elif [[ ${__INIT_OBJ_TYPE[${value%%[*}]} == ${ctype%%[*} ]]; then
					
						local re_vet re_arr re_asz size tflag
	
						re_vet='^[^[]+$'
						re_arr='^[^[]+\[\]$'
						re_asz='^[^[]+\[([^]]+)\]$'

						if		[[ $ctype =~ $re_vet ]]; then tflag=vector
						elif	[[ $ctype =~ $re_arr ]]; then tflag=array
						elif	[[ $ctype =~ $re_asz ]]; then tflag=szarray; size=${BASH_REMATCH[1]}
						fi
						
						[[ $value =~ $re_asz ]] &&
						[[ ${BASH_REMATCH[1]} -ge ${__INIT_OBJ_SIZE[${value%%[*}]} ]] && {
								error.trace def  "$name" "$ctype" "$value" "$__ERR_GETOPT_INDEX_OUT_RANGE"
								return $?
						}
	
						case $tflag in
							vector)		[[ $value =~ $re_vet ]] &&
										[[ ${__INIT_OBJ_ATTR[${value%%[*}]} == var ]] ||
										[[ $value =~ $re_asz && ${__INIT_OBJ_ATTR[${value%%[*}]} == array ]];;
									
							array)		[[ ${__INIT_OBJ_ATTR[${value%%[*}]} == array ]] &&
										[[ $value =~ $re_vet ]];;

							szarray)	[[ $size -eq ${__INIT_OBJ_SIZE[${value%%[*}]} ]] &&
										[[ $value =~ $re_vet ]];;
						esac || {
							error.trace objp "$ctype" "$tflag" "$value" "$__ERR_GETOPT_OBJ_ATTR"
							return $?
						}
					else
						false
					fi
					;;
   	    	esac && {
				__ERR__=
				__ERR_STACK__=
				__ERR_ARG__=
				__ERR_TYPE__=
				__ERR_VAL__=
				__ERR_MSG__=
				__ERR_FUNC__=
				__ERR_LINE__=
				__ERR_ARGS__=
			} || {
				error.trace def "$name" "$ctype" "$value" "$__ERR_GETOPT_TYPE_ARG '$ctype'"
				return $?
			}			
		fi
		lparam="$name:$ctype:$flag"
		[[ $app ]] && __GETOPT_PARSE+=("$param")
	done

	
	return $?
}

# func getopt.nargs => [uint]
#
# Retorna o número de argumentos da função na chamada de 'getopt.parse'.
#
function getopt.nargs()
{ 
	getopt.parse 0 "$@"

	echo ${#__GETOPT_PARSE[@]}
	return 0
}

# func getopt.args => [str]
#
# Retorna o nome dos argumentos.
#
function getopt.args()
{
	getopt.parse 0 "$@"

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
	getopt.parse 0 "$@"
	
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
	getopt.parse 1 "argname:str:+:$1" "${@:2}"
	getopt.__get_param $1 val
	return $?
}

# func getopt.type <[str]argname> => [str]
#
# Retorna o tipo suportado por 'argname'.
#
function getopt.type()
{
	getopt.parse 1 "argname:str:+:$1" "${@:2}"
	getopt.__get_param $1 type
	return $?
}

# func getopt.flag <[str]argname> => [str]
#
# Retorna a flag de 'argname'.
#
function getopt.flag()
{
	getopt.parse 1 "argname:str:+:$1" "${@:2}"
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

	error.trace def 'argname' 'str' "$1" "$__ERR_GETOPT_ARG_NAME"

	return $?
}

# func getopt.params => [str]
#
# Retorna os parâmetros da função em um formato utilizável.
#
function getopt.params()
{
	getopt.parse 0 "$@"

	local param name ctype flag
	for param in "${__GETOPT_PARSE[@]}"; do
		IFS=':' read name ctype flag _ <<< "$param"
		echo "$name:$ctype:$flag:"
	done
	return 0
}

source.__INIT__
# /* __GETOPT_SH */
