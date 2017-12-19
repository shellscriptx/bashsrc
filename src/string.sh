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

# erros
readonly __STR_ERR_SLICE='intervalo do slice inválido'
readonly __STR_ERR_FLAG_CHAR_INVALID='flag de cadeia de caracteres inválida'

# constantes
readonly STR_LOWERCASE='abcdefghijklmnopqrstuvwxyz'
readonly STR_UPPERCASE='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
readonly STR_LETTERS="${STR_LOWERCASE}${STR_UPPERCASE}"
readonly STR_DIGITS='0123456789'
readonly STR_HEX_DIGITS='0123456789abcdefABCDEF'
readonly STR_OCT_DIGITS='01234567'
readonly STR_PUNCTUATION='!"#$%&\()*+,-./:;<=>?@[\\]^_`{|}~'"'"
readonly STR_WHITESPACE=' \t\n\r\x0b\x0c'
readonly STR_PRINTABLE="${STR_DIGITS}${STR_LETTERS}${STR_PUNCTUATION}${STR_WHITESPACE}"

# type string
#
# Manipula uma cadeia de caracteres.
#
# Implementa 'S' com os métodos:
#
# S.len => [uint]
# S.capitalize => [str]
# S.center <[uint]width> <[char]fillchar> => [str]
# S.count <[str]sub> => [uint]
# S.hassuffix <[str]suffix> => [bool]
# S.hasprefix <[str]prefix> => [bool]
# S.expandtabs <[uint]tabsize> => [str]
# S.find <[str]sub> => [int]
# S.rfind <[str]sub> => [int]
# S.isalnum => [bool]
# S.isalpha => [bool]
# S.isdecimal => [bool]
# S.isdigit => [bool]
# S.isspace => [bool]
# S.isprintable => [bool]
# S.islower => [bool]
# S.isupper => [bool]
# S.istitle => [bool]
# S.join <[str]elem> => [str]
# S.ljust <[uint]width> <[char]fillchar> => [str]
# S.rjust <[uint]width> <[char]fillchar> => [str]
# S.tolower => [str]
# S.toupper => [str]
# S.trim <[str]sub> => [str]
# S.ltrim <[str]sub> => [str]
# S.rtrim <[str]sub> => [str]
# S.remove <[str]sub> => [str]
# S.rmprefix <[str]prefix> => [str]
# S.rmsuffix <[str]suffix> => [str]
# S.replace <[str]old> <[str]new> <[int]count> => [str]
# S.fnreplace <[str]old> <[int]count> <[func]funcname> <[str]args> ... => [str]
# S.nreplace <[str]old> <[str]new> <[int]match> => [str]
# S.fnnreplace <[str]old> <[int]match> <[func]funcname> <[str]args> ... => [str]
# S.split <[str]sep> => [str]
# S.swapcase => [str]
# S.totitle = [str]
# S.reverse => [str]
# S.repeat <[uint]count> => [str]
# S.zfill <[uint]width> => [uint]
# S.compare <[str]exp2> => [bool]
# S.nocasecompare <[str]exp2> => [bool]
# S.contains <[str]sub> => [bool]
# S.fnmap <[func]funcname> <[str]args> ... => [str]
# S.slice <[ini:len]slice> ... => [str]
# S.filter <[flag]name> ... => [object]
# S.field <[str]sub> <[uint]num> ... => [str]
# S.trimspace => [str]
#
# Obs: 'S' é uma variável válida.
#

