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

[ -v __GETOPT_SH__ ] && return 0

readonly __GETOPT_SH__=1

source builtin.sh

# Protótipos.
readonly -A __GETOPT__=(
[parse]='\bgetopt\.parse\s-?[0-9]+\s"[^:]+:'
[arg]=${__BUILTIN__[varname]}
[type]=${__BUILTIN__[vartype]}
[nargs]='^(-1|0|[1-9][0-9]*)$'
[funcs]='^getopt\.(n?args|values?|types?|params)$'
)

# Global
declare -ag __GETOPT_PARSE__

# .FUNCTION getopt.parse <nargs[int]> <arg[str]> ... -> [bool]
#
# Define e processa 'N' argumentos posicionais na linha de comando.
# Retorna 'true' se todos os argumentos satisfazem os tipos estabelecidos,
# caso contrário retorna 'false' e finaliza o script com status '1'.
#
# nargs - Número de argumentos suportados.
#         Se 'nargs = -1' ativa o suporte a argumentos variádicos. Utilize
#         '...' para determinar o argumento posicional variádico.
#
# O argumento passado na função é constituído por uma cadeia de caracteres 
# que determina o nome, tipo e valor do argumento posicional a ser
# processado, e que precisa respeitar a seguinte sintaxe:
#
# arg:type:value
#
# arg   - Nome do argumento posicional cujo caracteres suportados são: '[a-zA-Z0-9_]'
#         e deve iniciar com pelo menos uma letra ou underline '_'.
# type  - Tipo do dado suportado pelo argumento. O identificador deve ser um objeto
#         válido ou um tipo 'builtin'.
# value - Valor do argumento posicional.
#
# Tipos (builtin):
#
# bool     - true ou false.
# str      - Uma cadeia de caracteres.
# char     - Um caractere.
# int      - Inteiro.
# uint     - Inteiro positivo (sem sinal).
# float    - Números com valor de ponto flutuante.
# var      - Identificador de uma variável.
# array    - Identificador de um array válido.
# map      - Identificador de um array associativo válido.
# function - Identificador de uma função válida.
#
# Exemplos:
# 
# -- PADRÃO --
#
#                          argumentos posicionais
#                                    |
#                            -----------------
#                            |               |
# getopt.parse 2 "arg1:type1:$1" "arg2:type2:$2" "${@:3}"
#              |                                     |
#            total                               argumentos
#          argumentos                            subsequentes
#                                                (total + 1)
#
# -- VARIÁDICA --
#
# getopt.parse -1 "arg1:type1:$1" "arg2:type2:$2" ... "${@:3}"
#               |                   |     |        |      |
#           variádica               ----------------      |
#                                           |             |
#                                       argumento     argumentos
#                                       variádico     subsequentes
#         
# > Os argumentos subsequentes ao variático herdão seus atributos (exceto: valor).
#
function getopt.parse()
{
	local arg args ntype type val param flag vparam vp fl

	[[ $1 =~ ${__GETOPT__[nargs]}	]]	|| error.fatal "'$1' número de argumentos inválido"
	[[ $1 -ge 0 && $((${#@}-1)) -gt $1		]] 	&& error.fatal "'${*:$1+2}' excesso de argumentos"

	# Limpa memória. (exceto: funções 'getopt')
	[[ ${FUNCNAME[1]} =~ ${__GETOPT__[funcs]} ]] || __GETOPT_PARSE__=()

	# Lê os argumentos posicionais.
	for param in "${@:2}"; do
		# Se a função conter argumentos variáticos, define o argumento atual
		# com os atributos do último argumento.
		[[ $vp 							]] && param=$vparam:$param
		[[ $param == ... && $1 -eq -1	]] && vp=1 && continue		# Define a função como variática.

		IFS=':' read -r arg ntype val <<< "$param"
	
		[[ ! $vp && $arg == @($args) ]] && error.fatal "'$arg' conflito de argumentos"
		
		# Extrai tipo.
		type=${ntype%%[*}

		[[ $arg		=~ ${__GETOPT__[arg]}				]]	|| error.fatal "'$arg' nome do argumento inválido"
		[[ $ntype   =~ ${__GETOPT__[type]}  			]]  || error.fatal "'$ntype' erro de sintaxe"
		[[ $type 	== @(${__ALL_TYPE_NAMES__// /|})	]]	|| error.fatal "'$type' tipo do objeto desconhecido"

		# Flag de validação.
		flag=${__BUILTIN_TYPES__[$type]}
	
		# Avalia o valor do argumento com base no tipo especificado.
		case $type in
			# Insira aqui os tipos especiais que requerem premissas de avaliação e critérios 
			# que determinam o tipo do objeto. É dado como válido se o retorno de status da
			# última instrução for 'verdadeira', caso contrário uma mensagem de erro é 
			# apresentada e a rotina finalizada com status 1.
			var)		[[ $val =~ ${__BUILTIN__[vartype]} ]];;
			array)		IFS=' ' read _ fl _ <<< $(declare -p $val 2>/dev/null); [[ $fl == *a* ]];;
			map)		IFS=' ' read _ fl _ <<< $(declare -p $val 2>/dev/null); [[ $fl == *A* ]];;
			function) 	[[ $type == $(type -t $val) ]];;
			*)			if [[ $flag && $val =~ $flag ]]; then :
						elif [[ $type == ${__OBJ_INIT__[${val:--}]%%|*} ]]; then
							[[ $ntype =~ ${__GETOPT__[type]} ]]
							[[ ! ${BASH_REMATCH[2]} 	&& $(sizeof $val) -eq 0	]]	||
							[[ ${BASH_REMATCH[2]} == [] && $(sizeof $val) -gt 0 ]] 	||
							[[ ${BASH_REMATCH[3]} == $(sizeof $val) 			]]
						else false
						fi
						;;
		esac || error.fatal "<$arg[$ntype]>: '$val' tipo do dado inválido"
	
		# Salva a linha de comando.
		__GETOPT_PARSE__+=("$param")

		# Salva atributos.
		vparam=$arg:$type
		args+=${args:+|}${arg}
	done

	return $?
}

# .FUNCTION getopt.nargs -> [uint]|[bool]
#
# Retorna o total de argumentos
#
function getopt.nargs()
{
	getopt.parse 0 "$@"

	echo ${#__GETOPT_PARSE__[@]}
	return $?
}

# .FUNCTION getopt.args -> [str]|[bool]
# 
# Retorna o nome dos argumentos posicionais.
#
function getopt.args()
{
	getopt.parse 0 "$@"
	
	local param arg
	for param in "${__GETOPT_PARSE__[@]}"; do
		IFS=':' read arg _ _ <<< "$param"
		echo "$arg"
	done
	return $?
}

# .FUNCTION getopt.types -> [str]|[bool]
#
# Retorna o tipo dos argumentos posicionais.
#
function getopt.types()
{
	getopt.parse 0 "$@"
	
	local param type
	for param in "${__GETOPT_PARSE__[@]}"; do
		IFS=':' read _ type _ <<< "$param"
		echo "$type"
	done
	return $?
}

# .FUNCTION getopt.values -> [str]|[bool]
#
# Retorna o valor dos argumentos posicionais.
#
function getopt.values()
{
	getopt.parse 0 "$@"
	
	local param val
	for param in "${__GETOPT_PARSE__[@]}"; do
		IFS=':' read -r _ _ val <<< "$param"
		echo "$val"
	done
	return $?
}

# .FUNCTION getopt.params -> [str|str]|[bool]
#
# Retorna uma string com os atributos dos argumentos
# posicionais no seguinte formato:
#
# arg|type
#
function getopt.params()
{
	getopt.parse 0 "$@"
	
	local param arg type
	for param in "${__GETOPT_PARSE__[@]}"; do
		IFS=':' read arg type _ <<< "$param"
		echo "$arg|$type"
	done
	return $?
}

# .FUNCTION getopt.value <argname[str]> -> [str]|[bool]
#
# Retorna o valor do argumento especificado.
#
function getopt.value()
{
	getopt.parse 1 "argname:str:$1" "${@:2}"

	local param arg val
	for param in "${__GETOPT_PARSE__[@]}"; do
		IFS=':' read -r arg _ val  <<< "$param"
		[[ $arg == $1 ]] && echo "$val"
	done
	return $?
}

# .FUNCTION getopt.type <argname[str]> -> [str]|[bool]
#
# Retorna o tipo do argumento especificado.
#
function getopt.type()
{
	getopt.parse 1 "argname:str:$1" "${@:2}"

	local param arg type
	for param in "${__GETOPT_PARSE__[@]}"; do
		IFS=':' read arg type _  <<< "$param"
		[[ $arg == $1 ]] && echo "$type"
	done
	return $?
}

readonly -f getopt.parse	\
			getopt.nargs	\
			getopt.args		\
			getopt.types	\
			getopt.values	\
			getopt.params	\
			getopt.value	\
			getopt.type

# /* __GETOPT_SH__ */
