#!/bin/bash

#----------------------------------------------#
# Source:			regex.sh
# Data:				9 de novembro de 2017
# Desenvolvido por:	Juliano Santos [SHAMAN]
# E-mail:   		shellscriptx@gmail.com
#----------------------------------------------#

[[ $__REGEX_SRC ]] && return 0

readonly __REGEX_SRC=1

source builtin.sh
source str.sh

# errors
readonly __REGEX_ERR_FLAG_INVALID='a flag especificada é inválida'
readonly __REGEX_ERR_GROUP_REF='referência do grupo inválida'

# constantes
readonly regex_case=1         # [flag] - considera a diferença entre caracteres maiúsuculos e minúsculos.
readonly regex_ignorecase=2   # [flag] - ignora a diferença entre caracteres maiúsculos e minúsculos.

# func regex.findall <[str]pattern> <[str]exp> <[uint]flag> => [str]
#
# Retorna uma lista de todas as correspondências não sobrepostas na cadeia.
#
# Se um ou mais grupos de captura estiverem presentes no padrão, é retornado
# uma lista de grupos.
#
function regex.findall()
{
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3"
	
	local exp=$2
	local flag=$3

	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac	

	while [[ $exp =~ $1 ]]; do
		for match in "${BASH_REMATCH[@]}"; do
			echo "$match"
			exp=${exp/$match/}
		done
	done
	
	return 0
}

# func regex.fullmatch <[str]pattern> <[str]exp> <[uint]flag> => [uint|uint|str]
#
# Força 'pattern' a coincidir com toda sequência em 'exp', retornado o intervalo e a
# string da ocorrência. 
#
function regex.fullmatch()
{
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3"

	local flag=$3
	local exp=$2

	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac	

	if [[ $exp =~ ^$1$ ]]; then
		echo "0|${#BASH_REMATCH}|$BASH_REMATCH"
	fi
	
	return 0
}

# func regex.match <[str]pattern> <[str]exp> [uint]flag => [str]
#
# Aplica o padrão no inicio da string retornando a expressão se coincidir ou
# nulo se não for encontrado.
#
function regex.match()
{
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3"
	
	local flag=$3
	local exp=$2

	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac	

	if [[ $exp =~ ^$1 ]]; then
		echo "0|${#BASH_REMATCH}|$BASH_REMATCH"
	fi

	return 0
}

