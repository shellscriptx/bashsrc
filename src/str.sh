#!/bin/bash

#----------------------------------------------#
# Source:           str.sh
# Data:             14 de outubro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

# source
[[ $__STR_SH ]] && return 0

readonly __STR_SH=1

source builtin.sh

# erros
readonly __STR_ERR_SLICE='intervalo do slice inválido'
readonly __STR_ERR_FLAG_CHAR_INVALID='flag de cadeia de caracteres inválida'

# constantes
readonly str_lowercase='abcdefghijklmnopqrstuvwxyz'
readonly str_uppercase='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
readonly str_letters="${str_lowercase}${str_uppercase}"
readonly str_digits='0123456789'
readonly str_hexdigits='0123456789abcdefABCDEF'
readonly str_octdigits='01234567'
readonly str_punctuation='!"#$%&\()*+,-./:;<=>?@[\\]^_`{|}~'"'"
readonly str_whitespace=' \t\n\r\x0b\x0c'
readonly str_printable="${str_digits}${str_letters}${str_punctuation}${str_whitespace}"


# func str <[var]name> ...
#
# Cria variável do tipo 'str'
#
function str(){ __init_obj_type "$FUNCNAME" "$@"; return $?; }

# func str.len <[str]exp> => [uint]
#
# Retorna o comprimento de 'exp'.
#
function str.len()
{
	getopt.parse "exp:str:-:$1"
	echo ${#1}
	return 0
}

# func str.capitalize <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' com o primeiro caractere maiúsculo.
#
function str.capitalize()
{
	getopt.parse "exp:str:-:$1"
	echo "${1^}"
	return 0
}

# func str.center <[str]exp> <[uint]width> <[char]fillchar> => [str]
#
# Retorna 'exp' centralizado em largura e comprimento. O preenchimento é
# feito usando o caractere 'fillchar'.
#
function str.center()
{
	getopt.parse "exp:str:-:$1" "width:uint:+:$2" "fillchar:char:-:$3"

	local cr ch
	local len=$(($2-${#1}))

	(((len % 2) == 1)) && cr=$3
	((len >= 0)) && printf -v ch "%*s" $((len/2))

	echo "${ch// /${3:- }}$1${ch// /${3:- }}$cr"

	return 0
}

# func str.count <[str]exp> <[str]sub> => [uint]
#
# Retorna 'N' ocorrências de 'sub' em 'exp'. É suportado o uso de expressões
# regulares em 'sub', sendo assim será retornado 'N' padrões casados.
#
function str.count()
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

# func str.hassuffix <[str]exp> <[str]suffix> => [bool]
#
# Retorna 'true' se 'exp' termina com o 'suffix' especificado,
# caso contrário 'false'.
#
function str.hassuffix()
{
	getopt.parse "exp:str:-:$1" "suffix:str:-:$2"
	[[ "${1: -${#2}}" == "$2" ]]
	return $?
}

# func str.hasprefix <[str]exp> <[str]prefix> => [bool]
#
# Retorna 'true' se 'exp' inicia com o 'prefix' especificado,
# caso contrário 'false'.
#
function str.hasprefix()
{
	getopt.parse "exp:str:-:$1" "suffix:str:-:$2"
	[[ "${1:0:${#2}}" == "$2" ]]
	return $?
}

# func str.expandtabs <[str]exp> <[uint]tabsize> => [str]
#
# retorna uma seqüência de caracteres em que os caracteres de tabulação '\t'
# são expandidos usando espaços, usando opcionalmente o tabsize dado (padrão 8).
#
function str.expandtabs()
{
	getopt.parse "exp:str:-:$1" "tabsize:uint:-:$2"
	
	local t
	
	printf -v t "%*s" ${2:-8}
	echo "${1//\\t/$t}"
	
	return 0
}

# func str.find <[str]exp> <[str]sub> => [int]
#
# Retorna o índice mais baixo em 'exp' onde 'sub' é encontrado. Caso contrário
# índice será igual a '-1'.
#
function str.find()
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

# func str.rfind <[str]exp> <[str]sub> => [int]
#
# Retorna o índice mais alto em 'exp' onde 'sub' é encontrado. Caso contrário
# índice será igual a '-1'.
#
function str.rfind()
{
	getopt.parse "exp:str:-:$1" "sub:str:+:$2"
	
	local ind i
	
	for ((i=0; i < ${#1}; i++)); do
		[[ "${1:$i:${#2}}" == "$2" ]] && ind=$i
	done
		
	echo ${ind:--1}

	return 0
}

# func str.isalnum <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' são alfanuméricos. 
# Caso contrário 'false'.
#
function str.isalnum(){
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:alnum:]]+$ ]]
	return $?
}

# func str.isalpha <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem alfabéticos. 
# Caso contrário 'false'.
#
function str.isalpha()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:alpha:]]+$ ]]
	return $?
}

