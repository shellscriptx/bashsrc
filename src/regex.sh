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

[ -v __REGEX_SH__ ] && return 0

readonly __REGEX_SH__=1

source builtin.sh

readonly -A __REGEX__=(
[groupname]="\(\?<(${__BUILTIN__[objname]})>.+\)"
)

# .FUNCTION regex.compile <pattern[str]> -> [bool]
#
# Retorna 'true' se o padrão compilado satisfaz a sintaxe 
# POSIX da expressão regular estendida.
#
function regex.compile()
{
	getopt.parse 1 "pattern:str:$1" "${@:2}"
	
	[[ _ =~ $1 ]]
	[[ $? -eq 2 ]] && error.fatal "'$1' erro de sintaxe na expressão regular"

	return 0
}

# .FUNCTION regex.findall <pattern[str]> <expr[str]> -> [str]|[bool]
#
# Retorna uma lista de todas as correspondências não sobrepostas na cadeia.
#
function regex.findall()
{
	getopt.parse 2 "pattern:str:$1" "expr:str:$2" "${@:3}"
	
	local expr=$2
	
	while [[ $1 && $expr =~ $1 ]]; do
		echo "$BASH_REMATCH"
		expr=${expr/$BASH_REMATCH/}
	done

	return $?	
}

# .FUNCTION regex.fullmatch <pattern[str]> <expr[str]> <match[map]> -> [bool]
#
# Força o padrão a casar com a expressão inteira.
#
function regex.fullmatch()
{
	getopt.parse 3 "pattern:str:$1" "expr:str:$2" "match:map:$3" "${@:4}"

	local -n __ref__=$3

	__ref__=() || return 1
	
	if [[ $2 =~ ^$1$ ]]; then
		__ref__[start]=0
		__ref__[end]=${#BASH_REMATCH}
		__ref__[match]=$BASH_REMATCH
	fi
		
	return $?	
}

# .FUNCTION regex.match <pattern[str]> <expr[str]> <match[map]> -> [bool]
#
# Força o padrão a casar com a expressão inicial. 
#
function regex.match()
{
	getopt.parse 3 "pattern:str:$1" "expr:str:$2" "match:map:$3" "${@:4}"

	local -n __ref__=$3	

	__ref__=() || return 1

	if [[ $2 =~ ^$1 ]]; then
		__ref__[start]=0
		__ref__[end]=${#BASH_REMATCH}
		__ref__[match]=$BASH_REMATCH
	fi

	return $?	
}

# .FUNCTION regex.search <pattern[str]> <expr[str]> <match[map]> -> [bool]
#
# Busca uma correspondência do padrão na expressão.
#
function regex.search()
{
	getopt.parse 3 "pattern:str:$1" "expr:str:$2" "match:map:$3" "${@:4}"

	local __start__ __end__ __match__
	local __expr__=$2
	local -n __ref__=$3
	
	__ref__=() || return 1
	
	if [[ $__expr__ =~ $1 ]]; then
		__expr__=${__expr__%$BASH_REMATCH*}
		__ref__[start]=${#__expr__}
		__ref__[end]=$((${__ref__[start]}+${#BASH_REMATCH}))
		__ref__[match]=$BASH_REMATCH
	fi

	return $?
}

# .FUNCTION regex.split <pattern[str]> <expr[str]> -> [str]|[bool]
#
# Divide a string de origem pelas ocorrências do padrão, retornando uma lista 
# contendo as substrings resultantes.
#
function regex.split()
{
	getopt.parse 2 "pattern:str:$1" "expr:str:$2" "${@:3}"
	
	local expr=$2
	
	while [[ $1 && $expr =~ $1 ]]; do
		expr=${expr/$BASH_REMATCH/$'\n'}
	done

	echo "$expr"

	return $?	
}

# .FUNCTION regex.groups <pattern[str]> <expr[str]> -> [str]|[bool]
#
# Retorna uma lista de todos os grupos de captura presentes na ocorrência.
#
function regex.groups()
{
	getopt.parse 2 "pattern:str:$1" "expr:str:$2" "${@:3}"
	
	local expr=$2
	
	while [[ $expr =~ $1 && ${BASH_REMATCH[1]} ]]; do
		printf '%s\n' "${BASH_REMATCH[@]:1}"
		expr=${expr/$BASH_REMATCH/}
	done

	return $?	
}

# .FUNCTION regex.replace <pattern[str]> <expr[str]> <count[int]> <new[str]> -> [str]|[bool]
#
# Substitui 'N' ocorrências do padrão casado pela string especificada. 
# Se 'count < 0' aplica a substituição em todas as ocorrências.
#
function regex.replace()
{
	getopt.parse 4 "pattern:str:$1" "expr:str:$2" "count:int:$3" "new:str:$4" "${@:5}"

	local i c
	local expr=$2
	
	for ((i=0; i < ${#expr}; i++)); do
		[[ ${expr:$i} =~ $1 ]] || break
		if [[ ${expr:$i:${#BASH_REMATCH}} == $BASH_REMATCH ]]; then
			expr=${expr:0:$i}${4}${expr:$(($i+${#BASH_REMATCH}))}
			i=$(($i+${#4}-1))
			[[ $((++c)) -eq $3 ]] && break
		fi
	done
	
	echo "$expr"
	
	return $?
}

# .FUNCTION regex.fnreplace <pattern[str]> <expr[str]> <count[int]> <func[function]> <args[str]> ... -> [str]|[bool]
#
# Substitui 'N' ocorrências do padrão pelo retorno da função com 'N'args (opcional), passando como
# como argumento posicional '$1' o padrão casado. Se 'count < 0' aplica a substtiuição em todas as 
# ocorrências.
#
# == EXEMPLO ==
#
# source regex.sh
#
# dobrar()
# {
#     # Retorna o dobro do valor casado.
#     echo "$(($1*2))"
# }
# 
# expr='valor_a = 10, valor_b = 20, valor_c = 30'
#
# # Valor atual.
# echo "$expr"
# echo ---
#
# # Substitui somente os números contidos na expressão.
# regex.fnreplace '[0-9]+' "$expr" 1 dobrar    # 1ª ocorrência
# regex.fnreplace '[0-9]+' "$expr" 2 dobrar    # 1ª e 2ª ocorrência
# regex.fnreplace '[0-9]+' "$expr" -1 dobrar   # Todas
#
# == SAÍDA ==
#
# valor_a = 10, valor_b = 20, valor_c = 30
# ---
# valor_a = 20, valor_b = 20, valor_c = 30
# valor_a = 20, valor_b = 40, valor_c = 30
# valor_a = 20, valor_b = 40, valor_c = 60
#
function regex.fnreplace()
{
	getopt.parse -1 "pattern:str:$1" "expr:str:$2" "count:int:$3" "func:function:$4" "args:str:$5" ... "${@:6}"

	local new i c
	local expr=$2
	
	for ((i=0; i < ${#expr}; i++)); do
		[[ ${expr:$i} =~ $1 ]] || break
		if [[ ${expr:$i:${#BASH_REMATCH}} == $BASH_REMATCH ]]; then
			new=$($4 "$BASH_REMATCH" "${@:5}")
			expr=${expr:0:$i}${new}${expr:$(($i+${#BASH_REMATCH}))}
			i=$(($i+${#new}-1))
			[[ $((++c)) -eq $3 ]] && break
		fi
	done

	echo "$expr"

	return $?
}

# .FUNCTION regex.fnreplacers <pattern[str]> <expr[str]> <count[int]> <func[function]> -> [str]|[bool]
#
# Retorna uma string substituindo 'N' ocorrências do padrão pelo retorno da função, passando os grupos 
# casados como argumentos posicionais. Se 'count < 0' aplica a substituição em todas as ocorrências.
#
# Exemplo:  ([a-z]+)([A-Z]+)([0-9])  ... (...)
#              |       |       |           |
#            grupo1  grupo2  grupo3  ... grupoN
#              |       |       |           |
#   func   $1      $2      $3          $N
#
# > Chama a função se pelo menos um grupo de captura estiver presente.
#
# == EXEMPLO ==
#
# source regex.sh
#
# grupos()
# {
#     # Retorna a ordem invertida dos grupos de captura.
#     #
#     # $1 = '16'
#     # $2 = ' de julho de '
#     # $3 = '1993'
#     echo "${3}${2}${1}"
# }
#
# texto='Slackware é uma distribuição Linux lançada em 16 de julho de 1993 por Patrick Volkerding'
#
# echo "$texto"
# regex.fnreplacers "([0-9]+)(.+\s+)([0-9]+)" "$texto" -1 grupos
#
# == SAÍDA ==
#
# Slackware é uma distribuição Linux lançada em 16 de julho de 1993 por Patrick Volkerding
# Slackware é uma distribuição Linux lançada em 1993 de julho de 16 por Patrick Volkerding
#
function regex.fnreplacers()
{
	getopt.parse 4 "pattern:str:$1" "expr:str:$2" "count:int:$3" "func:function:$4" "${@:5}"

	local new i c
	local expr=$2
	
	for ((i=0; i < ${#expr}; i++)); do
		[[ ${expr:$i} =~ $1 ]] || break
		if [[ ${expr:$i:${#BASH_REMATCH}} == $BASH_REMATCH && ${BASH_REMATCH[1]} ]]; then
			new=$($4 "${BASH_REMATCH[@]:1}")
			expr=${expr:0:$i}${new}${expr:$(($i+${#BASH_REMATCH}))}
			i=$(($i+${#new}-1))
			[[ $((++c)) -eq $3 ]] && break
		fi
	done

	echo "$expr"

	return $?
}

# .FUNCTION regex.expand <pattern[str]> <expr[str]> <template[str]> -> [str]|[bool]
#
# Expande o grupo nomeado para o seu padrão casado no modelo especificado.
# O padrão para definição de nomenclatura de grupo deve respeitar a seguinte sintaxe:
#
# (?<group_name>regex) ...
#
# group_name - Identificador do grupo cujo caracteres suportados são: '[a-zA-Z0-9_]' e
#              precisa iniciar com pelo menos uma letra ou underline '_'. 
# regex      - Expressão regular estendida.
#
# > Pode ser especificado mais de um grupo.
#
# O modelo é uma cadeia de caracteres que compõe a formatação dos grupos
# nomeados cuja expansão é aplicada ao seu identificador representado pela
# sintaxe:
#
# <group_name>
#
# == EXEMPLO ==
#
# source regex.sh
#
# # Modelo.
# modelo=$(cat << _eof
# Nome: <nome>
# Sobrenome: <sobrenome>
# Idade: <idade>
# Cidade: <cidade>
# Estado: <estado>
# _eof
# )
#
# Dados a serem extraidos.
# dados='Fernanda,Santos,30,Volta Redonda,RJ'
#
# # Expressão regular que define os grupos nomeados para cada campo.
# re='^(?<nome>\w+),(?<sobrenome>\w+),(?<idade>[0-9]+),(?<cidade>[a-zA-Z0-9 ]+),(?<estado>[a-zA-Z]{2})$'
#
# # Retorna o modelo expandindo os padrões casados.
# regex.expand "$re" "$dados" "$modelo"
#
# == SAÍDA ==
#
# Nome: Fernanda
# Sobrenome: Santos
# Idade: 30
# Cidade: Volta Redonda
# Estado: RJ
#
function regex.expand()
{
	getopt.parse 3 "pattern:str:$1" "expr:str:$2" "template:str:$3" "${@:4}"

	local name names i
	local pattern=$1
	local template=$3

	# Extrai os nomes associados as expressões do grupo.
	while [[ $pattern =~ ${__REGEX__[groupname]} ]]; do
		# Anexa o nome e atualiza a expressão para o padrão POSIX ERE
		# removendo os identificadores.
		names+=(${BASH_REMATCH[1]})
		pattern=${pattern/\?<${BASH_REMATCH[1]}>/}
	done

	if [[ $2 =~ $pattern ]]; then
		for name in ${names[@]}; do
			# Substitui os nomes por suas respectivas ocorrêncicas.
			template=${template//<$name>/${BASH_REMATCH[$((++i))]}}
		done
	fi

	echo "$template"

	return $?
}

# .FUNCTION regex.exportnames <pattern[str]> <expr[str]> -> [bool]
#
# Exporta os grupos nomeados e atribui os padrões casados.
# O padrão para definição de nomenclatura de grupo deve respeitar a seguinte sintaxe:
#
# (?<group_name>regex) ...
#
# group_name - Identificador do grupo cujo caracteres suportados são: '[a-zA-Z0-9_]' e
#              precisa iniciar com pelo menos uma letra ou underline '_'.
# regex      - Expressão regular estendida.
#
# > Pode ser especificado mais de um grupo.
#
# == EXEMPLO ==
#
# source regex.sh
#
# dados='Patrick Volkerding'
#
# regex.exportnames '(?<nome>\w+) (?<sobrenome>\w+)' "$dados"
#
# echo "Nome:" $nome
# echo "Sobrenome:" $sobrenome
#
# == SAÍDA ==
#
# Nome: Patrick
# Sobrenome: Volkerding
#
function regex.exportnames()
{
	getopt.parse 2 "pattern:str:$1" "expr:str:$2" "${@:3}"

	local __name__ __names__ __i__
	local __pattern__=$1
	
	while [[ $__pattern__ =~ ${__REGEX__[groupname]} ]]; do
		__names__+=(${BASH_REMATCH[1]})
		__pattern__=${__pattern__/\?<${BASH_REMATCH[1]}>/}
	done

	if [[ $2 =~ $__pattern__ ]]; then
		for __name__ in ${__names__[@]}; do
			# Atribui o valor ao identificador.
			printf -v $__name__ "${BASH_REMATCH[$((++__i__))]}"
		done
	fi

	return $?
}

# .MAP match
#
# Chaves:
#
# start
# end
# match
#

# .TYPE regex_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.compile
# S.findall
# S.fullmatch
# S.match
# S.search
# S.split
# S.groups
# S.replace
# S.fnreplace
# S.fnreplacers
# S.expand
# S.exportnames
#
typedef regex_t				\
		regex.compile 		\
		regex.findall		\
		regex.fullmatch		\
		regex.match			\
		regex.search		\
		regex.split			\
		regex.groups		\
		regex.replace		\
		regex.fnreplace		\
		regex.fnreplacers	\
		regex.expand		\
		regex.exportnames

readonly -f regex.compile 		\
			regex.findall		\
			regex.fullmatch		\
			regex.match			\
			regex.search		\
			regex.split			\
			regex.groups		\
			regex.replace		\
			regex.fnreplace		\
			regex.fnreplacers	\
			regex.expand		\
			regex.exportnames

# /* __REGEX_SH__ */
