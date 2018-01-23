#!/bin/bash

#----------------------------------------------#
# Source:           string.sh
# Data:             14 de outubro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

# source
[[ $__STRING_SH ]] && return 0

readonly __STRING_SH=1

source builtin.sh

# tipos
__SRC_TYPES[string]='
string.capitalize 
string.center 
string.count 
string.hassuffix 
string.hasprefix 
string.expandspace
string.find 
string.rfind 
string.isalnum 
string.isalpha 
string.isdecimal 
string.isdigit 
string.isspace 
string.isprintable 
string.islower 
string.isupper 
string.istitle 
string.join 
string.ljust 
string.rjust 
string.tolower 
string.toupper 
string.trim 
string.ltrim 
string.rtrim 
string.remove 
string.rmprefix 
string.rmsuffix 
string.replace 
string.fnreplace 
string.nreplace 
string.fnnreplace 
string.split 
string.swapcase 
string.totitle 
string.reverse 
string.repeat 
string.zfill 
string.compare 
string.nocasecompare 
string.contains 
string.fnmap 
string.slice 
string.filter
string.len
string.field
'

# erros
readonly __ERR_STR_SLICE='intervalo do slice inválido'
readonly __ERR_STR_FLAG_CHAR_INVALID='flag de cadeia de caracteres inválida'

# const
readonly STR_LOWERCASE='abcdefghijklmnopqrstuvwxyz'
readonly STR_UPPERCASE='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
readonly STR_LETTERS="${STR_LOWERCASE}${STR_UPPERCASE}"
readonly STR_DIGITS='0123456789'
readonly STR_HEX_DIGITS='0123456789abcdefABCDEF'
readonly STR_OCT_DIGITS='01234567'
readonly STR_PUNCTUATION='!"#$%&\()*+,-./:;<=>?@[\\]^_`{|}~'"'"
readonly STR_WHITESPACE=' \t\n\r\x0b\x0c'
readonly STR_PRINTABLE="${STR_DIGITS}${STR_LETTERS}${STR_PUNCTUATION}${STR_WHITESPACE}"

#
# func string.len <[str]exp> => [uint]
#
# Retorna o comprimento de 'exp'.
#
function string.len()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		echo ${#str}
	done <<< "$1"
	return 0
}

# func string.capitalize <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com o primeiro caractere maiúsculo.
#
function string.capitalize()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"
	
	local str
	while read str; do
		echo "${str^}"
	done <<< "$1"
	return 0
}