#
# func string.len <[str]exp> => [uint]
#
# Retorna o comprimento de 'exp'.
#
function string.len()
{
	getopt.parse "exp:str:-:$1"
	echo ${#1}
	return 0
}

# func string.capitalize <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com o primeiro caractere maiúsculo.
#
function string.capitalize()
{
	getopt.parse "exp:str:-:$1"
	echo "${1^}"
	return 0
}

# func string.center <[str]exp> <[uint]width> <[char]fillchar> => [str]
#
# Retorna 'exp' centralizado em largura e comprimento. O preenchimento é
# feito usando o caractere 'fillchar'.
#
function string.center()
{
	getopt.parse "exp:str:-:$1" "width:uint:+:$2" "fillchar:char:-:$3"

	local cr ch
	local len=$(($2-${#1}))

	(((len % 2) == 1)) && cr=$3
	((len >= 0)) && printf -v ch "%*s" $((len/2))

	echo "${ch// /${3:- }}$1${ch// /${3:- }}$cr"

	return 0
}

# func string.count <[str]exp> <[str]sub> => [uint]
#
# Retorna 'N' ocorrências de 'sub' em 'exp'. É suportado o uso de expressões
# regulares em 'sub', sendo assim será retornado 'N' padrões casados.
#
function string.count()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"

	local i c=0

	if [[ ${#2} -gt 0 ]]; then
		for ((i=0; i < ${#1}; i++)); do
			[[ "${1:$i:${#2}}" == "$2" ]] && ((c++))
		done
	fi
	
	echo $c

	return 0	
}

# func string.hassuffix <[str]exp> <[str]suffix> => [bool]
#
# Retorna 'true' se 'exp' termina com o 'suffix' especificado,
# caso contrário 'false'.
#
function string.hassuffix()
{
	getopt.parse "exp:str:-:$1" "suffix:str:-:$2"
	[[ "${1: -${#2}}" == "$2" ]]
	return $?
}

# func string.hasprefix <[str]exp> <[str]prefix> => [bool]
#
# Retorna 'true' se 'exp' inicia com o 'prefix' especificado,
# caso contrário 'false'.
#
function string.hasprefix()
{
	getopt.parse "exp:str:-:$1" "suffix:str:-:$2"
	[[ "${1:0:${#2}}" == "$2" ]]
	return $?
}

# func string.expandtabs <[str]exp> <[uint]tabsize> => [str]
#
# retorna uma seqüência de caracteres em que os caracteres de tabulação '\t'
# são expandidos usando espaços, usando opcionalmente o tabsize dado (padrão 8).
#
function string.expandtabs()
{
	getopt.parse "exp:str:-:$1" "tabsize:uint:-:$2"
	
	local t
	
	printf -v t "%*s" ${2:-8}
	echo "${1//\\t/$t}"
	
	return 0
}

# func string.find <[str]exp> <[str]sub> => [int]
#
# Retorna o índice mais baixo em 'exp' onde 'sub' é encontrado. Caso contrário
# índice será igual a '-1'.
#
function string.find()
{
	getopt.parse "exp:str:-:$1" "sub:str:+:$2"
	
	local ind i
	
	for ((i=0; i < ${#1}; i++)); do
		if [[ "${1:$i:${#2}}" == "$2" ]]; then
			ind=$i; break
		fi
	done
		
	echo ${ind:--1}

	return 0
}

# func string.rfind <[str]exp> <[str]sub> => [int]
#
# Retorna o índice mais alto em 'exp' onde 'sub' é encontrado. Caso contrário
# índice será igual a '-1'.
#
function string.rfind()
{
	getopt.parse "exp:str:-:$1" "sub:str:+:$2"
	
	local ind i
	
	for ((i=0; i < ${#1}; i++)); do
		[[ "${1:$i:${#2}}" == "$2" ]] && ind=$i
	done
		
	echo ${ind:--1}

	return 0
}

# func string.isalnum <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' são alfanuméricos. 
# Caso contrário 'false'.
#
function string.isalnum(){
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:alnum:]]+$ ]]
	return $?
}

# func string.isalpha <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem alfabéticos. 
# Caso contrário 'false'.
#
function string.isalpha()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:alpha:]]+$ ]]
	return $?
}

# func string.isdecimal <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem dígitos. 
# Caso contrário 'false'.
#
function string.isdecimal()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:digit:]]+$ ]]
	return $?
}

# func string.isdigit <[str]exp> => [bool]
#
# O mesmo que 'string.decimal'
#
function string.isdigit()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:digit:]]+$ ]]
	return $?
}

# func string.isspace <[str]exp> => [bool]
# 
# Retorna 'true' se todos os caracteres em 'exp' forem espaço. 
# Caso contrário 'false'
#
function string.isspace()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:space:]]+$ ]]
	return $?
}

