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

[ -v __STRING_SH__ ] && return 0

readonly __STRING_SH__=1

source builtin.sh

# .FUNCTION string.len <expr[str]> -> [uint]|[bool]
#
# Retorna o comprimento de 'expr'.
#
function string.len()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	echo ${#1}
	return $?
}

# .FUNCTION string.capitalize <expr[str]> -> [str]|[bool]
# 
# Retorna uma cópia em letras maiúsculas de 'expr', ou seja, torna o primeiro
# caractere em maiúsculo e o restante em minúsculos.
#
function string.capitalize()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	local sub=${1:1}
	local ini=${1:0:1}
	echo "${ini^}${sub,,}"
	return $?
}

# .FUNCTION string.center <expr[str]> <fillchar[char]> <[uint]width> -> [str]|[bool]
#
# Retorna uma cópia de 'expr' centralizando o texto.
#
function string.center()
{
	getopt.parse 3 "expr:str:$1" "fillchar:char:$2" "width:uint:$3" "${@:4}"

	local ch cr
	local lc=$(($3-${#1}))

	((lc > 0)) && printf -v ch '%*s' $((lc/2))
	(((lc % 2) == 1)) && cr=$2
	ch=${ch// /$2}
	echo "${ch}${1}${ch}${cr}"

	return $?	
}

# .FUNCTION string.count <expr[str]> <sub[str]> -> [uint]|[bool]
#
# Retorna 'N' ocorrências de 'sub' em 'expr'.
#
function string.count()
{
	getopt.parse 2 "expr:str:$1" "sub:str:$2" "${@:3}"

	local expr=$1
	local c
	
	while [[ $2 && $expr =~ $2 ]]; do
		((c++)); expr=${expr/$BASH_REMATCH/}
	done

	echo ${c:-0}

	return $?
}

# .FUNCTION string.endswith <expr[str]> <suffix[str]> -> [bool]
#
# Retorna 'true' se 'expr' termina com 'suffix, caso contrário 'false'.
#
function string.endswith()
{
	getopt.parse 2 "expr:str:$1" "suffix:str:$2" "${@:3}"

	[[ $1 =~ $2$ ]]
	return $?
}

# .FUNCTION string.startswith <expr[str]> <prefix[str]> -> [bool]
#
# Retorna 'true' se 'expr' inicia com 'prefix', caso contrário 'false'.
#
function string.startswith()
{
	getopt.parse 2 "expr:str:$1" "prefix:str:$2" "${@:3}"

	[[ $1 =~ ^$2 ]]
	return $?
}

# .FUNCTION string.expandspace <expr[str]> <size[uint]> -> [bool]
#
# Retorna uma sequência caracteres em que os espaços são expandidos 
# ao comprimento especificado em 'size'.
#
function string.expandspaces()
{
	getopt.parse 2 "expr:str:$1" "size:str:$2" "${@:3}"

	local spc
	printf -v spc '%*s' $2
	echo "${1// /$spc}"
	return $?
}

# .FUNCTION string.find <expr[str]> <sub[str]> -> [int]|[bool]
#
# Retorna o índice mais baixo da ocorrência de 'sub' em 'expr'.
# Se não houver correspondência é retornado '-1'.
#
function string.find()
{
	getopt.parse 2 "expr:str:$1" "sub:str:$2" "${@:3}"
	
	local pos sub

	sub=${1#*$2}
	pos=$((${#1}-${#sub}-${#2}))
	((pos < 0)) && pos=-1
	echo $pos
	return $?
}

# .FUNCTION string.rfind <expr[str]> <sub[str]> -> [int]|[bool]
#
# Retorna o índice mais alto da ocorrência de 'sub' em 'expr'.
# Se não houver correspondência é retornado '-1'.
#
function string.rfind()
{
	getopt.parse 2 "expr:str:$1" "sub:str:$2" "${@:3}"

	local pos sub

	sub=${1##*$2}
	pos=$((${#1}-${#sub}-${#2}))
	((pos < 0)) && pos=-1
	echo $pos
	return $?
}

# .FUNCTION string.isalnum <expr[str]> -> [bool]
#
# Retorna 'true' se 'expr' contém letras e dígitos.
#
function string.isalnum()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 == +([[:alnum:]]) ]]
	return $?
}

# .FUNCTION string.isalpha <expr[str]> -> [bool]
#
# retorna 'true' se 'expr' contém somente letras.
#
function string.isalpha()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 == +([[:alpha:]]) ]]
	return $?
}

# .FUNCTION string.isdigit <expr[str]> -> [bool]
#
# Retorna 'true' se 'expr' contém somente dígitos.
#
function string.isdigit()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 == +([[:digit:]]) ]]
	return $?
}

# .FUNCTION string.isspace <expr[str]> -> [bool]
#
# Retorna 'true' se 'expr' contém somente espaços.
#
function string.isspace()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 == +([[:space:]]) ]]
	return $?
}