# func str.isdecimal <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem dígitos. 
# Caso contrário 'false'.
#
function str.isdecimal()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:digit:]]+$ ]]
	return $?
}

# func str.isdigit <[str]exp> => [bool]
#
# O mesmo que 'str.decimal'
#
function str.isdigit()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:digit:]]+$ ]]
	return $?
}

# func str.isspace <[str]exp> => [bool]
# 
# Retorna 'true' se todos os caracteres em 'exp' forem espaço. 
# Caso contrário 'false'
#
function str.isspace()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:space:]]+$ ]]
	return $?
}

# func str.isprintable <[str]exp> => [bool]
# 
# Retorna 'true' se todos os caracteres em 'exp' são imprimíveis.
# Caso contrário 'false'
#
function str.isprintable()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:print:]]+$ ]]
	return $?
}

# func str.islower <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem minúsculos.
# Caso contrário 'false'.
#
function str.islower()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:lower:]]+$ ]]
	return $?
}

# func str.isupper <[str]exp> => [bool]
#
# Retorna 'true' se todos os caracteres em 'exp' forem maiúsculos.
# Caso contrário 'false'.
#
function str.isupper()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^[[:upper:]]+$ ]]
	return $?
}

# func str.istitle <[str]exp> => [bool]
#
# Retorna 'true' se o primeiro caractere de todas as palavras forem maiúsculos.
# Caso contrário 'false'.
#
function str.istitle()
{
	getopt.parse "exp:str:-:$1"
	[[ $1 =~ ^([A-Z][a-zA-Z]*[^a-zA-Z]*)+$ ]]
	return $?
}

# func str.join <[str]iterable> <[str]elem> => [str]
#
# Retorna uma string contendo a cópia dos elementos de 'iterable' 
# que seja a concatenação de 'elem' entre elementos.
#
function str.join()
{
	getopt.parse "iterable:str:-:$1" "elem:str:-:$2"

	local exp

	mapfile -t exp <<< "$1"
	exp=$(printf "%s$2" "${exp[@]}")
	echo "${exp%$2}"

	return 0	
}

# func str.ljust <[str]exp> <[uint]width> <[char]fillchar> => [str]
#
# Retorna 'exp' justificado à esquerda com 'width' de comprimento.
# O preenchimento é feito usando o caractere 'fillchar' especificado 
# (o padrão é um espaço)
#
function str.ljust()
{
	getopt.parse "exp:str:-:$1" "width:uint:+:$2" "fillchar:char:-:$3"
	
	local  ch
	local len=$(($2-${#1}))

	((len >= 0)) && printf -v ch "%*s" $len
	echo "$1${ch// /$3}"
	
	return 0
}

# func str.rjust <[str]exp> <[uint]width> <[char]fillchar> => [str]
#
# Retorna 'exp' justificado à direita com 'width' de comprimento.
# O preenchimento é feito usando o caractere 'fillchar' especificado 
# (o padrão é um espaço)
#
function str.rjust()
{
	getopt.parse "exp:str:-:$1" "width:uint:+:$2" "fillchar:char:-:$3"
	
	local  ch
	local len=$(($2-${#1}))

	((len >= 0)) && printf -v ch "%*s" $len
	echo "${ch// /$3}$1"
	
	return 0
}

# func str.tolower <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo todos os caracteres para minúsculo.
#
function str.tolower()
{
	getopt.parse "exp:str:-:$1"
	echo "${1,,}"
	return 0
}

# func str.toupper <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo todos os caracteres para maiúsculo.
#
function str.toupper()
{
	getopt.parse "exp:str:-:$1"
	echo "${1^^}"
	return 0
}

# func str.trim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub'
# à direita e esquerda.
#
function str.trim()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	shopt -s extglob
	local exp="${1##+($2)}"
	echo "${exp%%+($2)}"
	shopt -u extglob
	return 0
}	

# func str.ltrim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub' à esquerda.
#
function str.ltrim()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	shopt -s extglob
	echo "${1##+($2)}"
	shopt -u extglob
	return 0
}

# func str.rtrim <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub' à direita.
#
function str.rtrim()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	shopt -s extglob
	echo "${1%%+($2)}"
	shopt -u extglob
	return 0
}

# func str.remove <[str]exp> <[str]sub> => [str]
#
# Retorna uma cópia de 'exp' removendo todas as ocorrências de 'sub'.
#
function str.remove()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	echo "${1//$2/}"
	return 0
}

# func str.rmprefix <[str]exp> <[str]prefix> => [str]
#
# Retorna uma cópia de 'exp' removendo o inicio da expressão
# caso comece com 'prefix'.
#
function str.rmprefix()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	echo "${1#$2}"
	return 0	
}

# func str.rmsuffix <[str]exp> <[str]suffix> => [str]
#
# Retorna uma cópia de 'exp' removendo o final da expressão
# caso termine com 'suffix'.
#
function str.rmsuffix()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	echo "${1%$2}"
	return 0	
}

