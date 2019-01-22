#!/bin/bash

#----------------------------------------------#
# Source:			regex.sh
# Data:				9 de novembro de 2017
# Desenvolvido por:	Juliano Santos [SHAMAN]
# E-mail:   		shellscriptx@gmail.com
#----------------------------------------------#

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

# const
readonly REG_ICASE=2
readonly REG_CASE=0

# func regex.findall <[str]pattern> <[str]exp> <[uint]flag> => [str]|[str] ...
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
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" ${@:4}
	
	local def cur exp match

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $3 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$3" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	

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

# func regex.fullmatch <[str]pattern> <[str]exp> <[uint]flag> => [uint|uint|str]
#
# Força 'pattern' a coincidir com toda sequência em 'exp', retornado o intervalo e a
# string da ocorrência. 
#
function regex.fullmatch()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" ${@:4}

	local def cur exp

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $3 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$3" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	

	shopt -q${def} nocasematch

	while read exp; do
		[[ $exp =~ ^$1$ ]] && echo "0|${#BASH_REMATCH}|$BASH_REMATCH"
	done <<< "$2"

	shopt -q${cur} nocasematch
	
	return 0
}

# func regex.match <[str]pattern> <[str]exp> [uint]flag => [str]
#
# Aplica o padrão no inicio da string retornando a expressão se coincidir ou
# nulo se não for encontrado.
#
function regex.match()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" ${@:4}
	
	local def cur exp

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $3 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$3" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	
	
	shopt -q${def} nocasematch

	while read exp; do
		[[ $exp =~ ^$1 ]] && echo "0|${#BASH_REMATCH}|$BASH_REMATCH"
	done <<< "$2"

	shopt -q${cur} nocasematch

	return 0
}

# func regex.search <[str]pattern> <[str]exp> <[uint]flag> => [uint|uint|str]
#
# Busca uma correspondência do padrão 'pattern' em 'exp', retornando o índice de
# intervalo do objeto da correspondência ou nulo se não houver.
#
# A correspondência é retornada no seguinte padrão:
#
# start|end|match
#
function regex.search()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" ${@:4}

	local exp tmp old s e def cur

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $3 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$3" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	

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

# func regex.split <[str]pattern> <[str]exp> <[uint]flag> => [str]
#
# Divide a string 'exp' pela ocorrências do padrão, retornando uma lista contendo as substrings resultantes.
#
# Exemplo: substring1|substring2|substring3|...
#
function regex.split()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" ${@:4}
		
	local def cur exp old

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $3 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$3" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	

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

# func regex.ismatch <[str]pattern> <[str]exp> <[uint]flag> => [bool]
#
# Retorna 'true' se o padrão coincidir em 'exp', caso contrário retorna 'false'.
#
function regex.ismatch()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" ${@:4}

	local exp def cur r

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $3 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$3" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	

	shopt -q${def} nocasematch

	while read exp; do
		[[ $exp =~ $1 ]] && { r=0; break; }
	done <<< "$2"

	shopt -q${cur} nocasematch

	return ${r:-1}
}