# .FUNCTION string.isprint <expr[str]> -> [bool]
#
# Retorna 'true' se 'expr' contém somente caracteres imprimíveis.
#
function string.isprint()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 == +([[:print:]]) ]]
	return $?
}


# .FUNCTION string.islower <expr[str]> -> [bool]
#
# Retorna 'true' se 'expr' contém somente caracteres minúsculos.
#
function string.islower()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 == +([^[:upper:]]) ]]
	return $?
}

# .FUNCTION string.isupper <expr[str]> -> [bool]
#
# Retorna 'true' se 'expr' contém somente caracteres maiúsculos.
#
function string.isupper()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 == +([^[:lower:]]) ]]
	return $?
}

# .FUNCTION string.istitle <expr[str]> -> [bool]
#
# Retorna 'true' se 'expr' é uma string de titulo e há pelo menos um
# caractere em maiúsculo, ou seja, caracteres maiúsculos só podem seguir sem
# caracteres e caracteres minúsculos apenas os maiúsculos. Retorna 'false'
# de outra forma.
#
function string.istitle()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 == +(*([^[:alpha:]])@([[:upper:]])+([[:lower:]])) ]]
	return $?
}

# .FUNCTION string.join <expr[str]> <sep[str]> [str]|[bool]
#
# Retorna uma string que é concatenação dos elementos iteráveis delimitados por 'sep'.
#
function string.join()
{
	getopt.parse 2 "expr:str:$1" "sep:str:$2" "${@:3}"

	local iter

	mapfile -t iter <<< "$1"
	printf -v expr "%s${2//%/%%}" "${iter[@]}"
	echo "${expr%$2}"
	return $?
}