# func string.isprintable <[str]exp> => [bool]
# 
# Retorna 'true' se todos os caracteres em 'exp' são imprimíveis.
# Caso contrário 'false'
#
function string.isprintable()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:print:]]+$ ]]
	return $?
}

# func string.islower <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem minúsculos.
# Caso contrário 'false'.
#
function string.islower()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:lower:]]+$ ]]
	return $?
}

# func string.isupper <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem maiúsculos.
# Caso contrário 'false'.
#
function string.isupper()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:upper:]]+$ ]]
	return $?
}

# func string.istitle <[str]exp> => [bool]
#
# Retorna 'true' se o primeiro caractere de todas as palavras forem maiúsculos.
# Caso contrário 'false'.
#
function string.istitle()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^([A-Z][a-zA-Z]*[^a-zA-Z]*)+$ ]]
	return $?
}

# func string.join <[str]iterable> <[str]elem> => [str]
#
# Retorna uma string contendo a cópia dos elementos de 'iterable' 
# que seja a concatenação de 'elem' entre elementos.
#
function string.join()
{
	getopt.parse "iterable:str:-:$1" "elem:str:-:$2"

	local exp

	mapfile -t exp <<< "$1"
	exp=$(printf "%s$2" "${exp[@]}")
	echo "${exp%$2}"

	return 0	
}

# func string.ljust <[str]exp> <[uint]width> <[char]fillchar> => [str]
#
# Retorna 'exp' justificado à esquerda com 'width' de comprimento.
# O preenchimento é feito usando o caractere 'fillchar' especificado 
# (o padrão é um espaço)
#
function string.ljust()
{
	getopt.parse "exp:str:-:$1" "width:uint:+:$2" "fillchar:char:-:$3"
	
	local  ch
	local len=$(($2-${#1}))

	((len >= 0)) && printf -v ch "%*s" $len
	echo "$1${ch// /$3}"
	
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
	getopt.parse "exp:str:-:$1" "width:uint:+:$2" "fillchar:char:-:$3"
	
	local  ch
	local len=$(($2-${#1}))

	((len >= 0)) && printf -v ch "%*s" $len
	echo "${ch// /$3}$1"
	
	return 0
}

# func string.tolower <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo todos os caracteres para minúsculo.
#
function string.tolower()
{
	getopt.parse "exp:str:-:$1"
	echo "${1,,}"
	return 0
}

# func string.toupper <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo todos os caracteres para maiúsculo.
#
function string.toupper()
{
	getopt.parse "exp:str:-:$1"
	echo "${1^^}"
	return 0
}

# func string.trim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub'
# à direita e esquerda.
#
function string.trim()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	shopt -s extglob
	local exp="${1##+($2)}"
	echo "${exp%%+($2)}"
	shopt -u extglob
	return 0
}	

# func string.ltrim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub' à esquerda.
#
function string.ltrim()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	shopt -s extglob
	echo "${1##+($2)}"
	shopt -u extglob
	return 0
}

# func string.rtrim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub' à direita.
#
function string.rtrim()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	shopt -s extglob
	echo "${1%%+($2)}"
	shopt -u extglob
	return 0
}

# func string.remove <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub'.
#
function string.remove()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	echo "${1//$2/}"
	return 0
}

# func string.rmprefix <[str]exp> <[str]prefix> => [str]
#
# Retorna uma cópia de 'exp' removendo o inicio da expressão
# caso comece com 'prefix'.
#
function string.rmprefix()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	echo "${1#$2}"
	return 0	
}

# func string.rmsuffix <[str]exp> <[str]suffix> => [str]
#
# Retorna uma cópia de 'exp' removendo o final da expressão
# caso termine com 'suffix'.
#
function string.rmsuffix()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	echo "${1%$2}"
	return 0	
}