# func string.center <[str]exp> <[char]fillchar> <[uint]width> => [str]
#
# Retorna 'exp' centralizado em largura e comprimento. O preenchimento é
# feito usando o caractere 'fillchar'.
#
function string.center()
{
	getopt.parse 3 "exp:str:-:$1" "fillchar:char:-:$2" "width:uint:+:$3" "${@:4}"

	local str ml ch cr l

	while read str; do ((ml < ${#str})) && ml=${#str}; done <<< "$1"

	ml=$(($ml+$3))

	while read str; do
		l=$((ml-${#str}))
		(((l % 2) == 1)) && cr=$2
		((l >= 0)) && printf -v ch "%*s" $((l/2))
		echo "${ch// /$2}${str}${ch// /$2}$cr"
		cr=''
	done <<< "$1"
	
	return 0
}

# func string.count <[str]exp> <[str]sub> => [uint]
#
# Retorna 'N' ocorrências de 'sub' em 'exp'.
#
function string.count()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:-:$2" "${@:3}"

	local str i c
	while read str; do
		c=0
		for ((i=0; i < ${#str}; i++)); do
			[[ ${str:$i:${#2}} == $2 ]] && ((++c))		
		done
		echo "$c"
	done <<< "$1"

	return 0
}

# func string.hassuffix <[str]exp> <[str]suffix> => [bool]
#
# Retorna 'true' se 'exp' termina com o 'suffix' especificado,
# caso contrário 'false'.
#
function string.hassuffix()
{
	getopt.parse 2 "exp:str:-:$1" "suffix:str:-:$2" "${@:3}"

	local str
	while read str; do
		[[ ${str: -${#2}} != $2 ]] && return 1
	done <<< "$1"
	return 0
}

# func string.hasprefix <[str]exp> <[str]prefix> => [bool]
#
# Retorna 'true' se 'exp' inicia com o 'prefix' especificado,
# caso contrário 'false'.
#
function string.hasprefix()
{
	getopt.parse 2 "exp:str:-:$1" "suffix:str:-:$2" "${@:3}"

	local str
	while read str; do
		[[ ${str:0:${#2}} != $2 ]] && return 1
	done <<< "$1"
	return 0
}

# func string.expandspace <[str]exp> <[uint]size> => [str]
#
# Retorna uma seqüência de caracteres em que os caracteres de espaço são expandidos
# para o comprimento especificado em 'size'.
#
function string.expandspace()
{
	getopt.parse 2 "exp:str:-:$1" "tabsize:uint:+:$2" "${@:3}"
	
	local str spc

	printf -v spc "%*s" $2
	while read str; do
		echo "${str// /$spc}"
	done <<< "$1"
	
	return 0
}

# func string.find <[str]exp> <[str]sub> => [int]
#
# Retorna o índice mais baixo em 'exp' onde 'sub' é encontrado. Caso contrário
# índice será igual a '-1'.
#
function string.find()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:+:$2" ${@:3}
	
	local str ind i
	
	while read str; do
		ind=-1
		for ((i=0; i < ${#str}; i++)); do
			[[ "${str:$i:${#2}}" == "$2" ]] && { ind=$i; break; }
		done
		echo "$ind"
	done <<< "$1"

	return 0
}

# func string.rfind <[str]exp> <[str]sub> => [int]
#
# Retorna o índice mais alto em 'exp' onde 'sub' é encontrado. Caso contrário
# índice será igual a '-1'.
#
function string.rfind()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:+:$2" "${@:3}"
	
	local str ind i
	
	while read str; do
		ind=-1
		for ((i=0; i < ${#str}; i++)); do
			[[ "${str:$i:${#2}}" == "$2" ]] && ind=$i
		done
		echo "$ind"
	done <<< "$1"

	return 0
}

# func string.isalnum <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' são alfanuméricos. 
# Caso contrário 'false'.
#
function string.isalnum(){
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		[[ $str != +([[:alnum:]]) ]] && return 1
	done <<< "$1"
	return 0
}

# func string.isalpha <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem alfabéticos. 
# Caso contrário 'false'.
#
function string.isalpha()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		[[ $str != +([[:alpha:]]) ]] && return 1
	done <<< "$1"
	return 0
}

# func string.isdecimal <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem dígitos. 
# Caso contrário 'false'.
#
function string.isdecimal()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		[[ $str != +([[:digit:]]) ]] && return 1
	done <<< "$1"
	return 0
}

# func string.isdigit <[str]exp> => [bool]
#
# O mesmo que 'string.decimal'
#
function string.isdigit()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"
	
	local str
	while read str; do
		[[ $str != +([[:digit:]]) ]] && return 1
	done <<< "$1"
	return 0
}

# func string.isspace <[str]exp> => [bool]
# 
# Retorna 'true' se todos os caracteres em 'exp' forem espaço. 
# Caso contrário 'false'
#
function string.isspace()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		[[ $str != +([[:space:]]) ]] && return 1
	done <<< "$1"
	return 0
}

# func string.isprintable <[str]exp> => [bool]
# 
# Retorna 'true' se todos os caracteres em 'exp' são imprimíveis.
# Caso contrário 'false'
#
function string.isprintable()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"
	
	local str
	while read str; do
		[[ $str != +([[:print:]]) ]] && return 1
	done <<< "$1"
	return 0
}

# func string.islower <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem minúsculos.
# Caso contrário 'false'.
#
function string.islower()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"
	
	local str
	while read str; do
		[[ $str != *([^[:upper:]])+([[:lower:]])*([^[:upper:]]) ]] && return 1
	done <<< "$1"
	return 0 
}

# func string.isupper <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem maiúsculos.
# Caso contrário 'false'.
#
function string.isupper()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		[[ $str != *([^[:lower:]])+([[:upper:]])*([^[:lower:]]) ]] && return 1
	done <<< "$1"
	return 0
}

# func string.istitle <[str]exp> => [bool]
#
# Retorna 'true' se o primeiro caractere de todas as palavras forem maiúsculos.
# Caso contrário 'false'.
#
function string.istitle()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		[[ $str != +(*([^[:alpha:]])@([[:upper:]])+([[:lower:]])) ]] && return 1
	done <<< "$1"
	return 0
}

# func string.join <[str]iterable> <[str]elem> => [str]
#
# Retorna uma string contendo a cópia dos elementos de 'iterable' 
# que seja a concatenação de 'elem' entre elementos.
#
function string.join()
{
	getopt.parse 2 "iterable:str:-:$1" "elem:str:-:$2" "${@:3}"

	local str
	while read str; do
		printf "%s$2" $str
	done <<< "$1"

	return 0
}

# func string.ljust <[str]exp> <[char]fillchar> <[uint]width> => [str]
#
# Retorna 'exp' justificado à esquerda com 'width' de comprimento.
# O preenchimento é feito usando o caractere 'fillchar' especificado 
#
function string.ljust()
{
	getopt.parse 3 "exp:str:-:$1" "fillchar:char:-:$2" "width:uint:+:$3" "${@:4}"

	local str ml ch

	while read str; do ((ml < ${#str})) && ml=${#str}; done <<< "$1"

	ml=$(($ml+$3))

	while read str; do
		printf -v ch '%*s' $((ml-${#str}))
		echo "${ch// /$2}$str"
	done <<< "$1"

	return 0
}

# func string.rjust <[str]exp> <[uint]width> <[char]fillchar> => [str]
#
# Retorna 'exp' justificado à direita com 'width' de comprimento.
# O preenchimento é feito usando o caractere 'fillchar' especificado 
# (o padrão é um espaço)
#
function string.rjust()
{
	getopt.parse 3 "exp:str:-:$1" "fillchar:char:-:$2" "width:uint:+:$3" "${@:4}"
	
	local str ml ch

	while read str; do ((ml < ${#str})) && ml=${#str}; done <<< "$1"

	ml=$(($ml+$3))

	while read str; do
		printf -v ch '%*s' $((ml-${#str}))
		echo "$str${ch// /$2}"
	done <<< "$1"

	return 0
}

# func string.tolower <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo todos os caracteres para minúsculo.
#
function string.tolower()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"
	
	local str
	while read str; do
		echo "${str,,}"
	done <<< "$1"
	return 0
}

# func string.toupper <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo todos os caracteres para maiúsculo.
#
function string.toupper()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		echo "${str^^}"
	done <<< "$1"
	return 0
}

# func string.trim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub'
# à direita e esquerda.
#
function string.trim()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:-:$2" "${@:3}"
	local flag str

	shopt -q extglob && flag='-s' || flag='-u'
	shopt -s extglob

	while read str; do
		str="${str##+($2)}"
		echo "${str%%+($2)}"
	done <<< "$1"

	shopt $flag extglob

	return 0
}	

# func string.ltrim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub' à esquerda.
#
function string.ltrim()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:-:$2" "${@:3}"
	
	local flag str

	shopt -q extglob && flag='-s' || flag='-u'
	shopt -s extglob

	while read str; do
		echo "${str##+($2)}"
	done <<< "$1"
	
	shopt $flag extglob

	return 0
}

# func string.rtrim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub' à direita.
#
function string.rtrim()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:-:$2" "${@:3}"
	
	local flag str

	shopt -q extglob && flag='-s' || flag='-u'
	shopt -s extglob

	while read str; do
		echo "${str%%+($2)}"
	done <<< "$1"

	shopt $flag extglob
	
	return 0
}

# func string.remove <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub'.
#
function string.remove()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:-:$2" "${@:3}"

	local str
	while read str; do
		echo "${str//$2/}"
	done <<< "$1"
	return 0
}

# func string.rmprefix <[str]exp> <[str]prefix> => [str]
#
# Retorna uma cópia de 'exp' removendo o inicio da expressão
# caso comece com 'prefix'.
#
function string.rmprefix()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:-:$2" "${@:3}"

	local str
	while read str; do
		echo "${str#$2}"
	done <<< "$1"
	return 0	
}

# func string.rmsuffix <[str]exp> <[str]suffix> => [str]
#
# Retorna uma cópia de 'exp' removendo o final da expressão
# caso termine com 'suffix'.
#
function string.rmsuffix()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:-:$2" "${@:3}"
	
	local str
	while read str; do
		echo "${str%$2}"
	done <<< "$1"
	return 0	
}

# func string.replace <[str]exp> <[str]old> <[str]new> <[int]count> => [str]
#
# Retorna uma cópia de 'exp' substituindo 'old' por 'new' em 'count' ocorrências.
# Se 'count' for igual à '-1' realiza a substituição em todas as ocorrências.
#
function string.replace()
{
	getopt.parse 4 "exp:str:-:$1" "old:str:-:$2" "new:str:-:$3" "count:int:+:$4" "${@:5}"
	
	local str i c

	while read str; do
		for ((i=0; i < ${#str}; i++)); do
			if [[ ${str:$i:${#2}} == $2 ]]; then
				str=${str:0:$i}${3}${str:$(($i+${#2}))}
				i=$(($i+${#3}))
				[[ $((++c)) -eq $4 ]] && break
			fi
		done
		echo "$str"
	done <<< "$1"

	return 0
}

# func string.fnreplace <[str]exp> <[str]old> <[int]count> <[func]funcname> <[str]args> ... => [str]
#
# Retorna uma cópia de 'exp' substituindo 'old' pelo retorno de 'funcname' em 'count' ocorrências. 
# A função é chamada e a expressão 'old' é passada como argumento posicional '$1' automaticamente
# com N'args' (opcional). Se 'count' for igual '-1' chama a função em todas as ocorrências. 
# 
# Exemplo 1:
#
# $ source string.sh
#
# # Função que converte para maiúsculo.
# $ upper()
# {
#    # retorno da função
#    string.toupper "$1"
# }
#
# $ source string.sh
# $ frase='Viva o linux, linux é vida, linux é o futuro !!!'
#
# $ string.fnreplace "$frase" "linux" -1 upper
# Viva o LINUX, LINUX é vida, LINUX é o futuro !!!
#
# Exemplo 2:
#
# $ source string.sh
# 
# $ texto='laranja, azul e vermelho'
#
# # Passando argumento na função 'string.repeat' para triplicar todas
# # as ocorrências de 'a' no texto.
# $ string.fnreplace "$texto" 'a' -1 string.repeat 3
# laaaraaanjaaa, aaazul e vermelho
#
function string.fnreplace()
{
	getopt.parse -1 "exp:str:-:$1" "old:str:-:$2" "count:int:+:$3" "funcname:func:+:$4" "args:str:-:$5" ... "${@:6}"
	
	local str fn i c

	while read str; do
		for ((i=0; i < ${#str}; i++)); do
			if [[ ${str:$i:${#2}} == $2 ]]; then
				fn=$($4 "$2" "${@:5}")			
				str=${str:0:$i}${fn}${str:$(($i+${#2}))}
				i=$(($i+${#fn}))
				[[ $((++c)) -eq $3 ]] && break
			fi
		done
		echo "$str"
	done <<< "$1"

	return 0
}


# func string.nreplace <[str]exp> <[str]old> <[str]new> <[int]match> => [str]
#
# Retorna uma cópia de 'exp' substituindo uma única vez 'old' por 'new' em
# 'N match' da esquerda para direita.
#
function string.nreplace()
{
	getopt.parse 4 "exp:str:-:$1" "old:str:-:$2" "new:str:-:$3" "match:uint:+:$4" "${@:5}"
	
	local str i m

	while read str; do
		for ((i=0; i < ${#str}; i++)); do
			if [[ ${str:$i:${#2}} == $2 ]]; then
				if [[ $((++m)) -eq $4 ]]; then
					str=${str:0:$i}${3}${str:$(($i+${#2}))}
					i=$(($i+${#3}))
				fi
			fi
		done
		echo "$str"
	done <<< "$1"

	return 0
}

# func string.fnnreplace <[str]exp> <[str]old> <[int]match> <[func]funcname> <[str]args> ...  => [str]
#
# Retorna uma cópia de 'exp' substituindo uma única vez 'old' pelo retorno de 'funcname'. A função
# é chamada em N'match' passando a ocorrência como argumento posicional '$1' com N'args' (opcional).
#
# Exemplo 1:
# 
# # Utilizando a função 'string.toupper' para converter para maiúsculo a primeira
# # ocorrência de 'linux' encontrada.
#
# $ source string.sh
# $ frase='Viva o linux, linux é vida !!!'
# $ tr.fnnreplace "$frase" "linux" 1 string.toupper
# Viva o LINUX, linux é vida !!!
#
function string.fnnreplace()
{
	getopt.parse -1 "exp:str:-:$1" "old:str:-:$2" "match:uint:+:$3" "funcname:func:+:$4" "args:str:-:$5" ... "${@:6}"
	
	local str fn i m

	while read str; do
		for ((i=0; i < ${#str}; i++)); do
			if [[ ${str:$i:${#2}} == $2 ]]; then
				if [[ $((++m)) -eq $3 ]]; then
					fn=$($4 "$2" "${@:5}")			
					str=${str:0:$i}${fn}${str:$(($i+${#2}))}
					i=$(($i+${#fn}))
				fi
			fi
		done
		echo "$str"
	done <<< "$1"

	return 0
}

# func string.split <[str]exp> <[str]sep> => [str]
#
# Retorna uma lista iterável de elementos em 'exp' utilizando 'sep'
# como delimitador.
#
function string.split()
{
	getopt.parse 2 "exp:str:-:$1" "sep:str:-:$2" "${@:3}"

	local str
	while read str; do
		echo -e "${str//$2/\\n}"
	done <<< "$1"
	return 0
}

# func string.swapcase <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo os caracteres de minúsculo para maiúsculo e vice-versa.
#
function string.swapcase()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str
	while read str; do
		echo "${str~~}"
	done <<< "$1"
	return 0
}

# func string.totitle <[str]exp> = [str]
#
# Retorna uma versão titulada de 'exp', ou seja, as palavras começam com
# caractere título. Os caracteres restantes são convertidos para minúsculo.
#
function string.totitle()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local str i ch
	
	while read str; do
		str=${str^}
		for ((i=0; i < ${#str}; i++)); do
			ch=${str:$((i+1)):1}
			[[ ${str:$i:1}${ch} == @([^[:alpha:]])@([[:alpha:]]) ]] &&
			str=${str:0:$((i+1))}${ch^}${str:$((i+2))}
		done
		echo "$str"
	done <<< "$1"

	return 0
}

# func string.reverse <[str]exp> => [str]
#
# Retorna a string 'exp' revertendo a sequência dos caracteres.
#
function string.reverse()
{
	getopt.parse 1 "exp:str:-:$1" ${@:2}

	local line str i
	while read line; do
		for ((i=${#line}-1; i >= 0; i--)); do
			str+=${line:$i:1}
		done
		echo "$str"
		str=''
	done <<< "$1"
	return 0

}

# func string.repeat <[str]exp> <[uint]count> => [str]
#
# Retorna 'count' copias de 'exp'.
#
function string.repeat()
{
	getopt.parse 2 "exp:str:-:$1" "count:uint:+:$2" "${@:3}"

	local str	
	while read str; do
		for ((i=0; i < $2; i++)); do
			echo -n "${str:- }"
		done; echo
	done <<< "$1"
	
#	for ((i=0; i < $2; i++)); do echo -n "$1"; done; echo
	return 0
}

# func string.zfill <[uint]num> <[uint]width> => [uint]
#
# Retorna um inteiro sem sinal com zeros à esquerda para preencher um campo com 'width' comprimento.
#
function string.zfill()
{
	getopt.parse 2 "num:uint:-:$1" "width:uint:+:$2" "${@:3}"

	local str
	while read str; do
		printf -v str "%$2s" "$str"
		echo "${str// /0}"
	done <<< "$1"
	return 0
}

# func string.compare <[str]exp1> <[str]exp2> => [bool]
#
# Retorna 'true' se 'exp1' for igual a 'exp2'. Caso contrário 'false'.
#
function string.compare()
{
	getopt.parse 2 "exp1:str:-:$1" "exp2:str:-:$2" "${@:3}"

	local str
	while read str; do
		[[ $str != $2 ]] && return 1
	done <<< "$1"
	return 0
}

# func string.nocasecompare <[str]exp1> <[str]exp2> => [bool]
#
# Retorna 'true' se 'exp1' for igual a 'exp2', ignorando a diferenciação de caracteres maiúsculos e minúsculos. Caso contrário 'false'.
#
function string.nocasecompare()
{
	getopt.parse 2 "exp1:str:-:$1" "exp2:str:-:$2" "${@:3}"

	local str
	while read str; do
		[[ ${str,,} != ${2,,} ]] && return 1
	done
	return 0
}

# func string.contains <[str]exp> <[str]sub> => [bool]
#
# Retorna 'true' se 'exp' contém 'sub'. Caso contrário 'false'.
# O parâmetro 'sub' pode ser uma expressão regular.
#
function string.contains()
{
	getopt.parse 2 "exp:str:-:$1" "sub:str:-:$2" "${@:3}"

	local str
	while read str; do
		[[ $str != *@($2)* ]] && return 1
	done <<< "$1"
	return 0
}

# func string.fnmap <[str]exp> <[func]funcname> <[str]args> ... => [str]
#
# Retorna uma cópia de 'exp' com todos os caracteres modificados de acordo com
# a função de mapeamento, onde 'funcname' é chamada a cada caractere lido passando
# o mesmo como argumento posicional '$1' com N'args' (opcional).
#
# Exemplo 1:
#
# $ source string.sh
#
# # Duplicando todos os caractere. 
# $ string.fnmap 'Linux' string.repeat 2
# LLiinnuuxx
#
# Exemplo 2:
#
# $ source string.sh
#
# # Adicionado um zero a cada digito.
# $ string.fnmap '11111' string.zfill 2
# 0101010101
#
function string.fnmap()
{
	getopt.parse -1 "exp:str:-:$1" "funcname:func:+:$2" "args:str:-:$3" ... "${@:4}"
	
	local line i
	while read line; do	
		for ((i=0; i<${#line}; i++)); do
			echo -n "$($2 "${line:$i:1}" "${@:3}")"; done
		echo
	done <<< "$1"
	return 0
}

# func string.slice <[str]exp> <[slice]slice> ... => [str]
#
# Retorna uma substring de 'exp' a partir do intervalo 'ini:len' especificado.
# Onde 'ini' indica a posição inicial e 'len' o comprimento. 
# Se 'len' for omitido, lê o comprimento total de 'exp'.
# Se 'ini' for omitido, lê a partir da posição '0'.
# O slice é um argumento variável podendo conter um ou mais intervalos determinando
# o conjunto de captura do slice que o antecede.
#
# Exemplo:
#
# $ texto='Programar em Shell Script é vida'
#
# # Capturando a expressão 'Shell Script'
#
# $ string.slice "$texto" 13:12
# Shell Script
#
# # O mesmo efeito combinando dois slices
#
# $ string.slice "$texto" 13: :-6
# Shell Script
#
# # Lendo os primeiros 25 caracteres
#
# $ string.slice "$texto" :25
# Programar em Shell Script
#
function string.slice()
{
	getopt.parse -1 "exp:str:-:$1" "slice:slice:+:$2" ... "${@:3}"

	local line slice
	while read line; do
		for slice in "${@:2}"; do
			IFS=':' slice=($slice)
			slice[0]=${slice[0]:-0}
			slice[1]=${slice[1]:-$((${#line}-${slice[0]}))}
			line=${line:${slice[0]}:${slice[1]}}
		done
		echo "$line"
	done <<< "$1"

	return 0
}

# func string.filter <[str]exp> <[flag]name> ... => [str]
#
# Retorna uma cópia de 'exp' filtrando somente a sequência de caracteres
# em 'name'.
#
# 'name' deve ser o nome da flag que especifica o tipo da cadeia a ser 
# capturada. Mais de uma 'flag' pode ser informada.
#
# Flags:
#
# alnum   - todas as letras e dígitos
# alpha   - todas as letras
# cntrl   - todos os caracteres de controle
# digit   - todos os dígitos
# graph   - todos os caracteres exibíveis, exceto espaços
# lower   - todas as letras minúsculas
# print   - todos os caracteres exibíveis, inclusive espaços
# punct   - todos os caracteres de pontuação
# upper   - todas as letras maiúsculas
# xdigit  - todos os dígitos hexadecimais
# space   - todos os espaços e tabulações
#  
# Exemplo:
#
# $ source string.sh
# $ texto='Linux nasceu em 1991 e o pai da criança é Linus Torvalds.'
# 
# # Somente os digitos e letras maiúsculas.
# $ string.filter "$texto" digit upper
# L1991LT
#
function string.filter()
{
	getopt.parse -1 "exp:str:-:$1" "flag:str:+:$2" ... "${@:3}"

	local flag flags line

	for flag in ${@:2}; do	
		case $flag in
			alnum|alpha|cntrl|digit|graph|lower|print|punct|upper|xdigit|space) flags+="[:$flag:]";;
			*) error.__trace def "flag" "str" "$flag" "$__ERR_STR_FLAG_CHAR_INVALID"; return $?;;
		esac
	done
	
	while read line; do
		echo "${line//[^$flags]/}"
	done <<< "$1"

	return 0
}

# func string.field <[str]exp> <[char]sep> <[int]num> ... => [str]
#
# Retorna 'N' campo(s) delimitado(s) por 'sep' em 'exp', onde 
# campo inicia a partir da posição '1' podendo especificar um ou mais campos. 
# Utilize notação negativa para leitura reversa, onde '-1' refere-se ao
# último campo, '-2' penúltimo e assim por diante.
#
# Exemplo:
#
# source builtin.sh
#
# texto='Debian,Slackware,CentOS,ArchLinux,Ubuntu,Fedora'
#
# # Somente o primeiro campo
# $ string.field "$texto" ',' 0
# Debian
#
# # Os três primeiros
# $ string.field "$texto" ',' {0..2}
# Debian Slackware CentOS
#
# Todos os campos exceto 'CentOS'
# $ string.field "$texto" ',' {0..1} {3..5}
# Debian Slackware ArchLinux Ubuntu Fedora
#
function string.field()
{
    getopt.parse -1 "exp:str:-:$1" "sep:char:-:$2" "field:int:+:$3" ... "${@:4}"
	
	local i line field
	while read line; do
		IFS="$2" field=($line)
		for i in ${@:3}; do
			echo -n "${field[$(($i-1))]} "
		done; echo
	done <<< "$1"

	return 0
}

# func string.trimspace <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' removendo os espaços excessivos.
#
function string.trimspace()
{
	getopt.parse 1 "exp:str:-:$1" "${@:2}"

	local exp
	while read exp; do
		echo $exp
	done <<< "$1"
	return 0
}

source.__INIT__
# /* __STR_SH */

