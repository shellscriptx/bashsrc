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

[[ $__REGEX_SH ]] && return 0

readonly __REGEX_SH=1

source builtin.sh
source string.sh

__TYPE__[regex_t]='
regex.findall
regex.fullmatch 
regex.match 
regex.search 
regex.split 
regex.ismatch 
regex.groups
regex.fngroups
regex.fnngroups
regex.savegroups 
regex.replace
regex.nreplace 
regex.fnreplace 
regex.fnnreplace
'

# errors
readonly __ERR_REGEX_FLAG_INVALID='a flag especificada é inválida'
readonly __ERR_REGEX_GROUP_REF='referência do grupo inválida'

# func regex.findall <[str]pattern> <[str]exp> <[bool]case> => [str]|[str] ...
#
# Retorna uma lista de todas as correspondências não sobrepostas na cadeia.
#
# Se um ou mais grupos de captura estiverem presentes no padrão, é retornado
# uma lista de grupos no seguinte padrão:
#
# Exemplo: fullmatch|group1|group2|...
#
function regex.findall()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "case:bool:+:$3" ${@:4}
	
	local def cur exp match

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $3 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch

	while read exp; do
		while [[ $exp =~ $1 ]]; do
			exp=${exp/${BASH_REMATCH}/}
			printf -v match '%s|' "${BASH_REMATCH[@]}"
			echo "${match%|}"
		done
	done <<< "$2"
	
	shopt -q${cur} nocasematch

	return 0
}

# func regex.fullmatch <[str]pattern> <[str]exp> <[bool]case> => [uint]|[uint]|[str]
#
# Força 'pattern' a coincidir com toda sequência em 'exp', retornado o intervalo e a
# string da ocorrência. 
#
function regex.fullmatch()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "case:bool:+:$3" ${@:4}

	local def cur exp

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $3 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch

	while read exp; do
		[[ $exp =~ ^$1$ ]] && echo "0|${#BASH_REMATCH}|$BASH_REMATCH"
	done <<< "$2"

	shopt -q${cur} nocasematch
	
	return 0
}

# func regex.match <[str]pattern> <[str]exp> <[bool]case> => [uint]|[uint]|[str]
#
# Aplica o padrão no inicio da string retornando a expressão se coincidir ou
# nulo se não for encontrado.
#
function regex.match()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "case:bool:+:$3" ${@:4}
	
	local def cur exp

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $3 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch

	while read exp; do
		[[ $exp =~ ^$1 ]] && echo "0|${#BASH_REMATCH}|$BASH_REMATCH"
	done <<< "$2"

	shopt -q${cur} nocasematch

	return 0
}