# func str.replace <[str]exp> <[str]old> <[str]new> <[int]count> => [str]
#
# Retorna uma cópia de 'exp' substituindo 'old' por 'new' em 'count' ocorrências.
# Se 'count' for igual à '-1' realiza a substituição em todas as ocorrências.
#
function str.replace()
{
	getopt.parse "exp:str:-:$1" "old:str:-:$2" "new:str:-:$3" "count:int:+:$4"
	
	local exp=$1
	local old=$2
	local new=$3
	local c pos

	for ((pos=0; pos < ${#exp}; pos++)); do
		if [[ "${exp:$pos:${#old}}" == "$old" ]]; then
			exp=${exp:0:$pos}${new}${exp:$(($pos+${#old}))}
			pos=$(($pos+${#new}-1))
			((c++)); [[ $c -eq $4 ]] && break
		fi
	done

	echo "$exp"

	return 0
}

# func str.fnreplace <[str]exp> <[str]old> <[func]name> <[int]count> => [str]
#
# Retorna uma cópia de 'exp' substituindo 'old' pelo retorno da função 'name'
# em 'count' ocorrências. A função 'name' é chamada e a expressão 'old' é passada
# como argumento automaticamente. Se 'count' for igual à '-1' realiza a
# substituição em todas as ocorrências. 
# 
# Exemplo:
#
# # Função que converte para maiúsculo.
# $ upper()
# {
#    # retorno da função
#    str.toupper "$1"
# }
#
# $ source str.sh
# $ frase='Viva o linux, linux é vida, linux é o futuro !!!'
#
# $ str.fnreplace "$frase" "linux" upper -1
# Viva o LINUX, LINUX é vida, LINUX é o futuro !!!
#
function str.fnreplace()
{
	getopt.parse "exp:str:-:$1" "old:str:-:$2" "name:func:+:$3" "count:int:+:$4"
	
	local exp=$1
	local func=$3
	local old=$2
	local pos c

	for ((pos=0; pos < ${#exp}; pos++)); do
		if [[ "${exp:$pos:${#old}}" == "$old" ]]; then
			new=$($func "$old")			
			exp=${exp:0:$pos}${new}${exp:$(($pos+${#old}))}
			pos=$(($pos+${#new}-1))
			((c++)); [[ $c -eq $4 ]] && break
		fi
	done

	echo "$exp"

	return 0
}


# func str.nreplace <[str]exp> <[str]old> <[str]new> <[int]match> => [str]
#
# Retorna uma cópia de 'exp' substituindo uma única vez 'old' por 'new' em
# 'N match' da esquerda para direita. Utilize notação negativa para leitura
# reversa. Se match for igual a '-1' será substituído a última ocorrência,
# '-2' para penúltima e assim por diante.
#
function str.nreplace()
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
				pos=$(($pos+${#new}-1))
				break
			fi
		fi
	done

	echo "$exp"

	return 0
}

# func str.fnnreplace <[str]exp> <[str]old> <[func]name> <[int]match> => [str]
#
# Retorna uma cópia de 'exp' substituindo uma única vez 'old' pelo retorno da
# função 'name'. A função é chamada em 'N match' e a string 'old' é passada
# automaticamente como argumento. Utilize notação negativa para 
# leitura reversa. Se match for igual a '-1' será substituído a última ocorrência,
# '-2' para penúltima e assim por diante.
#
# Exemplo 1:
# 
# # Utilizando a função 'str.toupper' para converter para maiúsculo a primeira
# # ocorrência de 'linux' encontrada.
#
# $ source str.sh
# $ frase='Viva o linux, linux é vida !!!'
# $ tr.fnnreplace "$frase" "linux" str.toupper 1
# Viva o LINUX, linux é vida !!!
#
# Exemplo 2:
#
# # Convertendo para maiúsculo e invertendo a sequência dos caracteres da
# # última ocorrência.
#
#
# $ source str.sh
# $ frase='Viva o linux, linux é vida !!!'
#
# # Criando sua própria função.
# $ my_func()
# {
#     echo "=> $(str.reverse "$(str.toupper "$1")") <="
# }
#
# $ str.fnnreplace "$frase" "linux" my_func -1
# Viva o linux, => XUNIL <= é vida !!!
#
function str.fnnreplace()
{
	getopt.parse "exp:str:-:$1" "old:str:-:$2" "name:func:+:$3" "match:int:+:$4"
	
	local exp=$1
	local old=$2
	local func=$3
	local new match cond op pos seg
	
	if [[ $4 -gt 0 ]]; then
		cond="pos < ${#exp}"; op='pos++'
	fi

	seg=$(($4 >= 0 ? 0 : $((${#exp}-1))))

	for ((pos=seg; ${cond:-pos >= 0}; ${op-pos--})); do
		if [[ "${exp:$pos:${#old}}" == "$old" ]]; then
			((match++))
			if [[ $match -eq ${4#-} ]]; then
				new=$($func "$old")			
				exp=${exp:0:$pos}${new}${exp:$(($pos+${#old}))}
				pos=$(($pos+${#new}-1))
				break
			fi
		fi
	done

	echo "$exp"

	return 0
}

# func str.split <[str]exp> <[str]sep> => [str]
#
# Retorna uma lista iterável de elementos em 'exp' utilizando 'sep'
# como delimitador.
#
function str.split()
{
	getopt.parse "exp:str:-:$1" "sep:str:-:$2"
	echo -e "${1//$2/\\n}"
	return 0
}

# func str.swapcase <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' convertendo os caracteres de minúsculo para maiúsculo e vice-versa.
#
function str.swapcase()
{
	getopt.parse "exp:str:-:$1"
	echo "${1~~}"
	return 0
}

# func str.totitle <[str]exp> = [str]
#
# Retorna uma versão titulada de 'exp', ou seja, as palavras começam com
# caractere título. Os caracteres restantes são convertidos para minúsculo.
#
function str.totitle()
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

# func str.reverse <[str]exp> => [str]
#
# Retorna a string 'exp' revertendo a sequência dos caracteres.
#
function str.reverse()
{
	getopt.parse "exp:str:-:$1"

	local i

	for ((i=${#1}-1; i >= 0; i--)); do
		printf "%c" "${1:$i:1}"; done; echo

	return 0
}

# func str.repeat <[str]exp> <[uint]count> => [str]
#
# Retorna 'count' copias de 'exp'.
#
function str.repeat()
{
	getopt.parse "exp:str:-:$1" "count:uint:+:$2"
	
	local tmp
	printf -v tmp "%$2s"
	echo "${tmp// /$1}"
	return 0
}

# func str.zfill <[uint]num> <[uint]width> => [uint]
#
# Retorna um inteiro sem sinal com zeros à esquerda para preencher um campo com 'width' comprimento.
#
function str.zfill()
{
	getopt.parse "num:uint:-:$1" "width:uint:+:$2"
	
	local ch
	local len=$(($2-${#1}))

	((len >= 0)) && printf -v ch "%*s" $len
	echo "${ch// /0}$1"
	
	return 0
}

# func str.compare <[str]exp1> <[str]exp2> => [bool]
#
# Retorna 'true' se 'exp1' for igual a 'exp2'. Caso contrário 'false'.
#
function str.compare()
{
	getopt.parse "exp1:str:-:$1" "exp2:str:-:$2"
	[[ "$1" == "$2" ]]
	return $?
}

# func str.nocasecompare <[str]exp1> <[str]exp2> => [bool]
#
# Retorna 'true' se 'exp1' for igual a 'exp2', ignorando a diferenciação de caracteres maiúsculos e minúsculos. Caso contrário 'false'.
#
function str.nocasecompare()
{
	getopt.parse "exp1:str:-:$1" "exp2:str:-:$2"
	[[ "${1,,}" == "${2,,}" ]]
	return $?
}

# func str.contains <[str]exp> <[str]sub> => [bool]
#
# Retorna 'true' se 'exp' contém 'sub'. Caso contrário 'false'.
# O parâmetro 'sub' pode ser uma expressão regular.
#
function str.contains()
{
	getopt.parse "exp:str:-:$1" "sub:str:-:$2"
	[[ $1 =~ $2 ]]
	return $?
}

# func str.map <[str]exp> <[func]funcname> => [str]
#
# Retorna uma cópia da string 'exp' com todos os seus caracteres modificados
# de acordo com a função de mapeamento.
# Nota: A função de mapeamento é chamada a cada iteração passando o caractere
# da posição atual.
#
# Exemplo 1:
#
#    $ str='shaman'
#    $ new+=$(str.map "$str" str.toupper)
#    $ echo $new
#    Saída:
#        S H A M A N
#
# Exemplo 2:
#
#    $ foo(){
#        echo "letra: <$1>"
#    }
#
#    $ str='foobar'
#    $ str.map "$str" "foo"
#
#    saída:
#        letra: <f>
#        letra: <o>
#        letra: <o>
#        letra: <b>
#        letra: <a>
#        letra: <r>
#
function str.map()
{
	getopt.parse "exp:str:-:$1" "funcname:func:+:$2"
	
	local i
	
	for ((i=0; i<${#1}; i++)); do
		$2 ${1:$i:1}; done

	return 0
}

# func str.slice <[str]exp> <[ini:len]slice> ... => [str]
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
# $ str.slice "$texto" '[13:12]'
# Shell Script
#
# # O mesmo efeito combinando dois slices
#
# $ str.slice "$texto" '[13:][:-6]'
# Shell Script
#
# # Lendo os primeiros 25 caracteres
#
# $ str.slice "$texto" '[:25]'
# Programar em Shell Script
#
function str.slice()
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

# func str.filter <[str]exp> <[flag]name> ... => [object]
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
# $ source str.sh
# $ texto='Linux nasceu em 1991 e o pai da criança é Linus Torvalds.'
# 
# # Somente os digitos e letras maiúsculas.
# $ str.filter "$texto" digit upper
# L1991LT
#
function str.filter()
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

# func str.field <[str]exp> <[str]sub> <[uint]num> ... => [str]
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
# $ str.field "$texto" ',' 0
# Debian
#
# # Os três primeiros
# $ str.field "$texto" ',' {0..2}
# Debian Slackware CentOS
#
# Todos os campos exceto 'CentOS'
# $ str.field "$texto" ',' {0..1} {3..5}
# Debian Slackware ArchLinux Ubuntu Fedora
#
function str.field()
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

# func str.trimspace <[str]exp> => [str]
#
# Retorna uma cópia de 'exp' removendo os espaços excessivos.
#
function str.trimspace()
{
	getopt.parse "exp:str:-:$1"
	echo $1
	return 0
}

readonly -f str.len \
			str.capitalize \
			str.center \
			str.count \
			str.hassuffix \
			str.hasprefix \
			str.expandtabs \
			str.find \
			str.rfind \
			str.isalnum \
			str.isalpha \
			str.isdecimal \
			str.isdigit \
			str.isspace \
			str.isprintable \
			str.islower \
			str.isupper \
			str.istitle \
			str.join \
			str.ljust \
			str.rjust \
			str.tolower \
			str.toupper \
			str.trim \
			str.ltrim \
			str.rtrim \
			str.remove \
			str.rmprefix \
			str.rmsuffix \
			str.replace \
			str.fnreplace \
			str.nreplace \
			str.fnnreplace \
			str.split \
			str.swapcase \
			str.totitle \
			str.reverse \
			str.repeat \
			str.zfill \
			str.compare \
			str.nocasecompare \
			str.contains \
			str.map \
			str.slice \
			str.filter \
			str.field \
			str.trimspace \
			str

# /* __STR_SRC */