# func string.replace <[str]exp> <[str]old> <[str]new> <[int]count> => [str]
#
# Retorna uma cópia de 'exp' substituindo 'old' por 'new' em 'count' ocorrências.
# Se 'count' for igual à '-1' realiza a substituição em todas as ocorrências.
#
function string.replace()
{
	getopt.parse "exp:str:-:$1" "old:str:-:$2" "new:str:-:$3" "count:int:+:$4"
	
	local exp=$1
	local old=$2
	local new=$3
	local c pos

	for ((pos=0; pos < ${#exp}; pos++)); do
		if [[ "${exp:$pos:${#old}}" == "$old" ]]; then
			exp=${exp:0:$pos}${new}${exp:$(($pos+${#old}))}
			pos=$(($pos+${#new}))
			((c++)); [[ $c -eq $4 ]] && break
		fi
	done

	echo "$exp"

	return 0
}

# func string.fnreplace <[str]exp> <[str]old> <[int]count> <[func]funcname> <[str]args> ... => [str]
#
# Retorna uma cópia de 'exp' substituindo 'old' pelo retorno de 'funcname' em 'count' ocorrências. 
# A função é chamada e a expressão 'old' é passada como argumento posicional '$1' automaticamente
# com N'args' (opcional). Se 'count' for igual à '-1' chama a função em todas as ocorrências. 
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
	getopt.parse "exp:str:-:$1" "old:str:-:$2" "count:int:+:$3" "funcname:func:+:$4"
	
	local exp=$1
	local func=$4
	local old=$2
	local pos c

	for ((pos=0; pos < ${#exp}; pos++)); do
		if [[ "${exp:$pos:${#old}}" == "$old" ]]; then
			new=$($func "$old" "${@:5}")			
			exp=${exp:0:$pos}${new}${exp:$(($pos+${#old}))}
			pos=$(($pos+${#new}))
			((c++)); [[ $c -eq $3 ]] && break
		fi
	done

	echo "$exp"

	return 0
}


# func string.nreplace <[str]exp> <[str]old> <[str]new> <[int]match> => [str]
#
# Retorna uma cópia de 'exp' substituindo uma única vez 'old' por 'new' em
# 'N match' da esquerda para direita. Utilize notação negativa para leitura
# reversa. Se match for igual a '-1' será substituído a última ocorrência,
# '-2' para penúltima e assim por diante.
#
function string.nreplace()
{
	getopt.parse "exp:str:-:$1" "old:str:-:$2" "new:str:-:$3" "match:int:+:$4"
	
	local exp=$1
	local old=$2
	local new=$3
	local cond pos op seg m

	if [[ $4 -gt 0 ]]; then
		cond="pos < ${#exp}"; op='pos++'
	fi

	seg=$(($4 >= 0 ? 0 : $((${#exp}-1))))

	for ((pos=seg; ${cond:-pos >= 0}; ${op-pos--})); do
		if [[ "${exp:$pos:${#old}}" == "$old" ]]; then
			((m++))
			if [[ $m -eq ${4#-} ]]; then
				exp=${exp:0:$pos}${new}${exp:$(($pos+${#old}))}
				pos=$(($pos+${#new}))
				break
			fi
		fi
	done

	echo "$exp"

	return 0
}

# func string.fnnreplace <[str]exp> <[str]old> <[int]match> <[func]funcname> <[str]args> ...  => [str]
#
# Retorna uma cópia de 'exp' substituindo uma única vez 'old' pelo retorno de 'funcname'. A função
# é chamada em N'match' passando a ocorrência como argumento posicional '$1' com N'args' (opcional).
# Utilize notação negativa para leitura reversa. Se match for igual a '-1' será substituído a última 
# ocorrência, '-2' para penúltima e assim por diante.
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
# Exemplo 2:
#
# # Convertendo para maiúsculo e invertendo a sequência dos caracteres da
# # última ocorrência.
#
#
# $ source string.sh
# $ frase='Viva o linux, linux é vida !!!'
#
# # Criando sua própria função.
# $ my_func()
# {
#     echo "=> $(string.reverse "$(string.toupper "$1")") <="
# }
#
# $ string.fnnreplace "$frase" "linux" -1 my_func 
# Viva o linux, => XUNIL <= é vida !!!
#
function string.fnnreplace()
{
	getopt.parse "exp:str:-:$1" "old:str:-:$2" "match:int:+:$3" "funcname:func:+:$4"
	
	local exp=$1
	local old=$2
	local func=$4
	local new match cond op pos seg
	
	if [[ $3 -gt 0 ]]; then
		cond="pos < ${#exp}"; op='pos++'
	fi

	seg=$(($3 >= 0 ? 0 : $((${#exp}-1))))

	for ((pos=seg; ${cond:-pos >= 0}; ${op-pos--})); do
		if [[ "${exp:$pos:${#old}}" == "$old" ]]; then
			((match++))
			if [[ $match -eq ${3#-} ]]; then
				new=$($func "$old" "${@:5}")			
				exp=${exp:0:$pos}${new}${exp:$(($pos+${#old}))}
				pos=$(($pos+${#new}))
				break
			fi
		fi
	done

	echo "$exp"

	return 0
}

# func string.split <[str]exp> <[str]sep> => [str]
#
# Retorna uma lista iterável de elementos em 'exp' utilizando 'sep'
# como delimitador.
#
function string.split()
{
	getopt.parse "exp:str:-:$1" "sep:str:-:$2"
	echo -e "${1//$2/\\n}"
	return 0
}

# func string.swapcase <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo os caracteres de minúsculo para maiúsculo e vice-versa.
#
function string.swapcase()
{
	getopt.parse "exp:str:-:$1"
	echo "${1~~}"
	return 0
}

# func string.totitle <[str]exp> = [str]
#
# Retorna uma versão titulada de 'exp', ou seja, as palavras começam com
# caractere título. Os caracteres restantes são convertidos para minúsculo.
#
function string.totitle()
{
	getopt.parse "exp:str:-:$1"

	local exp=${1,,}
	local nch=1 ch i

	for ((i=0; i < ${#exp}; i++)); do
		ch=${exp:$i:1}
		if [[ $ch == ?([a-z]) ]]; then
			if [[ $nch ]]; then
				exp=${exp:0:$i}${ch^}${exp:$((i+1))}
				unset nch
			fi
		else
			nch=1
		fi
	done

	echo "$exp"

	return 0
}

# func string.reverse <[str]exp> => [str]
#
# Retorna a string 'exp' revertendo a sequência dos caracteres.
#
function string.reverse()
{
	getopt.parse "exp:str:-:$1"

	local i

	for ((i=${#1}-1; i >= 0; i--)); do
		printf "%c" "${1:$i:1}"; done; echo

	return 0
}

# func string.repeat <[str]exp> <[uint]count> => [str]
#
# Retorna 'count' copias de 'exp'.
#
function string.repeat()
{
	getopt.parse "exp:str:-:$1" "count:uint:+:$2"
	
	local tmp
	printf -v tmp "%$2s"
	echo "${tmp// /$1}"
	return 0
}

# func string.zfill <[uint]num> <[uint]width> => [uint]
#
# Retorna um inteiro sem sinal com zeros à esquerda para preencher um campo com 'width' comprimento.
#
function string.zfill()
{
	getopt.parse "num:uint:-:$1" "width:uint:+:$2"
	
	local ch
	local len=$(($2-${#1}))

	((len >= 0)) && printf -v ch "%*s" $len
	echo "${ch// /0}$1"
	
	return 0
}

# func string.compare <[str]exp1> <[str]exp2> => [bool]
#
# Retorna 'true' se 'exp1' for igual a 'exp2'. Caso contrário 'false'.
#
function string.compare()
{
	getopt.parse "exp1:str:-:$1" "exp2:str:-:$2"
	[[ "$1" == "$2" ]]
	return $?
}

# func string.nocasecompare <[str]exp1> <[str]exp2> => [bool]
#
# Retorna 'true' se 'exp1' for igual a 'exp2', ignorando a diferenciação de caracteres maiúsculos e minúsculos. Caso contrário 'false'.
#
function string.nocasecompare()
{
	getopt.parse "exp1:str:-:$1" "exp2:str:-:$2"
	[[ "${1,,}" == "${2,,}" ]]
	return $?
}

# func string.contains <[str]exp> <[str]sub> => [bool]
#
# Retorna 'true' se 'exp' contém 'sub'. Caso contrário 'false'.
# O parâmetro 'sub' pode ser uma expressão regular.
#
function string.contains()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	[[ $1 =~ $2 ]]
	return $?
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
	getopt.parse "exp:str:-:$1" "funcname:func:+:$2"
	
	local i
	
	for ((i=0; i<${#1}; i++)); do
		echo -n "$($2 ${1:$i:1} "${@:3}")"; done

	return 0
}

# func string.slice <[str]exp> <[ini:len]slice> ... => [str]
#
# Retorna uma substring de 'exp' a partir do intervalo '[ini:len]' especificado.
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
# $ string.slice "$texto" '[13:12]'
# Shell Script
#
# # O mesmo efeito combinando dois slices
#
# $ string.slice "$texto" '[13:][:-6]'
# Shell Script
#
# # Lendo os primeiros 25 caracteres
#
# $ string.slice "$texto" '[:25]'
# Programar em Shell Script
#
function string.slice()
{
	getopt.parse "exp:str:-:$1" "slice:slice:+:$2"

    local exp=$1
    local slice=$2
	local start
    
	while [[ $slice =~ \[([^]][0-9]*:?(-[0-9]+|[0-9]*))\] ]]
    do
        start=${BASH_REMATCH[1]%:*}
        length=${BASH_REMATCH[1]#*:}
        delm=${BASH_REMATCH[1]//[0-9]/}

        [[ ! $delm ]] && length=1

        exp=${exp:${start:-0}:${length:-${#exp}}}
        slice=${slice/\[${BASH_REMATCH[1]}\]/}
        
    done

    echo  "$exp"

	return 0
}

# func string.filter <[str]exp> <[flag]name> ... => [object]
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
	getopt.parse "flag:str:-:$2"

	local flag flags

	for flag in ${@:2}; do	
		case $flag in
			alnum|alpha|cntrl|digit|graph|lower|print|punct|upper|xdigit|space) flags+="[:$flag:]";;
			*) error.__exit "flag" "str" "$flag" "$__STR_ERR_FLAG_CHAR_INVALID";;
		esac
	done
	
	echo "${1//[^$flags]/}"
	
	return 0
}

# func string.field <[str]exp> <[str]sub> <[uint]num> ... => [str]
#
# Retorna 'num' campo(s) delimitado por 'sub' em 'exp', onde 
# campo inicia a partir da posição '0' (zero). Pode ser 
# especificado um ou mais campos.
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
    getopt.parse "exp:str:-:$1" "sub:str:-:$2"

    local field num str
    local i=0 s=0 d=0

    for num in ${@:3}; do
        getopt.parse "num:uint:+:$num"
        for ((i=s; i < ${#1}; i++)); do
            str=${1:$i:${#2}}
            if [ "$str" == "$2" ]; then
                ((d++)); continue
            elif [ $d -eq $num ]; then
                field+=$str
            elif [ $d -gt $num ]; then
                break
            fi
        done
        field+=' '
        s=$i
    done

    echo "${field% }"

    return 0
}

# func string.trimspace <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' removendo os espaços excessivos.
#
function string.trimspace()
{
	getopt.parse "exp:str:-:$1"
	echo $1
	return 0
}

readonly -f string.len \
			string.capitalize \
			string.center \
			string.count \
			string.hassuffix \
			string.hasprefix \
			string.expandtabs \
			string.find \
			string.rfind \
			string.isalnum \
			string.isalpha \
			string.isdecimal \
			string.isdigit \
			string.isspace \
			string.isprintable \
			string.islower \
			string.isupper \
			string.istitle \
			string.join \
			string.ljust \
			string.rjust \
			string.tolower \
			string.toupper \
			string.trim \
			string.ltrim \
			string.rtrim \
			string.remove \
			string.rmprefix \
			string.rmsuffix \
			string.replace \
			string.fnreplace \
			string.nreplace \
			string.fnnreplace \
			string.split \
			string.swapcase \
			string.totitle \
			string.reverse \
			string.repeat \
			string.zfill \
			string.compare \
			string.nocasecompare \
			string.contains \
			string.fnmap \
			string.slice \
			string.filter \
			string.field \
			string.trimspace 

# /* __STR_SRC */