# func regex.groups <[str]pattern> <[str]exp> <[uint]flag> => [str]
#
# Retorna uma lista de grupos de captura se presentes no padrão.
#
function regex.groups()
{
	getopt.parse 3 "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" ${@:4}

	local grp exp def cur

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $3 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$3" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	

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

# func regex.fngroups <[str]pattern> <[str]exp> <[str]new> <[int]count> <[uint]flag> <[func]funcname> <[str]args> ... => [str] 
#
# Substitui os retrovisores dos grupos de captura em 'new' pelo retorno de 'funcname' em 'count' ocorrências. Se 'count' for
# igual a '-1' realiza a substituição em todas as ocorrências.
# Chama 'funcname' passando como argumento posicional '$1' o grupo de captura se presente com 'N'args (opcional) a cada 
# ocorrência de 'pattern' em 'exp', subsituindo os retrovisores  &, \\1, \\2, \\3 ... pelo retorno da função.
# Toda a ocorrência incluindo os grupos de captura são representados pelo caractere '&' e que também é passado como argumento.
#
# A função é chamada somente se o grupo de captura estiver presente ou '&' for especificado.
#
# Exemplo:
#
# # Dobrando o valor do último número contido na expressão.
#
# #!/bin/bash
#
# source regex.sh
#
# nums='num: 4, num: 10, num: 50'
#
# dobrar(){
#    arg=$1
#
#    # Efetua a operação se 'arg' for um número, caso contrário retorna o padrão.
#    __isnum__ arg && echo $(($1 * 2)) || echo $1
# }
#
# echo -n "Antes: "
# echo $nums
#
# echo -n "Depois: "
# regex.fngroups "^.*\\s([0-9]+)$" "$nums" "& -> \\1" 1 $REG_ICASE dobrar
#
# Saida:
#
# Antes: num: 4, num: 10, num: 50
# Depois: num: 4, num: 10, num: 50 -> 100
#
function regex.fngroups()
{
	getopt.parse -1 "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:int:+:$4" "flag:uint:+:$5" "funcname:func:+:$6" "args:str:-:$7" ... "${@:8}"

	local exp new c i

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $5 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$5" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	
	
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

# func regex.fnngroups <[str]pattern> <[str]exp> <[str]new> <[uint]match> <[uint]flag> <[func]funcname> <[str]args> ... => [str] 
#
# Substitui os retrovisores dos grupos de captura em 'new' pelo retorno de 'funcname' em 'match' ocorrência.
# Chama 'funcname' passando como argumento posicional '$1' o grupo de captura se presente com 'N'args (opcional) 
# Toda a ocorrência incluindo os grupos de captura são representados pelo caractere '&' e que também é passado como argumento.
#
# A função é chamada somente se o grupo de captura estiver presente ou '&' for especificado.
#
function regex.fnngroups()
{
	getopt.parse -1 "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:uint:+:$4" "flag:uint:+:$5" "funcname:func:+:$6" "args:str:-:$7" ... "${@:8}"

	local exp new c i

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $5 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$5" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	
	
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
# func regex.savegroups <[str]pattern> <[str]exp> <[uint]flag> <[array]name>
#
# Salva os grupos de captura ou ocorrências casadas em array 'name'.
#
# Exemplo:
#
# #!/bin/bash
# # script: regroup.sh
#
# source regex.sh
# source array.sh
#
# array grupo
#
# # Compila o padrão e inicia a variável 're' do tipo 'regex'.
# padrao='(<[^>]+>)'
#
# texto="Seja livre use <Linux>. Escolha sua distro <Debian>, <Slackware>, <Redhat> e desfrute da liberdade."
#
# # Aplica a regex em 'texto' e salva as expressões casadas em 'grupo'.
# regex.savegroups "$padrao" "$texto" $REG_ICASE grupo
#
# # Lista os elementos de 'grupo'.
# for grp in "${grupo[@]}"
# do
#    echo "grupo $((i++)): $grp"
# done
#
# # Exibe parte da expressão casada.
# echo -e "\nExpressão: ${grupo[@]}"
# 
# # FIM
#
# $ ./regroup.sh
#
# grupo 0: <Linux>
# grupo 1: <Debian>
# grupo 2: <Slackware>
# grupo 3: <Redhat>
#
# Expressão: Seja livre use <Linux> <Debian> <Slackware> <Redhat>
#
function regex.savegroups()
{
	getopt.parse 4 "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" "dest:array:+:$4" "${@:5}"
	
	declare -n __byref=$4
	local __def __cur __exp

	shopt -q nocasematch && __cur='s' || __cur='u'
	
	case $3 in
		0) __def='u';;
		2) __def='s';;
		*) error.__trace def "flag" "uint" "$3" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	

	shopt -q${__def} nocasematch

	while read __exp; do
		while [[ $__exp =~ $1 ]]; do
			__byref+=("${BASH_REMATCH[@]:1}")
			__exp=${__exp/${BASH_REMATCH}/}
		done
	done <<< "$2"

	shopt -q${__cur} nocasematch

	return 0
}