# .FUNCTION string.ljust <expr[str]> <fillchar[char]> <width[uint]> -> [str]|[bool]
#
# Retorna uma string justificada à esquerda em uma cadeia de largura de comprimento. 
# O preenchimento é feito usando o caractere de preenchimento especificado em 'fillchar'.
#
function string.ljust()
{
	getopt.parse 3 "expr:str:$1" "fillchar:char:$2" "width:uint:$3" "${@:4}"

	local ch wd 
	wd=$(($3-${#1}))
	printf -v ch '%*s' $(($wd > 0 ? $wd : 0))
	echo "${ch// /$2}${1}"
	return $?
}

# .FUNCTION string.rjust <expr[str]> <fillchar[char]> <width[uint]> -> [str]|[bool]
#
# Retorna uma string justificada à diretia em uma cadeia de largura de comprimento. 
# O preenchimento é feito usando o caractere de preenchimento especificado em 'fillchar'.
#
function string.rjust()
{
	getopt.parse 3 "expr:str:$1" "fillchar:char:$2" "width:uint:$3" "${@:4}"

	local ch wd 
	wd=$(($3-${#1}))
	printf -v ch '%*s' $(($wd > 0 ? $wd : 0))
	echo "${1}${ch// /$2}"
	return $?
}

# .FUNCTION string.lower <expr[str]> -> [str]|[bool]
#
# Converte a cadeia de caracteres para minúsculo.
#
function string.lower()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	echo "${1,,}"
	return $?
}

# .FUNCTION string.upper <expr[str]> -> [str]|[bool]
#
# Converte a cadeia de caracteres para maiúsculo.
#
function string.upper()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	echo "${1^^}"
	return $?
}

# .FUNCTION string.strip <expr[str]> <sub[str]> -> [str]|[bool]
#
# Retorna uma cópia da string removendo a substring do inicio e final
# da cadeia de caracteres.
#
function string.strip()
{
	getopt.parse 2 "expr:str:$1" "sub:str:$2" "${@:3}"

	local on expr
	
	shopt -q extglob && on='s'
	shopt -s extglob
	expr=${1##+($2)}
	echo "${expr%%+($2)}"
	shopt -${on:-u} extglob
	return $?
}

# .FUNCTION string.lstrip <expr[str]> <sub[str]> -> [str]|[bool]
#
# Retorna uma cópia da string removendo a substring do inicio da
# cadeia de caracteres.
#
function string.lstrip()
{
	getopt.parse 2 "expr:str:$1" "sub:str:$2" "${@:3}"

	local on
	
	shopt -q extglob && on='s'
	shopt -s extglob
	echo "${1##+($2)}"
	shopt -${on:-u} extglob
	return $?
}

# .FUNCTION string.rstrip <expr[str]> <sub[str]> -> [str]|[bool]
#
# Retorna uma cópia da string removendo a substring do final da
# cadeia de caracteres.
#
function string.rstrip()
{
	getopt.parse 2 "expr:str:$1" "sub:str:$2" "${@:3}"

	local on
	
	shopt -q extglob && on='s'
	shopt -s extglob
	echo "${1%%+($2)}"
	shopt -${on:-u} extglob
	return $?
}

# .FUNCTION string.replace <expr[str]> <old[str]> <new[str]> <count[int]> -> [str]|[bool]
#
# Retorna uma cópia da string substituindo 'N' ocorrências de 'old' por 'new'.
#
function string.replace
{
	getopt.parse 4 "expr:str:$1" "old:str:$2" "new:str:$3" "count:int:$4" "${@:5}"

	local expr c i
	
	expr=$1

	for ((i=0; i < ${#expr}; i++)); do
		if [[ ${expr:$i:${#2}} == $2 ]]; then
			expr=${expr:0:$i}${3}${expr:$(($i+${#2}))}
			i=$(($i+${#3}))
			[[ $((++c)) -eq $4 ]] && break
		fi
	done
	
	echo "$expr"
	
	return $?
}

# .FUNCTION string.fnreplace <expr[str]> <old[str]> <count[int]> <func[function]> <args[str]> ... -> [str]|[bool]
#
# Retorna uma cópia da string substituindo 'N' ocorrências de 'old' pelo retorno da função.
# A função é chamada a cada ocorrência, passando como argumento posicional '$1' a expressão 
# casada com 'N' args (opcional).
#
# == EXEMPLO ==
#
# source string.sh
#
# texto='Linux é vida, Linux é liberdade, Linux é tudo!!'
#
# # Função que remove os dois primeiros caracteres da expressão.
# rm_chars(){
#	echo "${1#??}"
# }
#
# # Manipulando a palavra 'Linux' utilizando funções já existentes.
# string.fnreplace "$texto" 'Linux' -1 string.reverse 
# string.fnreplace "$texto" 'Linux ' -1 string.repeat 3
# string.fnreplace "$texto" 'Linux' 2 string.upper
#
# # Função personalizada.
# string.fnreplace "$texto" 'Linux' -1 rm_chars
#
# == SAÍDA ==
#
# xuniL é vida, xuniL é liberdade, xuniL é tudo!!
# Linux Linux Linux é vida, Linux Linux Linux é liberdade, Linux Linux Linux é tudo!!
# LINUX é vida, LINUX é liberdade, Linux é tudo!!
# nux é vida, nux é liberdade, nux é tudo!!
#
function string.fnreplace
{
	getopt.parse -1 "expr:str:$1" "old:str:$2" "count:int:$3" "func:function:$4" "args:str:$5" ... "${@:6}"

	local expr fn i c

	expr=$1

	for ((i=0; i < ${#expr}; i++)); do
		if [[ ${expr:$i:${#2}} == $2 ]]; then
			fn=$($4 "$2" "${@:5}")
			expr=${expr:0:$i}${fn}${expr:$(($i+${#2}))}
			i=$(($i+${#fn}))
			[[ $((++c)) -eq $3 ]] && break
		fi
	done

	echo "$expr"

	return $?
}

# .FUNCTION string.replacers <expr[str]> <old[str]> <new[str]> ... -> [str]|[bool]
#
# Retorna uma cópia da string substituindo todas as ocorrências de 'old' por 'new',
# podendo ser especificado mais de um conjunto de substituição.
#
# == EXEMPLO ==
#
# source string.sh
#
# texto='A Microsoft além do Windows agora tem sua própria distro Linux'.
#
# # Substituições.
# string.replacers "$texto" 'Windows' 'Ruindows' 'Microsoft' 'Micro$oft' 'Linux' 'Rindux'
#
# == SAÍDA ==
#
# A Micro$oft além do Ruindows agora tem sua própria distro Rindux.
#
function string.replacers()
{
	getopt.parse -1 "expr:str:$1" "old:str:$2" "new:str:$3" ... "${@:4}"
	
	local expr=$1

	set "${@:2}"

	while [[ $1 && $expr == *$1* ]]; do
		expr=${expr//$1/$2}
		shift 2
	done

	echo "$expr"

	return $?
}

# .FUNCTION string.split <expr[str]> <sep[str]> <count[int]> -> [str]|[bool]
#
# Retorna uma lista de palavras delimitadas por 'sep' em 'count' vezes.
# Se 'count' for menor que zero aplica a ação em todas as ocorrências.
#
# == EXEMPLO ==
#
# source string.sh
#
# distros='Slackware,Debian,Centos,Ubuntu,Manjaro'
#
# string.split "$distro" ',' -1
# echo ---
# string.split "$distro" ',' 2
#
# == SAÍDA ==
#
# Slackware
# Debian
# Centos
# Ubuntu
# Manjaro
# ---
# Slackware
# Debian
# Centos,Ubuntu,Manjaro
#
function string.split()
{
	getopt.parse 3 "expr:str:$1" "sep:str:$2" "count:int:$3" "${@:4}"

	local c expr=$1
	
	while [[ $expr == *$2* ]]; do
		[[ $((c++)) -eq $3 ]] && break
		expr=${expr/$2/$'\n'}
	done

	mapfile -t expr <<< "$expr"
	printf '%s\n' "${expr[@]}"

	return $?
}

# .FUNCTION string.swapcase <expr[str]> -> [str]|[bool]
#
# Retorna uma cópia de 'expr' convertendo os caracteres minúsculos para
# maiúsculos e vice-versa.
#
function string.swapcase()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	echo "${1~~}"
	return $?
}

# .FUNCTION string.title <expr[str]> -> [str]|[bool]
#
# Retorna uma cópia titulada de 'expr', ou seja, as palavras começam com
# a primeira letra maiúscula e as demais minúsculas.
#
function string.title()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"
	
	local expr=${1,,}
	
	while [[ $expr =~ [^a-zA-Z][a-z] ]]; do
		expr=${expr/$BASH_REMATCH/${BASH_REMATCH^^}}
	done

	echo "${expr^}"

	return $?
}

# .FUNCTION string.reverse <expr[str]> -> [str]|[bool]
#
# Retorna uma cópia invertida da sequẽncia de caracteres de 'expr'.
#
function string.reverse()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	rev <<< "$1"
	return $?
}

# .FUNCTION string.repeat <expr[str]> <count[uint]> -> [str]|[bool]
#
# Retorna uma copia de 'expr' repetida 'N' vezes.
#
function string.repeat()
{
	getopt.parse 2 "expr:str:$1" "count:uint:$2" "${@:3}"

	local i
	for ((i=0; i < $2; i++)); do
		echo -n "$1"
	done; echo
	return $?
}

# .FUNCTION string.zfill <expr[str]> <width[uint]> -> [str]|[bool]
#
# Preenche a expressão com 'N' zeros a esquerda.
#
function string.zfill()
{
	getopt.parse 2 "expr:str:$1" "witdh:uint:$2" "${@:3}"

	local i
	for ((i=0; i < $2; i++)); do
		echo -n '0'
	done; echo "$1"
	return $?
}

# .FUNCTION string.compare <expr1[str]> <expr2[str]> <case[bool]> -> [bool]
#
# Compara as expressões e retorna 'true' se forem iguais, caso contrário 'false'.
# Se 'case' for igual a 'true' ativa a análise tipográfica de diferenciação entre
# caracteres maiúsculos e minúsculos.
#
# == EXEMPLO ==
#
# source string.sh
#
# string.compare 'Linux' 'LINUX' true && echo true || echo false
# string.compare 'Linux' 'LINUX' false && echo true || echo false
#
# == SAÍDA ==
#
# false
# true
#
function string.compare()
{
	getopt.parse 3 "expr1:str:$1" "expr2:str:$2" "case:bool:$3" "${@:4}"

	if $3; then	[ "$1" == "$2" ]; else [ "${1,,}" == "${2,,}" ]; fi
	return $?
}

# .FUNCTION string.contains <expr[str]> <sub[str]> -> [bool]
#
# Retorna 'true' se a expressão contém a substring.
#
function string.contains()
{
	getopt.parse 2 "expr:str:$1" "sub:str:$2" "${@:3}"

	[[ $1 == *$2* ]]
	return $?
}

# .FUNCTION string.map <expr[str]> -> [char]|[uint]
#
# Retorna uma lista iterável da cadeia de caracteres.
#
function string.map()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	local i

	for ((i=0; i < ${#1}; i++)); do
		echo "${1:$i:1}"
	done	

	return $?
}

# .FUNCTION string.fnsmap <expr[str]> <func[function]> <args[str]> ... -> [str]|[bool]
#
# Aplica a função em cada substring delimitada pelo caractere ' ' espaço contido na expressão
# substituindo-a pelo retorno da função.
#
# == EXEMPLO ==
#
# source string.sh
#
# texto='Linux é sinônimo de liberdade e ser livre é uma questão de escolha.'
#
# flag(){
#    echo "[$1]"
# }
#
# char(){
#    echo "[${1:0:1}]"
# }
#
# string.fnsmap "$texto" flag
# string.fnsmap "$texto" char
# string.fnsmap "$texto" string.repeat 2
#
# == SAÍDA ==
#
# [Linux] [é] [sinônimo] [de] [liberdade] [e] [ser] [livre] [é] [uma] [questão] [de] [escolha.] 
# [L] [é] [s] [d] [l] [e] [s] [l] [é] [u] [q] [d] [e] 
# LinuxLinux éé sinônimosinônimo dede liberdadeliberdade ee serser livrelivre éé umauma questãoquestão dede escolha.escolha. 
#
function string.fnsmap()
{
	getopt.parse -1 "expr:str:$1" "func:function:$2" "args:str:$3" ... "${@:4}"

	local expr str
	
	while IFS=$'\n' read -r str; do
		expr+=$($2 "$str" "${@:3}")' '
	done < <(printf '%s\n' $1)

	echo "$expr"

	return $?
}

# .FUNCTION string.fncmap <expr[str]> <func[function]> <args[str]> ... -> [str]|[bool]
#
# Aplica a função em cada caractere da expressão substituindo-o pelo retorno da função.
#
# == EXEMPLO ==
#
# source string.sh
#
# texto='Viva o Linux'
#
# func(){
#    echo "($1)"
# }
#
# string.fncmap "$texto" func
#
# == SAÍDA ==
#
# (V)(i)(v)(a)( )(o)( )(L)(i)(n)(u)(x)
#
function string.fncmap()
{
	getopt.parse -1 "expr:str:$1" "func:function:$2" "args:str:$3" ... "${@:4}"

	local expr i
	
	for ((i=0; i < ${#1}; i++)); do
		expr+=$($2 "${1:$i:1}" "${@:3}")
	done
    
	echo "$expr"

	return $?
}

# .FUNCTION string.filter <expr[str]> <class[str]> ... -> [str]|[bool]
#
# Filtra a expressão retornando apenas a cadeia de caracteres representada
# pela classe. Pode ser especificada mais de uma classe.
#
# Classes suportadas:
#
# [:alnum:]  - todas as letras e dígitos
# [:alpha:]  - todas as letras
# [:blank:]  - todos os espaços brancos na horizontal
# [:cntrl:]  - todos os caracteres de controle
# [:digit:]  - todos os dígitos
# [:graph:]  - todos os caracteres exibíveis, exceto espaços
# [:lower:]  - todas as letras minúsculas
# [:print:]  - todos os caracteres exibíveis, inclusive espaços
# [:punct:]  - todos os caracteres de pontuação
# [:space:]  - todos os espaços brancos na horizontal ou vertical
# [:upper:]  - todas as letras maiúsculas
# [:xdigit:] - todos os dígitos hexadecimais
#
# == EXEMPLO ==
#
# source string.sh
#
# distro='Ubuntu 16.04, Debian 9, Slackware 14'
#
# string.filter "$distro" [:alpha:] [:space:]
# string.filter "$distro" [:digit:]
# string.filter "$distro" [:punct:]
#
# == SAÍDA ==
#
# Ubuntu  Debian  Slackware 
# 1604914
# .,,
#
function string.filter()
{
	getopt.parse -1 "expr:str:$1" "class:str:$2" ... "${@:3}"

	echo "${1//[^${@:2}]/}"
	return $?
}

# .FUNCTION string.field <expr[str]> <sep[str]> <field[int]> ... [str]|[bool]
#
# Retorna 'N' campos delimitados pela substring. Utilize notação negativa para
# captura reversa dos campos, ou seja, se o índice for igual à '-1' é retornado
# o útlimo elemento, '-2' o penúltimo e assim por diante.
#
# == EXEMPLO ==
#
# source string.sh
#
# lista='item1,item2,item3,item4,item5'
#
# string.field "$lista" ',' {1..3}
# string.field "$lista" ',' 1 4
# string.field "$lista" ',' {2..5}
# string.field "$lista" ',' -1
# string.field "$lista" 'item3' 1
#
# == SAÍDA ==
#
# item1 item2 item3 
# item1 item4 
# item2 item3 item4 item5 
# item5 
# item1,item2,
#
function string.field()
{
	getopt.parse -1 "expr:str:$1" "sep:str:$2" "field:int:$3" ... "${@:4}"

	local field fields expr

	mapfile -t fields <<< "${1//$2/$'\n'}"

	for field in ${@:3}; do
		expr+=${fields[$((field > 0 ? field - 1 : field))]}' '
	done

	echo "$expr"

	return $?
}

# .FUNCTION string.slice <expr[str]> <slice[str]> -> [str]|[bool]
#
# Retorna uma substring resultante do intervalo dentro de uma cadeia
# de caracteres. O slice é a represetação do intervalo a ser capturado
# e precisa respeitar o seguinte formato:
#
# [start:len]...
#
# start - Posição inicial dentro da cadeia.
# len   - Comprimento a ser capturado a partir de 'start'.
#
# > Não pode conter espaços entre slices.
# > Utilize notação negativa para captura reversa.
#
# Pode ser especificado mais de um slice dentro da mesma expressão,
# onde o slice subsequente trata a cadeia resultante do slice anterior
# e assim respecitivamente.
#
# == EXEMPLO ==
#
# source string.sh
#
# texto='Programação com shell script'
#
# string.slice "$texto" '[16:]'
# string.slice "$texto" '[:11]'
# string.slice "$texto" '[:-6]'
# string.slice "$texto" '[-1]'
# string.slice "$texto" '[4:10][2:9][:-2]'
#
# == SAÍDA ==
#
# shell script
# Programação
# Programação com shell 
# t
# mação
#
function string.slice()
{
    getopt.parse 2 "expr:str:$1" "slice:str:$2" "${@:3}"

    [[ $2 =~ ${__BUILTIN__[slice]} ]] || error.fatal "'$2' erro de sintaxe na expressão slice"

    local str=$1
    local slice=$2
    local ini len

    while [[ $slice =~ \[([^]]+)\] ]]; do
        IFS=':' read ini len <<< "${BASH_REMATCH[1]}"
        [[ ${len#-} -gt ${#str} ]] && str='' && break
        [[ ${BASH_REMATCH[1]} != *@(:)* ]] && len=1
        ini=${ini:-0}
        len=${len:-$((${#str}-$ini))}
        str=${str:$ini:$len}
        slice=${slice/\[${BASH_REMATCH[1]}\]/}
    done

	echo "$str"

    return $?
}

# .TYPE string_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.len			
# S.capitalize	
# S.center		
# S.count		
# S.endswith		
# S.startswith	
# S.expandspaces	
# S.find			
# S.rfind		
# S.isalnum		
# S.isalpha		
# S.isspace		
# S.isprint		
# S.islower		
# S.isupper		
# S.istitle		
# S.join			
# S.ljust		
# S.rjust		
# S.lower		
# S.upper		
# S.strip		
# S.lstrip		
# S.rstrip		
# S.replace		
# S.fnreplace	
# S.replacers	
# S.split		
# S.swapcase		
# S.title		
# S.reverse		
# S.repeat		
# S.zfill		
# S.compare		
# S.contains		
# S.fnsmap		
# S.fncmap		
# S.filter		
# S.field		
# S.slice
#
typedef string_t			\
		string.len			\
		string.capitalize	\
		string.center		\
		string.count		\
		string.endswith		\
		string.startswith	\
		string.expandspaces	\
		string.find			\
		string.rfind		\
		string.isalnum		\
		string.isalpha		\
		string.isspace		\
		string.isprint		\
		string.islower		\
		string.isupper		\
		string.istitle		\
		string.join			\
		string.ljust		\
		string.rjust		\
		string.lower		\
		string.upper		\
		string.strip		\
		string.lstrip		\
		string.rstrip		\
		string.replace		\
		string.fnreplace	\
		string.replacers	\
		string.split		\
		string.swapcase		\
		string.title		\
		string.reverse		\
		string.repeat		\
		string.zfill		\
		string.compare		\
		string.contains		\
		string.map			\
		string.fnsmap		\
		string.fncmap		\
		string.filter		\
		string.field		\
		string.slice

# Funções
readonly -f string.len			\
			string.capitalize	\
			string.center		\
			string.count		\
			string.endswith		\
			string.startswith	\
			string.expandspaces	\
			string.find			\
			string.rfind		\
			string.isalnum		\
			string.isalpha		\
			string.isspace		\
			string.isprint		\
			string.islower		\
			string.isupper		\
			string.istitle		\
			string.join			\
			string.ljust		\
			string.rjust		\
			string.lower		\
			string.upper		\
			string.strip		\
			string.lstrip		\
			string.rstrip		\
			string.replace		\
			string.fnreplace	\
			string.replacers	\
			string.split		\
			string.swapcase		\
			string.title		\
			string.reverse		\
			string.repeat		\
			string.zfill		\
			string.compare		\
			string.contains		\
			string.map			\
			string.fnsmap		\
			string.fncmap		\
			string.filter		\
			string.field		\
			string.slice

# /* __STRING_SH__ */
