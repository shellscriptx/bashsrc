#!/bin/bash

#----------------------------------------------#
# Source:           builtin.sh
# Data:             9 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:			shellscriptx@gmail.com
#----------------------------------------------#

[[ $__BUILTIN_SH ]] && return 0 

readonly __BUILTIN_SH=1

source error.sh
source getopt.sh
source map.sh
source array.sh
source str.sh
source os.sh

# erros
readonly __BUILTIN_ERR_FUNC_EXISTS='a função já existe ou é um comando interno'


# func has <[str]exp> on <[var]name> => [bool]
#
# Retorna 'true' se 'name' contém 'exp'. Caso contrário 'false'
# 'Name' é o identificador do objeto que pode ser um var, array ou map.
#
# A validação depende do tipo do objeto especificado respeitando os 
# critérios abaixo:
#
# var - verifica se 'exp' está presente na expressão.
# array - verifica se 'exp' é um elemento.
# map - verifica se 'exp' é uma chave válida.
#  
# # Exemplo 1:
#
# #!/bin/bash
# # script: has.sh
#
# source getopt.sh
# source builtin.sh
# source map.sh
# source array.sh
#
# # var
# text="Linux é a minha casa e shell script é o meu idioma."
#
# # array
# declare -a asys
#
# # add        array valor
# array.append asys Windows
# array.append asys Linux
# array.append asys MacOS
#
# # map
# declare -A msys
#
# # add   map  key valor
# map.add msys nt Windows
# map.add msys unix Linux
# map.add msys xnu MacOS
#
# # Verificando
# echo "Contém 'Linux'."
# echo
# echo -n 'text: ' 
# has 'Linux' on text && echo sim || echo não
#
# echo -n 'asys: ' 
# has 'Linux' on asys && echo sim || echo não
#
# echo -n 'msys: '
# has 'Linux' on msys && echo sim || echo não
#
# echo --------------
# 
# echo "Contém 'unix'."
# echo
# echo -n 'text: ' 
# has 'unix' on text && echo sim || echo não
# 
# echo -n 'asys: ' 
# has 'unix' on asys && echo sim || echo não
#
# echo -n 'msys: '
# has 'unix' on msys && echo sim || echo não
#
# # FIM
# 
# ./has.sh
# Contém 'Linux'.
#
# text: sim
# asys: sim
# msys: não
# --------------
# Contém 'unix'.
#
# text: não
# asys: não
# msys: sim
#
# # Exemplo 2:
#
# #!/bin/bash
# script: has2.sh
#
# source getopt.sh
# source builtin.sh
# source map.sh
# source array.sh
#
# # map
# declare -A msys
#
# # add   map  key valor
# map.add msys nt Windows
# map.add msys unix Linux
# map.add msys xnu MacOS
#
# while :
# do
#     echo
#     echo "Map: msys"
#     echo
#
#     read -p 'Digite a chave: ' chave
#
#     if has "$chave" on msys; then
#        echo "Chave encontrada: '$chave'"
#        echo "Valor: ${msys[$chave]}"
#     else
#        echo "aviso: '$chave': a chave solicitada não existe."
#     fi
# done
# 
# # FIM
#
# $ ./has2.sh
# Map: msys
#
# Digite a chave: unix [enter]
# Chave encontrada: 'unix'
# Valor: Linux
#
# Map: msys
#
# Digite a chave: Linux [enter]
# aviso: 'Linux': a chave solicitada não existe.
#
function has(){
	
	getopt.parse "exp:str:+:$1" "on:keyword:+:$2" "name:var:+:$3"
	
	declare -n __obj_ref=$3
	local __type

	read _ __type _ < <(declare -p $3 2>/dev/null)

	case $__type in
		*a*) array.contains $3 "$1";;
		*A*) map.contains $3 "$1";;
		*) str.contains "$__obj_ref" "$1";;
	esac

	return $?
}