# func regex.replace <[str]pattern> <[str]exp> <[str]new> <[int]count> <[uint]flag> => [str]
#
# Substitui 'count' vezes o padrão em 'pattern' por 'new'. Se 'count' for igual à '-1',
# aplica a substituição em todas as ocorrências. A expressão em 'pattern' pode ser uma ERE 
# (expressão regular estendida), podendo utilizar retrovisores '&, \\1, \\2, \\3 ...' em 'new' se
# grupos de captura estiverem presentes entre parenteses '(...)'.
#
# Exemplo:
#
# #!/bin/bash
# # script: re.sh
#
# source regex.sh
#
# texto='O Linux tem 26 anos de idade, criado em 1991 por Linus Torvalds.'
#
# echo -e "$texto\n"
#
# # Removendo tudo antes de 'Linux Torvalds'.
# echo -n '1 - '
# regex.replace "^.*por " '' "$texto" 1 $REG_ICASE
#
# # Retirando somente os números.
# echo -n '2 - '
# regex.replace "[0-9]+" '' "$texto" -1 $REG_ICASE
#
# # Colocando os números entre '[...]' utilizando grupo/retrovisor.
# # '\\1' represeta o padrão casado no primeiro grupo entre (...).
# echo -n '3 - '
# regex.replace "([0-9]+)" '[\\1]' "$texto" -1 $REG_ICASE
#
# # FIM
#
# $ ./re.sh
# O Linux tem 26 anos de idade, criado em 1991 por Linus Torvalds.
#
# 1 - Linus Torvalds.
# 2 - O Linux tem  anos de idade, criado em  por Linus Torvalds.
# 3 - O Linux tem [26] anos de idade, criado em [1991] por Linus Torvalds.
#
function regex.replace()
{
	getopt.parse 5 "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:int:+:$4" "flag:uint:+:$5" "${@:6}"

	local exp new i n c

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $5 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$5" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	
	
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
	
# func regex.nreplace <[str]pattern> <[str]exp> <[str]new> <[uint]match> <[uint]flag> => [str]
#
# Substitui 'pattern' por 'new' em 'match' ocorrência. A expressão em 'pattern' pode ser uma ERE 
# (expressão regular estendida), podendo utilizar retrovisores '\\1, \\2, \\3 ...' em 'new' se
# grupos de captura estiverem presentes entre parenteses '(...)'.
#
# Exemplo:
#
# #!/bin/bash
# # script: re.sh
#
# source regex.sh
#
# texto='A Informática é uma ciência exotérica'
#
# echo -e "$texto\\n"
#
# # Apagando a segunda palavra que termina com a letra 'a'.
# echo -n '1 - '
# regex.nreplace "\\w+a\\s" '' "$texto" 2 $REG_ICASE
#
# # Colocando entre parênteses a terceira palavra com mais de 3 letras.
# echo -n '2 - '
# regex.nreplace "(\\w{3,})" '(\\1)' "$texto" 3 $REG_ICASE
#
# # Criando dois grupos de captura e invertendo a ordem dos retrovisores
# '\\1' e '\\2' para geração de uma nova frase.
# echo -n '3 - '
# regex.nreplace "(\\w{3,}).*\\s(\\w{3,})$" '\\2 \\1' "$texto" 1 $REG_ICASE
#
# # FIM
#
# $ ./re.sh
# A Informática é uma ciência exotérica
#
# 1 - A Informática é ciência exotérica
# 2 - A Informática é uma (ciência) exotérica
# 3 - A exotérica Informática
#
function regex.nreplace()
{
	getopt.parse 5 "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:uint:+:$4" "flag:uint:+:$5" "${@:6}"

	local exp new i n c

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $5 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$5" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	
	
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

# func regex.fnreplace <[str]pattern> <[str]exp> <[int]count> <[uint]flag> <[func]funcname> <[str]args> ... => [str]
#
# Substitui 'count' vezes o padrão em 'pattern' pelo retorno de 'funcname', cujo identificador é uma 
# função válida que é chamada e recebe automaticamente como argumento posicional '$1' o padrão casado e
# com N'args' (opcional). 
# Se 'count' for igual à '-1' aplica em todas as ocorrências.
# A expressão em 'pattern' pode ser uma ERE (expressão regular estendida).
#
# Exemplo:
#
# #!/bin/bash
# script: re.sh
#
# source regex.sh
#
# texto="Contagem regressiva: 5, 4, 3, 2, 1"
#
# echo -e "$texto\\n"
#
# # Rotular números pares e ímpares.
# rotular(){
#    [[ $(($1%2)) -eq 0 ]] && res="par=($1)" || res="impar=($1)"
#    echo "$res"
# }
#
# # Incrementando '10' ao valor atual.
# somando(){
#    echo "$(($1+10))"
# }
#
# # Somente os números ímpares.
# impar(){
#    [[ $(($1%2)) -eq 0 ]] || echo "$1" 
# }
#
# # Adicionando uma casa decimal.
# decimal(){
#    echo "$1.0" 
# }
#
# echo -n '1 - '
# regex.fnreplace "[0-9]+" "$texto" -1 $REG_ICASE rotular
#
# echo -n '2 - '
# regex.fnreplace "[0-9]+" "$texto" -1 $REG_ICASE somando
#
# echo -n '3 - '
# regex.fnreplace "[0-9]+" "$texto" -1 $REG_ICASE impar
#
# echo -n '4 - '
# regex.fnreplace "[0-9]+" "$texto" 2 $REG_ICASE decimal
#
# # FIM
#
# $ ./re.sh
# Contagem regressiva: 5, 4, 3, 2, 1
#
# 1 - Contagem regressiva: impar=(5), par=(4), impar=(3), par=(2), impar=(1)
# 2 - Contagem regressiva: 15, 14, 13, 12, 11
# 3 - Contagem regressiva: 5, , 3, , 1
# 4 - Contagem regressiva: 5.0, 4.0, 3, 2, 1
#
function regex.fnreplace()
{
	getopt.parse -1 "pattern:str:+:$1" "exp:str:-:$2" "count:int:+:$3" "flag:uint:+:$4" "funcname:func:+:$5" "args:str:-:$6" ... "${@:7}"

	local exp new c i

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $4 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$4" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	
	
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

# func regex.fnnreplace <[str]pattern> <[str]exp> <[uint]match> <[uint]flag> <[func]funcname> <[str]args> ... => [str]
#
# Substitui o padrão em 'pattern' pelo retorno de 'funcname' em 'match' ocorrência. 'funcname' é o
# identificador de uma função válida que é chamada e recebe automaticamente como argumento
# posicional '$1' o padrão casado e com N'args' (opcional). 
# A expressão em 'pattern' pode ser uma ERE (expressão regular estendida).
#
# Exemplo:
#
# #!/bin/bash
# # script: re.sh
#
# source regex.sh
# source string.sh
#
# texto='Slackware é uma distro Linux lançada em 16/7/1993'
#
# mes_nome(){
#    # Verifica o número do mês e atribui o nome.
#    case ${1////} in
#        1) mes='janeiro';;
#        2) mes='fevereiro';;
#        3) mes='março';;
#        4) mes='abril';;
#        5) mes='maio';;
#        6) mes='junho';;
#        7) mes='julho';;
#        8) mes='agosto';;
#        9) mes='setembro';;
#        10) mes='outubro';;
#        11) mes='novembro';;
#        12) mes='dezembro';;
#    esac
#
#    # Retorna a expressão com o nome.
#    echo " $mes de "
# }
#
# maiusculo(){
#    string.toupper "$1"
# }
#
# mascara(){
#    echo "[#]"
# }
#
# echo -e "$texto\\n"
#
# # Atribui nome ao número do mês.
# echo -n '1 - '
# regex.fnnreplace '/([1-9]|1[0-2])/' "$texto" 1 $REG_ICASE mes_nome
#
# # Converte para maiúsculo a quinta palavra.
# echo -n '2 - '
# regex.fnnreplace '\\w+\\s' "$texto" 5 $REG_ICASE maiusculo
#
# # Mascara o vigésimo quarto caractere.
# echo -n '3 - '
# regex.fnnreplace '.' "$texto" 24 $REG_ICASE mascara
#
# # FIM
#
# $ ./re.sh
# Slackware é uma distro Linux lançada em 16/7/1993
#
# 1 - Slackware é uma distro Linux lançada em 16 julho de 1993
# 2 - Slackware é uma distro LINUX lançada em 16/7/1993
# 3 - Slackware é uma distro [#]inux lançada em 16/7/1993
#
function regex.fnnreplace()
{
	getopt.parse -1 "pattern:str:+:$1" "exp:str:-:$2" "count:uint:+:$3" "flag:uint:+:$4" "funcname:func:+:$5" "args:str:-:$6" ... "${@:7}"

	local exp new i c

	shopt -q nocasematch && cur='s' || cur='u'
	
	case $4 in
		0) def='u';;
		2) def='s';;
		*) error.__trace def "flag" "uint" "$4" "$__ERR_REGEX_FLAG_INVALID"; return $?;;
	esac	
	
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