# func regex.search <[str]pattern> <[str]exp> <[bool]case> => [uint]|[uint]|[str]
#
# Busca uma correspondência do padrão 'pattern' em 'exp', retornando o índice de
# intervalo do objeto da correspondência ou nulo se não houver.
#
# A correspondência é retornada no seguinte padrão:
#
# Retorno: start|end|match
#
function regex.search()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "case:bool:+:$3" ${@:4}

	local exp tmp old s e def cur

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $3 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch
	
	while read exp; do
		old=$exp
		while [[ $exp =~ $1 ]]; do
			tmp=${old#*${BASH_REMATCH}}
			e=$((${#old}-${#tmp}))
			s=$((e-${#BASH_REMATCH}))
			exp=${exp/${BASH_REMATCH}/}
			echo "$s|$e|${BASH_REMATCH}"
		done
	done <<< "$2"

	shopt -q${cur} nocasematch
	
	return 0
}

# func regex.split <[str]pattern> <[str]exp> <[bool]case> => [str]
#
# Divide a string 'exp' pela ocorrências do padrão, retornando uma lista contendo as substrings resultantes.
#
# Exemplo: substring1|substring2|substring3|...
#
function regex.split()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "case:bool:+:$3" ${@:4}
		
	local def cur exp old

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $3 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch

	while read exp; do
		old=$exp
		while [[ $exp =~ $1 ]]; do
			exp=${exp/${BASH_REMATCH}/}
			old=${old/${BASH_REMATCH}/\\n}
		done
		echo -e "$old"
	done <<< "$2"

	shopt -q${cur} nocasematch
	
	return 0
}

# func regex.ismatch <[str]pattern> <[str]exp> <[bool]case> => [bool]
#
# Retorna 'true' se o padrão coincidir em 'exp', caso contrário retorna 'false'.
#
function regex.ismatch()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "case:bool:+:$3" ${@:4}

	local exp def cur r

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $3 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch

	while read exp; do
		[[ $exp =~ $1 ]] && { r=0; break; }
	done <<< "$2"

	shopt -q${cur} nocasematch

	return ${r:-1}
}

# func regex.groups <[str]pattern> <[str]exp> <[bool]case> => [str]
#
# Retorna uma lista de grupos de captura se presentes no padrão.
#
function regex.groups()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "case:bool:+:$3" ${@:4}

	local grp exp def cur

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $3 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch
	
	while read exp; do
		while [[ $exp =~ $1 ]]; do
			printf -v grp '%s|' "${BASH_REMATCH[@]:1}"
			exp=${exp/${BASH_REMATCH}/}
			echo "${grp%|}"
		done
	done <<< "$2"

	shopt -q${cur} nocasematch

	return 0
}

# func regex.fngroups <[str]pattern> <[str]exp> <[str]new> <[int]count> <[bool]case> <[func]funcname> <[str]args> ... => [str] 
#
# Substitui os retrovisores dos grupos de captura em 'new' pelo retorno de 'funcname' em 'count' ocorrências. Se 'count' for
# igual a '-1' realiza a substituição em todas as ocorrências.
# Chama 'funcname' passando como argumento posicional '$1' o grupo de captura se presente com 'N'args (opcional) a cada 
# ocorrência de 'pattern' em 'exp', subsituindo os retrovisores  &, \\1, \\2, \\3 ... pelo retorno da função.
# Toda a ocorrência incluindo os grupos de captura são representados pelo caractere '&' e que também é passado como argumento.
#
# A função é chamada somente se o grupo de captura estiver presente ou '&' for especificado.
#
function regex.fngroups()
{
	getopt.parse -1 "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:int:+:$4" "case:bool:+:$5" "funcname:func:+:$6" "args:str:-:$7" ... "${@:8}"

	local exp new c i

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $5 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch
	
	while read exp; do
		c=0
		for ((i=0; i < ${#exp}; i++)); do
			[[ ${exp:$i} =~ $1 ]] || break
			if [[ ${exp:$i:${#BASH_REMATCH}} == ${BASH_REMATCH} ]]; then
				new=${3//&/$($6 "${BASH_REMATCH}" "${@:7}")}
				if [[ ${#BASH_REMATCH[@]} -eq 2 ]]; then
					new=${new//\\1/$($6 "${BASH_REMATCH[1]}" "${@:7}")}
				elif [[ ${#BASH_REMATCH[@]} -gt 2 ]]; then
					for n in ${!BASH_REMATCH[@]}; do
						new=${new//\\$((n+1))/$($6 "${BASH_REMATCH[$((n+1))]}" "${@:7}")}
					done
				fi
				exp=${exp:0:$i}${new}${exp:$(($i+${#BASH_REMATCH}))}
				i=$(($i+${#new}-1))
				[[ $((++c)) -eq $4 || ${1:0:1} == ^ ]] && break
			fi
		done
		echo "$exp"
	done <<< "$2"

	shopt -q${cur} nocasematch

	return 0
	
}

# func regex.fnngroups <[str]pattern> <[str]exp> <[str]new> <[uint]match> <[bool]case> <[func]funcname> <[str]args> ... => [str] 
#
# Substitui os retrovisores dos grupos de captura em 'new' pelo retorno de 'funcname' em 'match' ocorrência.
# Chama 'funcname' passando como argumento posicional '$1' o grupo de captura se presente com 'N'args (opcional) 
# Toda a ocorrência incluindo os grupos de captura são representados pelo caractere '&' e que também é passado como argumento.
#
# A função é chamada somente se o grupo de captura estiver presente ou '&' for especificado.
#
function regex.fnngroups()
{
	getopt.parse -1 "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:uint:+:$4" "case:bool:+:$5" "funcname:func:+:$6" "args:str:-:$7" ... "${@:8}"

	local exp new c i

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $5 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch
	
	while read exp; do
		c=0
		for ((i=0; i < ${#exp}; i++)); do
			[[ ${exp:$i} =~ $1 ]] || break
			if [[ ${exp:$i:${#BASH_REMATCH}} == ${BASH_REMATCH} ]]; then
				if [[ $((++c)) -eq $4 ]]; then
					new=${3//&/$($6 "${BASH_REMATCH}" "${@:7}")}
					if [[ ${#BASH_REMATCH[@]} -eq 2 ]]; then
						new=${new//\\1/$($6 "${BASH_REMATCH[1]}" "${@:7}")}
					elif [[ ${#BASH_REMATCH[@]} -gt 2 ]]; then
						for n in ${!BASH_REMATCH[@]}; do
							new=${new//\\$((n+1))/$($6 "${BASH_REMATCH[$((n+1))]}" "${@:7}")}
						done
					fi
					exp=${exp:0:$i}${new}${exp:$(($i+${#BASH_REMATCH}))}
					i=$(($i+${#new}-1))
				fi
			fi
		done
		echo "$exp"
	done <<< "$2"

	shopt -q${cur} nocasematch

	return 0
	
}
# func regex.savegroups <[str]pattern> <[str]exp> <[bool]case> <[array]name>
#
# Salva os grupos de captura ou ocorrências casadas em array 'name'.
#
function regex.savegroups()
{
	getopt.parse 4 "pattern:str:+:$1" "exp:str:-:$2" "case:bool:+:$3" "dest:array:+:$4" "${@:5}"
	
	declare -n __byref=$4
	local __def __cur __exp

	shopt -q nocasematch && __cur='s' || __cur='u'
	[[ $3 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch
	
	while read __exp; do
		while [[ $__exp =~ $1 ]]; do
			__byref+=("${BASH_REMATCH[@]:1}")
			__exp=${__exp/${BASH_REMATCH}/}
		done
	done <<< "$2"

	shopt -q${__cur} nocasematch

	return 0
}

# func regex.replace <[str]pattern> <[str]exp> <[str]new> <[int]count> <[bool]case> => [str]
#
# Substitui 'count' vezes o padrão em 'pattern' por 'new'. Se 'count' for igual à '-1',
# aplica a substituição em todas as ocorrências. A expressão em 'pattern' pode ser uma ERE 
# (expressão regular estendida), podendo utilizar retrovisores '&, \\1, \\2, \\3 ...' em 'new' se
# grupos de captura estiverem presentes entre parenteses '(...)'.
#
function regex.replace()
{
	getopt.parse 5 "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:int:+:$4" "case:bool:+:$5" "${@:6}"

	local exp new i n c def

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $5 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch
	
	while read exp; do
		c=0
		for ((i=0; i < ${#exp}; i++)); do
			[[ ${exp:$i} =~ $1 ]] || break
			if [[ ${exp:$i:${#BASH_REMATCH}} == ${BASH_REMATCH} ]]; then
				new=${3//&/${BASH_REMATCH}}
				if [[ ${#BASH_REMATCH[@]} -eq 2 ]]; then
					new=${new//\\1/${BASH_REMATCH[1]}}
				elif [[ ${#BASH_REMATCH[@]} -gt 2 ]]; then
					for n in ${!BASH_REMATCH[@]}; do
						new=${new//\\$((n+1))/${BASH_REMATCH[$((n+1))]}}
					done
				fi
				exp=${exp:0:$i}${new}${exp:$(($i+${#BASH_REMATCH}))}
				i=$(($i+${#new}-1))
				[[ $((++c)) -eq $4 || ${1:0:1} == ^ ]] && break
			fi
		done
		echo "$exp"
	done <<< "$2"

	return 0
}
	
# func regex.nreplace <[str]pattern> <[str]exp> <[str]new> <[uint]match> <[bool]case> => [str]
#
# Substitui 'pattern' por 'new' em 'match' ocorrência. A expressão em 'pattern' pode ser uma ERE 
# (expressão regular estendida), podendo utilizar retrovisores '\\1, \\2, \\3 ...' em 'new' se
# grupos de captura estiverem presentes entre parenteses '(...)'.
#
function regex.nreplace()
{
	getopt.parse 5 "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:uint:+:$4" "case:bool:+:$5" "${@:6}"

	local exp new i n c

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $5 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch

	while read exp; do
		c=0
		for ((i=0; i < ${#exp}; i++)); do
			[[ ${exp:$i} =~ $1 ]] || break
			if [[ ${exp:$i:${#BASH_REMATCH}} == ${BASH_REMATCH} ]]; then
				if [[ $((++c)) -eq $4 ]]; then
					new=${3//&/${BASH_REMATCH}}
					if [[ ${#BASH_REMATCH[@]} -eq 2 ]]; then
						new=${new//\\1/${BASH_REMATCH[1]}}
					elif [[ ${#BASH_REMATCH[@]} -gt 2 ]]; then
						for n in ${!BASH_REMATCH[@]}; do
							new=${new//\\$((n+1))/${BASH_REMATCH[$((n+1))]}}
						done
					fi
					exp=${exp:0:$i}${new}${exp:$(($i+${#BASH_REMATCH}))}
					i=$(($i+${#new}-1))
				fi
			fi
		done
		echo "$exp"
	done <<< "$2"

	return 0
}

# func regex.fnreplace <[str]pattern> <[str]exp> <[int]count> <[bool]case> <[func]funcname> <[str]args> ... => [str]
#
# Substitui 'count' vezes o padrão em 'pattern' pelo retorno de 'funcname', cujo identificador é uma 
# função válida que é chamada e recebe automaticamente como argumento posicional '$1' o padrão casado e
# com N'args' (opcional). 
# Se 'count' for igual à '-1' aplica em todas as ocorrências.
# A expressão em 'pattern' pode ser uma ERE (expressão regular estendida).
#
function regex.fnreplace()
{
	getopt.parse -1 "pattern:str:+:$1" "exp:str:-:$2" "count:int:+:$3" "case:bool:+:$4" "funcname:func:+:$5" "args:str:-:$6" ... "${@:7}"

	local exp new c i

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $4 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch

	while read exp; do
		c=0
		for ((i=0; i < ${#exp}; i++)); do
			[[ ${exp:$i} =~ $1 ]] || break
			if [[ ${exp:$i:${#BASH_REMATCH}} == ${BASH_REMATCH} ]]; then
				new=$($5 "$BASH_REMATCH" "${@:6}")
				exp=${exp:0:$i}${new}${exp:$(($i+${#BASH_REMATCH}))}
				i=$(($i+${#new}-1))
				[[ $((++c)) -eq $3 || ${1:0:1} == ^ ]] && break
			fi
		done
		echo "$exp"
	done <<< "$2"

	return 0
}

# func regex.fnnreplace <[str]pattern> <[str]exp> <[uint]match> <[bool]case> <[func]funcname> <[str]args> ... => [str]
#
# Substitui o padrão em 'pattern' pelo retorno de 'funcname' em 'match' ocorrência. 'funcname' é o
# identificador de uma função válida que é chamada e recebe automaticamente como argumento
# posicional '$1' o padrão casado e com N'args' (opcional). 
# A expressão em 'pattern' pode ser uma ERE (expressão regular estendida).
#
function regex.fnnreplace()
{
	getopt.parse -1 "pattern:str:+:$1" "exp:str:-:$2" "count:uint:+:$3" "case:bool:+:$4" "funcname:func:+:$5" "args:str:-:$6" ... "${@:7}"

	local exp new i c

	shopt -q nocasematch && cur='s' || cur='u'
	[[ $4 == true ]] && def='u' || def='s'
	shopt -q${def} nocasematch

	while read exp; do
		c=0
		for ((i=0; i < ${#exp}; i++)); do
			[[ ${exp:$i} =~ $1 ]] || break
			if [[ ${exp:$i:${#BASH_REMATCH}} == ${BASH_REMATCH} ]]; then
				if [[ $((++c)) -eq $3 ]]; then
					new=$($5 "$BASH_REMATCH" "${@:6}")
					exp=${exp:0:$i}${new}${exp:$(($i+${#BASH_REMATCH}))}
					i=$(($i+${#new}-1))
				fi
			fi
		done
		echo "$exp"
	done <<< "$2"

	return 0
}

source.__INIT__
# /* __REGEX_SH */