# func swap <[var]name1> <[var]name2>
#
# Troca os valores entre 'name1' e 'name'.
#
# # Exemplo:
#
# $ var1=10
# $ var2=30
#
# $ swap var1 var2
# $ echo $var1
# 30
# $ echo $var2
# 10
#
function swap(){
	
	getopt.parse "varname1:str:+:$1" "varname2:str:+:$2"

	declare -n __ref1=$1 __ref2=$2
	local __tmp
	
	__tmp=$__ref1
	__ref1=$__ref2
	__ref2=$__tmp

	return 0
}

# func sum <[int]num> ... => [int]
# 
# Retorna o resultado da soma de todos os elementos.
#
function sum(){

	local num res
	
	for num in $@; do
		getopt.parse "num:int:+:$num"
		res=$((res+num))
	done

	echo "$res"

	return 0
}

# func map <[func]funcname> <[var]name> => [object]
#
# Chama a função 'funcname' a cada iteração de 'name' passando 
# automaticamente o objeto atual como argumento.
#
# O objeto irá depender do tipo de dado em 'name', aplicando
# os seguintes critérios:
#
# var - itera cada caractere da expressão
# array - itera o elemento.
# map - itera a chave.
#
function map(){
	
	getopt.parse "funcname:func:+:$1" "name:var:+:$2"
	
	declare -n __obj_ref=$2
	local __item __key __ch __type
	
	read _ __type _ < <(declare -p $2 2>/dev/null)

	case $__type in
		*a*) for __item in "${__obj_ref[@]}"; do $1 "$__item"; done;;
		*A*) for __key in "${!__obj_ref[@]}"; do $1 "$__key"; done;;
		*) for ((__ch=0; __ch < ${#__obj_ref}; __ch++)); do $1 "${__obj_ref:$__ch:1}"; done;;
	esac

	return 0
}

# func filter <[func]funcname> <[var]name> => [object]
#
# Filtra os elementos contidos em 'name' chamando 'funcname' e passa
# como argumento o elemento atual a cada iteração. Se o retorno da função 
# for igual '0' imprime o valor do elemento, caso contrário nenhum valor 
# é retornado. Objeto 'name' pode ser do tipo var, array ou map.
#
# Exemplo 1:
#
# # Filtrando somente os números pares de um array.
# $ source builtin.sh
#
# $ nums=(1 2 3 4 5 6 7 8 9 10)
# $ par(){
#     # retornando o resto da divisão. Se for '0' é par,
#     # caso contrário é impar.
#     return $(($1%2))
# }
#
# $ filter par nums
# 2
# 4
# 6
# 8
# 10
#
# Exemplo 2:
#
# # Utilizando a função 'str.isupper' para listar somente
# # os caracteres maiúsculos.
# 
# $ source builtin.sh
# $ source str.sh
#
# $ letras='aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ'
# $ maiusculas=$(filter str.isupper letras)
# $ echo $maiusculas
# A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
#
function filter()
{
	getopt.parse "funcname:func:+:$1" "name:var:+:$2"
	
	declare -n __obj_ref=$2
	local __item __key __ch __type
	
	read _ __type _ < <(declare -p $2 2>/dev/null)

	case $__type in
		*a*) for __item in "${__obj_ref[@]}"; do $1 "$__item" && echo "$__item"; done;;
		*A*) for __key in "${!__obj_ref[@]}"; do $1 "$__key" && echo "$__key"; done;;
		*) for ((__ch=0; __ch < ${#__obj_ref}; __ch++)); do $1 "${__obj_ref:$__ch:1}" && 
			echo "${__obj_ref:$__ch:1}"; done;;
	esac

	return 0
}

# func chr <[uint]code> => [char]
#
# Retorna um caractere representado por 'code' na tabela ascii
#
function chr()
{
	getopt.parse "code:uint:+:$1"
	printf \\$(printf "%03o" $1)'\n'
	return 0
}

# func ord <[char]ch> => [uint]
#
# Retorna um valor inteiro da representação ordinal de 'ch'.
#
function ord()
{
	getopt.parse "char:char:-:$1"
	printf '%d\n' "'$1"
	return 0
}

# func hex <[int]num> => [hex]
#
# Converte 'num' para base hexadecimal.
#
function hex()
{
	getopt.parse "num:int:+:$1"
	printf '0x%x\n' $1
	return 0
}

# func bin <[int]num> => [bin]
#
# Converte 'num' para base binária.
#
function bin()
{
	getopt.parse "num:int:+:$1"
	
	local bit i

	for ((i=${1#-}; i > 0; i >>= 1)); do
		bit=$((i&1))$bit
	done
	
	echo ${1//[^-]/}${bit:-0}

	return 0
}

# func oct <[int]num> => [oct]
#
# Converte 'num' para base octal.
#
function oct()
{
	getopt.parse "num:int:+:$1"
	printf '0%o\n' $1
	return 0
}

# func htoi <[hex]base> => [int]
#
# Converte para inteiro a base hexadecimal em 'base'.
#
# Exemplo:
#
# $ source builtin.sh
# $ htoi 0xfc3
# 4035
#
function htoi()
{
	getopt.parse "base:hex:+:$1"
	echo $((16#${1#0x}))
	return 0
}

# func btoi <[bin]base> => [int]
#
# Converte para inteiro a base binária em 'base'.
#
function btoi()
{
	getopt.parse "num:bin:+:$1"
	echo $((2#$1))
	return 0
}

# func otoi <[oct]base> => [int]
#
# Converte para inteiro a base octal em 'base'.
#
function otoi()
{
	getopt.parse "num:oct:+:$1"
	echo $((8#$1))
	return 0
}

# func len <[var]name> => [uint]
#
# Retorna o comprimento de 'name'.
# 'name' pode ser do tipo var, array ou map.
#
# 'var' - retorna o total de caracteres.
# 'array' e 'map' - retorna o total de elementos.
#
# Exemplo:
#
# $ source builtin.sh
#
# $ distro=(Debian Slacware RedHat)
# $ nome='Debian'
#
# $ len distro
# 3
# $ len nome
# 6
#
function len()
{
	getopt.parse "name:var:+:$1"
	
	declare -n __obj_ref=$1
	local __type

	read _ __type _ < <(declare -p $1 2>/dev/null)

	case $__type in
		*a*|*A*) echo ${#__obj_ref[@]};;
		*) echo ${#__obj_ref};;
	esac

	return 0
}

# func range <[int]min> <[int]max> <[int]step> => [int]
#
# Retorna uma lista iterável contendo uma sequência de números inteiros
# a partir de 'min' até 'max' com 'step' intervalos.
#
# Exemplo 1:
#
# # Contagem regressiva de '2' até '-2'.
#
# $ source builtin.sh
# $ range 2 -2 -1
# 2
# 1
# 0
# -1
# -2
#
# Exemplo 2:
#
# # Imprimindo somente os números pares de '1' à '10'.
#
# $ source builtin.sh
# $ range 2 10 2
# 2
# 4
# 6
# 8
# 10
#
function range()
{
	getopt.parse "min:int:+:$1" "max:int:+:$2" "step:int:+:$3"

	local op i

	[[ $1 -ge $2 && $3 -ge 0 ||
	   $1 -le $2 && $3 -le 0 ]]  && return 0
	
	[[ $1 -gt $2 ]] && op='>='
	
	for ((i=$1; i ${op:-<=} $2; i=i+$3)); do
		echo $i
	done			

	return 0
}

# func fnrange <[func]funcname> <[int]min> <[int]max> <[int]step> => [object]
#
# Chama a função 'funcname' a cada iteração do intervalo especificado, passando
# automaticamente o valor atual do elemento como argumento.
#
# Exemplo:
#
# #!/bin/bash
# # script: fnrange.sh
#
# source builtin.sh
# source array.sh
# 
# # Elementos do array
# array.append lista "item1"
# array.append lista "item2"
# array.append lista "item3"
# array.append lista "item4"
# array.append lista "item5"
# array.append lista "item6"
#
# # função 
# del_intervalo()
# {
# 	indice=$1
# 	elemento=$(array.item lista $indice)
# 
# 	# Remove o elemento armazenado no índice recebido
# 	# no parâmetro posicional '$1' que é atualizado a
# 	# cada iteração do intervalo especificado no 'range'.
# 	echo "'$elemento' do índice '$indice'"
# 	array.remove lista "$elemento"
# }
# 
# echo "Lista [antes]:"
# array.list lista
# echo
# 
# echo "Removendo..."
# fnrange del_intervalo 1 6 2
# 
# echo
# echo "Lista [depois]:"
# array.list lista
#
# # FIM
#
# $ ./fnrange.sh
# Lista [antes]:
# 0|item1
# 1|item2
# 2|item3
# 3|item4
# 4|item5
# 5|item6
#
# Removendo...
# 'item2' do índice '1'
# 'item4' do índice '3'
# 'item6' do índice '5'
# 
# Lista [depois]:
# 0|item1
# 2|item3
# 4|item5
#
function fnrange()
{
	getopt.parse "funcname:func:+:$1" "min:int:+:$2" "max:int:+:$3" "step:int:+:$4"

	local op i

	[[ $1 -ge $3 && $4 -ge 0 ||
	   $1 -le $3 && $4 -le 0 ]]  && return 0
	
	[[ $2 -gt $3 ]] && op='>='
	for ((i=$2; i ${op:-<=} $3; i=i+$4)); do $1 $i; done			

	return 0
}

# func isobj <[var]name> => [bool]
#
# Retorna 'true' se o objeto 'name' foi instanciado, caso contrário 'false'.
#
function isobj()
{
	getopt.parse "name:var:+:$1"
	[[ -v $1 ]]
	return $?
}

# func sorted <[var]name> ... => [iterable]
#
# Retorna uma lista iterável em ordem alfabética dos items em 'name'.
# O objeto 'name' deve ser do tipo var, array ou map, podendo especificar
# mais de um objeto.
#
# Ordenação por tipo:
#
# var - As palavras contidas na expressão
# array - Os elementos.
# map - As chaves.
#
function sorted()
{
	local __item __type
	
	for __item in $@; do
		getopt.parse "name:var:+:$__item"
		declare -n __obj_ref=$__item

		read _ __type _ < <(declare -p $__item 2>/dev/null)

		case $__type in
			*a*) printf '%s\n' "${__obj_ref[@]}";;
			*A*) printf '%s\n' "${!__obj_ref[@]}";;
			*) echo -e "${__obj_ref// /\\n}";;
		esac

		declare +n __obj_ref
		unset __obj_ref __type
	done | sort -db

	return 0
}

# func fndef <[func]funcname> <[func]newname>
#
# Cria uma nova referência 'newname' para a chamada de 'funcname'.
# Obs: A nomenclatura original da função é mantida, podendo ser 
# chamada diretamente.
# 
# Exemplo:
#
# $ source builtin.sh
# $ source str.sh
#
# $ texto='shell script é o poder. :D'
#
# # Nova nomenclatura para 'str.toupper'.
# $ fndef str.toupper up
#
# # Executando.
# $ up "$texto"
# SHELL SCRIPT É O PODER. :D
#
function fndef()
{
	getopt.parse "funcname:func:+:$1" "new:funcname:+:$2"

	local line ins

	if which $2 &>/dev/null || declare -fp $2 &>/dev/null; then
		error.__exit "newtype" "funcname" "$2" "$__BUILTIN_ERR_FUNC_EXISTS"
	fi
	
	[[ $(declare -fp $1) =~ \{.*\} ]] && 
	eval "$2()$BASH_REMATCH"
	return 0
}

# func enum <[str]iterable> => [iterable]
#
# Retorna uma lista iterável enumerada.
#
function enum()
{
	local i arr

	mapfile -t arr <<< $1
	for i in ${!arr[@]}; do	echo "$((i+1))|${arr[$i]}"; done
	return 0
}

# func min <[var]name> ... => [object]
#
# Retorna o número inteiro mínimo contido em 'name'.
# Pode ser especificado uma ou mais variáveis do tipo
# var, array ou map.
# Obs: cadeia de caracteres são ignoradas.
#
function min()
{
	local __item __arr __obj

	for __obj in $@; do
		getopt.parse "name:var:+:$__obj"
		
		declare -n __obj_ref=$__obj
		__arr+=${__obj_ref[@]}

		declare +n __obj_ref
		unset __obj_ref
	done
	
	__arr=${__arr//[^0-9-]/ }
	__arr=${__arr//- /}
	__arr=($(printf '%s\n' $__arr | sort -n))
	
	echo "${__arr[0]}"

	return 0
}

# func max <[var]name> ... => [object]
#
# Retorna o número inteiro máximo contido em 'name'.
# Pode ser especificado uma ou mais variáveis do tipo
# var, array ou map.
# Obs: cadeia de caracteres são ignoradas.
#
function max()
{
	local __item __arr __obj

	for __obj in $@; do
		getopt.parse "name:var:+:$__obj"
		
		declare -n __obj_ref=$__obj
		__arr+=${__obj_ref[@]}

		declare +n __obj_ref
		unset __obj_ref
	done
	
	__arr=${__arr//[^0-9-]/ }
	__arr=${__arr//- /}
	__arr=($(printf '%s\n' $__arr | sort -n))
	
	echo "${__arr[$((${#__arr[@]}-1))]}"
	
	return 0
}

# func list <[var]list> <[var]source> ...
#
# Cria uma lista indexada contendo os elementos de 'source'.
# Pode ser especificado um ou mais objetos. Se o objeto for
# do tipo map, a chave é ignorada e somente o elemento é copiado.
#
# Exemplo:
#
# $ source builtin.sh
# $ source array.sh
# $ source map.sh	
#  
# # map
# $ declare -A so
# $ map.add so unix "Linux"
# $ map.add so nt "Windows"
#  
# # array
# $ array.append proc "Intel"
# $ array.append proc "AMD"
#  
# # var
# $ arch='i386/AMD64'
#  
# # Criando a lista com os elementos dos objetos
# # declarados anteriormente.
# $ list nova_lista so proc arch
#  
# # Listando...
# $ array.items nova_lista
# Linux
# Windows
# Intel
# AMD
# i386/AMD64
#
function list()
{
	getopt.parse "name:var:+:$1"
	
	declare -n __obj_dest=$1
	local __item __type

	for __item in ${@:2}; do
		getopt.parse "name:var:+:$__item"
		declare -n __obj_ref=$__item

		read _ __type _ < <(declare -p $__item 2>/dev/null)

		case $__type in
			*a*) __obj_dest+=("$(array.items $__item)");;
			*A*) __obj_dest+=("$(map.items $__item)");;
			*) __obj_dest+=("$__obj_ref");;
		esac

		declare +n __obj_ref
		unset __obj_ref __type
	done	

	return 0	
}

# func unique <[var]source> ... => [iterable]
#
# Retorna uma lista iterável de elementos únicos contidos em 'source',
# emitindo apenas a primeira ocorrência de uma sequência repetida.
# Pode ser especificado um ou mais objetos do tipo var, array ou map.
#
# Exemplo:
#
# $ source builtin.sh
# $ source array.sh
#
# # var
# $ distro='Debian Slackware CentOS RedHat'
#
# # array
# $ array.append arr_dist 'Ubuntu'
# $ array.append arr_dist 'Debian'
# $ array.append arr_dist 'Slackware'
#
# # Listando..
# $ unique distro arr_dist
# CentOS
# Debian
# RedHat
# Slackware
# Ubuntu
#
function unique()
{
	local __item __type

	for __item in $@; do
		getopt.parse "source:var:+:$__item"
		declare -n __obj_ref=$__item

		read _ __type _ < <(declare -p $__item 2>/dev/null)

		case $__type in
			*a*) array.items $__item;;
			*A*) map.items $__item;;
			*) printf '%s\n' $__obj_ref;;
		esac

		declare +n __obj_ref
		unset __obj_ref __type
	done | sort -u

	return 0	
}

# func reversed <[str]iterable> => [iterable]
#
# Reverte os elementos contidos em 'iterable'.
#
function reversed()
{
	local arr
	mapfile -t arr <<< $1
	
	for ((i=${#arr[@]}-1; i >= 0; i--)); do
		echo "${arr[$i]}"
	done

	return 0
}

# func iter <[str]iterable> <[int]start> <[uint]count> => [iterable]
#
# Retorna uma nova lista iterável contendo 'count' elementos de 'iterable'
# a partir da posição 'start'. Se 'count' for igual à '-1' lê todos os
# elementos depois de 'start'. 
# Obs: A lista inicia na posição '0' (zero).
#
# # Exemplo:
#
# # Considere o conteúdo do arquivo 'cores.txt' a seguir:
# $ cat cores.txt
# 1 - azul
# 2 - verde
# 3 - vermelho
# 4 - preto
# 5 - amarelo
# 6 - cinza
# 7 - branco
# 8 - laranja
#
# script: iterable.sh
#
# #!/bin/bash
#
# source builtin.sh
#
# # Listando os três primeiros
# iter "$(cat cores.txt)" 0 3
# echo -------------
#
# # Os três últimos.
# iter "$(cat cores.txt)" -3 3
# echo -------------
#
# # Dois items apartir do anti penúltimo
# iter "$(cat cores.txt)" -4 2
# echo -------------
#
# # O último
# iter "$(cat cores.txt)" -1 1
#
# FIM
#
# $ ./iterable.sh 
# 1 - azul
# 2 - verde
# 3 - vermelho
# -------------
# 6 - cinza
# 7 - branco
# 8 - laranja
# -------------
# 5 - amarelo
# 6 - cinza
# -------------
# 8 - laranja
#
function iter()
{
	getopt.parse "iterable:str:+:$1" "start:int:+:$2" "count:int:+:$3"

	local arr count
	mapfile -t arr <<< $1

	if [[ $3 -eq -1 ]]; then
		count=${#arr[@]}
	elif [[ $3 -gt 0 ]]; then
		count=$3
	fi
	
	printf '%s\n' "${arr[@]:$2:${count:-0}}"

	return 0	
}

# func niter <[str]iterable> <[int]pos> => [str]
#
# Retorna o item na posição 'pos' em 'iterable'.
# Se 'pos' for igual à '-1' retorna o último elemento.
#
function niter()
{
	getopt.parse "iterable:str:+:$1" "pos:int:+:$2"
	
	local item arr
	mapfile -t arr <<< $1
	
	if [[ $2 -ge 0 ]]; then
		item=${arr[$2]}
	elif [[ $2 -eq -1 ]]; then
		item=${arr[$((${#arr[@]}-1))]}
	fi
	
	echo "$item"

	return 0
}

# func mod <[int]x> <[int]y> => [result|remainder]
#
# Retorna o resultado e o resto da divisão de 'x' pelo divisor 'y'.
#
# Exemplo:
#
# $ source builtin.sh
# $ mod 10 3
# 3|1
#
function mod()
{
	getopt.parse "x:int:+:$1" "y:int:+:$2"
	echo "$(($1/$2))|$(($1%$2))"
	return 0
}


readonly -f has \
			sum \
			map \
			filter \
			chr \
			ord \
			hex \
			bin \
			oct \
			htoi \
			btoi \
			otoi \
			len \
			range \
			fnrange \
			sorted \
			fndef \
			enum \
			min \
			max \
			list \
			unique \
			reversed \
			iter \
			mod

# /* BUILTIN_SRC */