# func regex.search <[str]pattern> <[str]exp> <[uint]flag> => [uint|uint|str]
#
# Busca uma correspondência do padrão 'pattern' em 'exp', retornando o índice de
# intervalo do objeto da correspondência ou nulo se não houver. Se parênteses forem
# utilizados no padrão, é retorna uma lista de objetos de grupo.
#
function regex.search()
{
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3"

	local match s e
	local flag=$3
	local exp=$2

	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac	

	if [[ $exp =~ $1 ]]; then
		for match in "${BASH_REMATCH[@]}"; do
			s=$(str.find "$exp" "$match")
			e=$((s+${#match}))
			echo "$s|$e|$match"
		done
	fi
	
	return 0
}

# func regex.split <[str]pattern> <[str]exp> <[uint]flag> => [str]
#
# Retorna uma lista contendo as substrings resultantes. E se a captura de parênteses
# for utilizada no padrão, então o texto de todos grupos também são retornados como
# parte do resultado da lista.
#
function regex.split()
{
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3"
		
	local exp=$2
	local sub=$2
	local flag=$3

	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac	

	while [[ $sub =~ $1 ]]; do
		exp=${exp//${BASH_REMATCH[0]}/\\n}
		sub=${sub//${BASH_REMATCH[0]}/}
	done
	
	echo "$exp"

	return 0
}

# func regex.ismatch <[str]pattern> <[str]exp> <[uint]flag> => [bool]
#
# Retorna 'true' se o padrão coincidir em 'exp', caso contrário retorna 'false'.
#
function regex.ismatch()
{
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3"

	local flag=$3
	local exp=$2

	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac	

	[[ $exp =~ $1 ]] && return 0

	return 1
}

# func regex.groups <[str]pattern> <[str]exp> <[uint]flag> => [str]
#
# Retorna uma lista de grupos de captura se presentes no padrão.
#
function regex.groups()
{
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3"

	local exp=$2
	local flag=$3

	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac	

	while [[ $exp =~ $1 ]]; do
		for match in "${BASH_REMATCH[@]}"; do
			exp=${exp/$match/}
			echo "$match"
		done
	done

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
# padrao='^.*use|<[^>]+>'
#
# texto="Seja livre use <Linux>. Escolha sua distro <Debian>, <Slackware>, <Redhat> e desfrute da liberdade."
#
# # Aplica a regex em 'texto' e salva as expressões casadas em 'grupo'.
# regex.savegroups "$padrao" "$texto" $regex_case grupo
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
# grupo 0: Seja livre use
# grupo 1: <Linux>
# grupo 2: <Debian>
# grupo 3: <Slackware>
# grupo 4: <Redhat>
#
# Expressão: Seja livre use <Linux> <Debian> <Slackware> <Redhat>
#
function regex.savegroups()
{
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "flag:uint:+:$3" "dest:array:+:$4"
	
	declare -n __ref=$4
	local __exp=$2
	local __flag=$3
	local __match

	case $__flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$__flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac	

	[[ $__exp =~ $1 ]]
	__ref=("${BASH_REMATCH[@]}")
	
	return 0
}

# func regex.replace <[str]pattern> <[str]exp> <[str]new> <[int]count> <[uint]flag> => [str]
#
# Substitui 'count' vezes o padrão em 'pattern' por 'new'. Se 'count' for igual à '-1',
# aplica a substituição em todas as ocorrências. A expressão em 'pattern' pode ser uma ERE 
# (expressão regular estendida), podendo utilizar retrovisores '\1, \2, \3 ...' em 'new' se
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
# regex.replace "^.*por " '' "$texto" 1 $regex_case
#
# # Retirando somente os números.
# echo -n '2 - '
# regex.replace "[0-9]+" '' "$texto" -1 $regex_case
#
# # Colocando os números entre '[...]' utilizando grupo/retrovisor.
# # '\1' represeta o padrão casado no primeiro grupo entre (...).
# echo -n '3 - '
# regex.replace "([0-9]+)" '[\1]' "$texto" -1 $regex_case
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
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "count:int:+:$4" "flag:uint:+:$5"

	local pattern=$1
	local exp=$2
	local flag=$5
	local seg=0
	local groups grp pos c
	
	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac
	
	for ((c=0; c != $4; c++)); do
		new=$3
		groups=()
		
		[[ ${exp:$seg} =~ $pattern ]]
		[[ $BASH_REMATCH ]] || break
		groups=("${BASH_REMATCH[@]}")
		
		while [[ $new =~ \\[1-9][0-9]* ]]; do
			grp=${BASH_REMATCH[0]#\\}
			new=${new/\\$grp/${groups[$grp]}}
		done
		
		for ((pos=seg; pos < ${#exp}; pos++)); do
			if [[ "${exp:$pos:${#groups[0]}}" == "${groups[0]}" ]]; then
				seg=$(($pos+${#groups[0]}+${#new}-1))
				break
			fi
		done
		exp=${exp:0:$pos}${new}${exp:$(($pos+${#groups[0]}))}
	done
	
	echo "$exp"
	
	return 0
}
	
# func regex.nreplace <[str]pattern> <[str]exp> <[str]new> <[uint]match> <[uint]flag> => [str]
#
# Substitui 'pattern' por 'new' em 'match' ocorrência. A expressão em 'pattern' pode ser uma ERE 
# (expressão regular estendida), podendo utilizar retrovisores '\1, \2, \3 ...' em 'new' se
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
# echo -e "$texto\n"
#
# # Apagando a segunda palavra que termina com a letra 'a'.
# echo -n '1 - '
# regex.nreplace "\w+a\s" '' "$texto" 2 $regex_case
#
# # Colocando entre parênteses a terceira palavra com mais de 3 letras.
# echo -n '2 - '
# regex.nreplace "(\w{3,})" '(\1)' "$texto" 3 $regex_case
#
# # Criando dois grupos de captura e invertendo a ordem dos retrovisores
# '\1' e '\2' para geração de uma nova frase.
# echo -n '3 - '
# regex.nreplace "(\w{3,}).*\s(\w{3,})$" '\2 \1' "$texto" 1 $regex_case
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
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "new:str:-:$3" "match:uint:+:$4" "flag:uint:+:$5"

	local pattern=$1
	local exp=$2
	local flag=$5
	local groups grp seg m

	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac

	while [[ $4 -gt $m ]]; do
		new=$3
		groups=()
		
		[[ ${exp:$seg} =~ $pattern ]]
		[[ $BASH_REMATCH ]] || break
		groups=("${BASH_REMATCH[@]}")
	
		while [[ $new =~ \\[1-9][0-9]* ]]; do
			grp=${BASH_REMATCH[0]#\\}
			new=${new/\\$grp/${groups[$grp]}}
		done
		
		for ((pos=seg; pos < ${#exp}; pos++)); do
			if [[ "${exp:$pos:${#groups[0]}}" == "${groups[0]}" ]]; then
				seg=$(($pos+${#groups[0]}))
				((m++))
				break
			fi
		done
	done

	[[ $m -eq $4 ]] && exp=${exp:0:$pos}${new}${exp:$(($pos+${#groups[0]}))}

	echo "$exp"

	return 0
}

# func regex.fnreplace <[str]pattern> <[str]exp> <[func]funcname> <[int]count> <[uint]flag> => [str]
#
# Substitui 'count' vezes o padrão em 'pattern' pelo retorno de 'funcname', cujo identificador é uma 
# função válida que é chamada e recebe automaticamente como argumento posicional '$1' o padrão casado. 
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
# echo -e "$texto\n"
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
# regex.fnreplace "[0-9]+" rotular "$texto" -1 $regex_case
#
# echo -n '2 - '
# regex.fnreplace "[0-9]+" somando "$texto" -1 $regex_case
#
# echo -n '3 - '
# regex.fnreplace "[0-9]+" impar "$texto" -1 $regex_case
#
# echo -n '4 - '
# regex.fnreplace "[0-9]+" decimal "$texto" 2 $regex_case
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
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "funcname:func:+:$3" "count:int:+:$4" "flag:uint:+:$5"

	local pattern=$1
	local func=$3
	local exp=$2
	local flag=$5
	local pos c seg new
	
	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac
	
	for ((c=0; c != $4; c++)); do
		[[ ${exp:$seg} =~ $pattern ]]
		[[ $BASH_REMATCH ]] || break

		for ((pos=seg; pos < ${#exp}; pos++)); do
			if [[ "${exp:$pos:${#BASH_REMATCH}}" == "$BASH_REMATCH" ]]; then
				new=$($func "$BASH_REMATCH")
				seg=$(($pos+${#BASH_REMATCH}+${#new}-1))
				break
			fi
		done
		exp=${exp:0:$pos}${new}${exp:$(($pos+${#BASH_REMATCH}))}
	done
	
	echo "$exp"
	
	return 0
}

# func regex.fnnreplace <[str]pattern> <[str]exp> <[func]funcname> <[uint]match> <[uint]flag> => [str]
#
# Substitui o padrão em 'pattern' pelo retorno de 'funcname' em 'match' ocorrência. 'funcname' é o
# identificador de uma função válida que é chamada e recebe automaticamente como argumento
# posicional '$1' o padrão casado. 
# A expressão em 'pattern' pode ser uma ERE (expressão regular estendida).
#
# Exemplo:
#
# #!/bin/bash
# # script: re.sh
#
# source regex.sh
# source str.sh
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
#    str.toupper "$1"
# }
#
# mascara(){
#    echo "[#]"
# }
#
# echo -e "$texto\n"
#
# # Atribui nome ao número do mês.
# echo -n '1 - '
# regex.fnnreplace '/([1-9]|1[0-2])/' mes_nome "$texto" 1 $regex_case
#
# # Converte para maiúsculo a quinta palavra.
# echo -n '2 - '
# regex.fnnreplace '\w+\s' maiusculo "$texto" 5 $regex_case
#
# # Mascara o vigésimo quarto caractere.
# echo -n '3 - '
# regex.fnnreplace '.' mascara "$texto" 24 $regex_case
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
	getopt.parse "pattern:str:+:$1" "exp:str:-:$2" "funcname:func:+:$3" "match:uint:+:$4" "flag:uint:+:$5"

	local pattern=$1
	local func=$3
	local exp=$2
	local flag=$5
	local pos seg m
		
	case $flag in
		1) shopt -u nocasematch;;
		2) shopt -s nocasematch;;
		*) error.__exit "flag" "uint" "$flag" "$__REGEX_ERR_FLAG_INVALID";;
	esac
	
	while [[ $4 -gt $m ]]; do
		[[ ${exp:$seg} =~ $pattern ]]
		[[ $BASH_REMATCH ]] || break

		for ((pos=seg; pos < ${#exp}; pos++)); do
			if [[ "${exp:$pos:${#BASH_REMATCH}}" == "$BASH_REMATCH" ]]; then
				seg=$(($pos+${#BASH_REMATCH}))
				((m++))
				break
			fi
		done
	done

	[[ $m -eq $4 ]] && exp=${exp:0:$pos}$($func "$BASH_REMATCH")${exp:$(($pos+${#BASH_REMATCH}))}

	echo "$exp"
	
	return 0
}

readonly -f regex.findall \
			regex.fullmatch \
			regex.match \
			regex.search \
			regex.split \
			regex.ismatch \
			regex.groups \
			regex.savegroups \
			regex.replace \
			regex.nreplace \
			regex.fnreplace \
			regex.fnnreplace 

# /* __REGEX_SRC */
