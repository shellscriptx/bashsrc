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

[[ $__BUILTIN_SH ]] && return 0

if ! command -v bash &>/dev/null; then
	echo "bashsrc: erro: interpretador de comandos 'bash' não está instalado" 1>&2
	exit 1
elif ! [[ ${BASH_VERSINFO[0]} -ge 4 && ${BASH_VERSINFO[1]} -ge 3 ]]; then
	echo "bashsrc: erro: requer 'bash v4.3.0' ou superior" 1>&2
	echo "atual: bash $BASH_VERSION" 1>&2
	exit 1
elif ! [[ $BASHSRC_PATH ]]; then
	echo "bashsrc: erro: '\$BASHSRC_PATH' variável de ambiente não está configurada" 1>&2
	exit 1
fi

readonly __BUILTIN_SH=1

declare -A	__INIT_SRC_TYPES \
			__TYPE__ \
			__INIT_OBJ_METHOD \
			__INIT_OBJ_TYPE \
			__INIT_OBJ_SIZE \
			__INIT_OBJ_ATTR \
			__INIT_OBJ
		
declare	__DEPS__
declare __ON_ERROR_RESUME=false

declare __ERR__ \
		__ERR_STACK__ \
		__ERR_ARG__ \
		__ERR_TYPE_ \
		__ERR_VAL__ \
		__ERR_MSG__ \
		__ERR_FUNC__ \
		__ERR_LINE__ \
		__ERR_ARGS__

shopt -s	extglob \
			globasciiranges \
			extquote \
			sourcepath

shopt -u 	nocasematch

__TYPE__[var_t]='
__len__
__quote__
__typeval__
__isnum__
__isnull__
__in__
__dec__
__eq__
__ne__
__gt__
__lt__
__ge__
__le__
__float__
__iter__
__fnmap__
__upper__
__lower__
__rev__
__repl__
__rm__
__swapcase__
__ins__
__app__
__sum__
'

__TYPE__[ptr_t]='
__float__
__in__
__dec__
__fnmap__
__upper__
__lower__
__rev__
__repl__
__rm__
__swapcase__
__ins__
__app__
__sum__
'

__TYPE__[obj_t]='
__del__
__typeof__
__sizeof__
__imp__
__attr__
'

readonly __ARRAY_T=(
var_t
ptr_t
struct_t
map_t
array_t
)

# erros
readonly __ERR_BUILTIN_FUNC_EXISTS='a função já existe ou é um comando interno'
readonly __ERR_BUILTIN_ALREADY_INIT='o objeto já foi implementado'
readonly __ERR_BUILTIN_TYPE_CONFLICT='conflito de tipos: o tipo especificado já foi inicializado'
readonly __ERR_BUILTIN_METHOD_NOT_FOUND='o método de implementação não existe'
readonly __ERR_BUILTIN_METHOD_CONFLICT='conflito de métodos: o método já foi implementado ou é uma função reservada'
readonly __ERR_BUILTIN_DEPS='o pacote requerido não está instalado'
readonly __ERR_BUILTIN_TYPE='o identificador do tipo é inválido'
readonly __ERR_BUILTIN_SRC_TYPE='o tipo do objeto é invalido'
readonly __ERR_BUILTIN_DEL_OBJ='não foi possível deletar o objeto'
readonly __ERR_BUILTIN_TYPE_ARRAY='o tipo já é implementado por array'
readonly __ERR_BUILTIN_IMPLICIT_TYPE='a implementação do tipo é implícita'

readonly NULL=0

readonly -A __FLAG_TYPE=(
[ptr]='^\*'
[file]='.'
[dir]='.'
[path]='.'
[func]='.'
[map]='.'
[array]='.'
[flag]='^[a-zA-Z]+$'
[funcname]='^[a-zA-Z0-9_.-]+$'
[var]='^(_+[a-zA-Z0-9]|[a-zA-Z])[a-zA-Z0-9_]*(\[([0-9]|[1-9][0-9]+)\])?$'
[varname]='^(_+[a-zA-Z0-9]|[a-zA-Z])[a-zA-Z0-9_]*(\[[1-9][0-9]*\])?$'
[srctype]='^(_+[a-zA-Z0-9]|[a-zA-Z])[a-zA-Z0-9_]*_[tT]$'
[st_member]='^(_+[a-zA-Z0-9]|[a-zA-Z])([a-zA-Z0-9_.]+[a-zA-Z])?(\[([1-9][0-9]*)?\])?$'
[uint]='^(0|[1-9][0-9]*)$'
[int]='^(0|[-+]?[1-9][0-9]*)$'
[float]='^[-+]?[0-9](,[0-9]+)$'
[dec]='^[-+]?[0-9]+(.[0-9]+)$'
[char]='^.$'
[str]='^.+$'
[bool]='^(true|false)$'
[zone]='^[+-][0-9]+$'
[bin]='^[01]+$'
[hex]='^(0x)?[0-9a-fA-F]+$'
[oct]='^[0-7]+$'
[size]='^[0-9]+\s*[kKmMgGtTpPeEzZyY][bB]$'
[12h]='^(0[1-9]|1[0-2]):[0-5][0-9]$'
[24h]='^([01][0-9]|2[0-3]):[0-5][0-9]$'
[date]='^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4,})$'
[hour]='^([01][0-9]|2[0-3])$'
[min]='^[0-5][0-9]$'
[sec]='^[0-5][0-9]$'
[mday]='^(0?[1-9]|[12][0-9]|3[01])$'
[month]='^(0?[1-9]|1[0-2])$'
[year]='^[0-9]{4,}$'
[yday]='^(00[1-9]|0[1-9][0-9]|[12][0-9]{2}|3([0-5][0-9]|6[0-6]))$'
[wday]='^[1-7]$'
[url]='^(https?|ftp|smtp)://(www\.)?[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+/?$'
[email]='^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'
[ipv4]='^(([0-9]|[1-9][0-9]|1[0-9]{,2}|2[0-4][0-9]|25[0-5])[.]){3}([0-9]|[1-9][0-9]|1[0-9]{,2}|2[0-4][0-9]|25[0-5])$'
[ipv6]='^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$'
[mac]='^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$'
[slice]='^((0|-?[1-9][0-9]*):?|:?(0|-?[1-9][0-9]*)|(0|-?[1-9][0-9]*):(0|-?[1-9][0-9]*))$'
[uslice]='^((0|[1-9][0-9]*):?|:?(0|[1-9][0-9]*)|(0|[1-9][0-9]*):(0|[1-9][0-9]*))$'
)

readonly -A __FLAG_IN=(
[getopt_nargs]='^(-1|0|[1-9][0-9]*)$'
[getopt_pname]='^[a-zA-Z0-9_=+-]+$'
[getopt_flag]='^(\+|-)$'
[getopt_ctype]='^(_+[a-zA-Z0-9]|[a-zA-Z])[a-zA-Z0-9_]*(\[([1-9][0-9]*)?\])?$'
[var]='^[^[]+$'
[array]='^[^[]+\[\]$'
[szarray]='^[^[]+\[([0-9]|[1-9][0-9]+)\]$'
[farray]='^([^[]+)\[([^]]+)\]$'
)

# func has <[str]exp1> on <[str]exp2> => [bool]
#
# Retorna 'true' se 'exp2' contém 'exp1'. Caso contrário 'false'
#
function has()
{	
	getopt.parse 3 "exp1:str:-:$1" "on:keyword:+:$2" "exp2:str:-:$3" ${@:4}

	local str; while read str; do
		[[ $str == *@($1)* ]] && return 0
	done <<< "$3"

	return 1
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
	
	getopt.parse 2 "varname1:var:+:$1" "varname2:var:+:$2" ${@:3}

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
function sum()
{
	getopt.parse -1 "num:int:-:$1" ... "${@:2}"
	local tmp=($*)
	local nums=${tmp[@]}
	echo $((${nums// /+}))
	return 0
}

# func fnmap <[var]name> <[func]funcname> <[str]args> ...
#
# Chama 'funcname' a cada iteração de 'name' passando automaticamente o elemento
# atual como argumento posicional '$1' seguido de 'N'args (opcional).
#
# O objeto irá depender do tipo de dado em 'name', aplicando os seguintes critérios:
#
# var - itera cada caractere da expressão
# array - itera o elemento.
# map - itera a chave.
#
function fnmap(){
	
	getopt.parse -1 "name:var:+:$1" "funcname:func:+:$2" "args:str:-:$3" ... "${@:4}"
	
	declare -n __obj_ref=$1
	local __item __key __ch __type
	
	IFS=' ' read _ __type _ < <(declare -p $1 2>/dev/null)

	case $__type in
		*a*) for __item in "${__obj_ref[@]}"; do $2 "$__item" "${@:3}"; done;;
		*A*) for __key in "${!__obj_ref[@]}"; do $2 "$__key" "${@:3}"; done;;
		*) for ((__ch=0; __ch < ${#__obj_ref}; __ch++)); do echo -n "$($2 "${__obj_ref:$__ch:1}" "${@:3}")"; done;;
	esac

	return 0
}

# func filter <[var]name> <[func]funcname> <[str]args> ... => [str]
#
# Chama 'funcname' a cada iteração dos elementos contidos em 'name', passando
# automaticamente o elemento atual como argumento posicional '$1' com 'N'args (opcional).
# O elemento é retornado somente se o retorno de 'fucname' for igual à 0 (zero).
#
# O comportamento da iteração irá depender do tipo de objeto passado em 'var'.
#
# var - Lê cada caractere da expressão.
# map - Lê as chaves de map.
# array - Lê os elementos contidos no array.
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
# $ filter nums par
# 2
# 4
# 6
# 8
# 10
#
# Exemplo 2:
#
# # Utilizando a função 'string.isupper' para listar somente
# # os caracteres maiúsculos.
# 
# $ source builtin.sh
# $ source string.sh
#
# $ letras='aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ'
# $ filter letras string.isupper
# ABCDEFGHIJKLMNOPQRSTUVWXYZ
#
function filter()
{
	getopt.parse -1 "name:var:+:$1" "funcname:func:+:$2" "args:str:-:$3" ... "${@:4}"
	
	declare -n __obj_ref=$1
	local __item __key __ch __type
	
	IFS=' ' read _ __type _ < <(declare -p $1 2>/dev/null)

	case $__type in
		*a*) for __item in "${__obj_ref[@]}"; do $2 "$__item" "${@:3}" && echo "$__item"; done;;
		*A*) for __key in "${!__obj_ref[@]}"; do $2 "$__key" "${@:3}" && echo "$__key"; done;;
		*) for ((__ch=0; __ch < ${#__obj_ref}; __ch++)); do $2 "${__obj_ref:$__ch:1}" "${@:3}" && 
			echo -n "${__obj_ref:$__ch:1}"; done; echo;;
	esac

	return 0
}

# func chr <[uint]code> => [char]
#
# Retorna um caractere representado por 'code' na tabela ascii
#
function chr()
{
	getopt.parse 1 "code:uint:+:$1" ${@:2}
	printf \\$(printf "%03o" $1)'\n'
	return 0
}

# func ord <[char]ch> => [uint]
#
# Retorna um valor inteiro da representação ordinal de 'ch'.
#
function ord()
{
	getopt.parse 1 "char:char:-:$1" ${@:2}
	printf '%d\n' "'$1"
	return 0
}

# func hex <[int]num> => [hex]
#
# Converte 'num' para base hexadecimal.
#
function hex()
{
	getopt.parse 1 "num:int:+:$1" ${@:2}
	printf '0x%x\n' $1
	return 0
}

# func bin <[int]num> => [bin]
#
# Converte 'num' para base binária.
#
function bin()
{
	getopt.parse 1 "num:int:+:$1" ${@:2}
	
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
	getopt.parse 1 "num:int:+:$1" ${@:2}
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
	getopt.parse 1 "base:hex:+:$1" ${@:2}
	echo $((16#${1#0x}))
	return 0
}

# func btoi <[bin]base> => [int]
#
# Converte para inteiro a base binária em 'base'.
#
function btoi()
{
	getopt.parse 1 "num:bin:+:$1" ${@:2}
	echo $((2#$1))
	return 0
}

# func otoi <[oct]base> => [int]
#
# Converte para inteiro a base octal em 'base'.
#
function otoi()
{
	getopt.parse 1 "num:oct:+:$1" ${@:2}
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
	getopt.parse 1 "name:var:+:$1" ${@:2}
	
	declare -n __obj_ref=$1
	local __type

	IFS=' ' read _ __type _ < <(declare -p $1 2>/dev/null)

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
	getopt.parse 3 "min:int:+:$1" "max:int:+:$2" "step:int:+:$3" ${@:4}

	local i op
	
	[[ $3 -lt 0 ]] && op='>=' || op='<='
	for ((i=$1; i $op $2; i=i+$3)); do echo "$i"; done

	return 0
}

# func fnrange <[int]min> <[int]max> <[int]step> <[func]funcname> <[str]args> ...
#
# Chama 'funcname' a cada iteração com 'step' intervalo, passando automaticamente o valor
# atual do elemento como argumento posicional '$1' com 'N'args (opcional).
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
# fnrange 1 6 2 del_intervalo
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
	getopt.parse -1 "min:int:+:$1" "max:int:+:$2" "step:int:+:$3" "funcname:func:+:$4" "args:str:-:$5" ... "${@:6}"

	local i op
	
	[[ $3 -lt 0 ]] && op='>=' || op='<='
	for ((i=$1; i $op $2; i=i+$3)); do $4 $i "${@:5}"; done

	return 0
}

# func isobj <[var]name> => [bool]
#
# Retorna 'true' se o objeto 'name' foi instanciado, caso contrário 'false'.
#
function isobj()
{
	getopt.parse 1 "name:var:+:$1" ${@:2}
	[[ ${__INIT_OBJ[${1%%[*}]} ]]
	return $?
}

# func sorted <[var]name> ... => [str]
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
	getopt.parse -1 "name:var:+:$1" ... "${@:2}"
	
	local __item __type
	
	for __item in $@; do
		declare -n __obj_ref=$__item

		IFS=' ' read _ __type _ < <(declare -p $__item 2>/dev/null)

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
# $ source string.sh
#
# $ texto='shell script é o poder. :D'
#
# # Nova nomenclatura para 'string.toupper'.
# $ fndef string.toupper up
#
# # Executando.
# $ up "$texto"
# SHELL SCRIPT É O PODER. :D
#
function fndef()
{
	getopt.parse 2 "funcname:func:+:$1" "new:funcname:+:$2" ${@:3}

	if which $2 &>/dev/null || declare -fp $2 &>/dev/null; then
		error.trace def "newtype" "funcname" "$2" "$__ERR_BUILTIN_FUNC_EXISTS"; return $?
	elif [[ $(declare -fp $1) =~ \{.*\} ]]; then
		eval "$2()$BASH_REMATCH"
	fi

	return $?
}

# func enum <[str]iterable> => [str]
#
# Retorna uma lista iterável enumerada.
#
function enum()
{
	local i iter
	while read iter; do echo "$((++i))|$iter"; done <<< "$1"
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
	getopt.parse -1 "name:var:+:$1" ... "${@:2}"

	local __item __obj
	local -i __arr

	for __obj in $@; do
		declare -n __obj_ref=$__obj
		__arr+=(${__obj_ref[@]})
		unset -n __obj_ref
	done

	__arr=($(printf '%d\n' ${__arr[@]} | sort -n))
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
	getopt.parse -1 "name:var:+:$1" ... "${@:2}"

	local __obj
	local -i __arr

	for __obj in $@; do
		declare -n __obj_ref=$__obj
		__arr+=(${__obj_ref[@]})
		unset -n __obj_ref
	done

	__arr=($(printf '%d\n' ${__arr[@]} | sort -n))
	echo "${__arr[-1]}"
	
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
	getopt.parse -1 "list:var:+:$1" "source:var:+:$2" ... "${@:3}"
	
	declare -n __obj_dest=$1
	local __item

	for __item in ${@:2}; do
		declare -n __obj_ref=$__item
		__obj_dest+=("${__obj_ref[@]}")
		unset -n __obj_ref
	done	

	return 0	
}

# func unique <[var]source> ... => [str]
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
	getopt.parse -1 "source:var:+:$1" ... "${@:2}"

	local __item

	for __item in $@; do
		declare -n __obj_ref=$__item
		printf '%s\n' "${__obj_ref[@]}"
		unset -n __obj_ref
	done | sort -u

	return 0	
}

# func reversed <[str]iterable> => [str]
#
# Reverte os elementos contidos em 'iterable'.
#
function reversed()
{
	getopt.parse 1 "iterable:str:-:$1" ${@:2}

	local arr

	mapfile -t arr <<< "$1"
	
	for ((i=${#arr[@]}-1; i >= 0; i--)); do
		echo "${arr[$i]}"
	done

	return 0
}

# func iter <[str]iterable> <[int]start> <[uint]count> => [str]
#
# Retorna uma nova lista iterável contendo 'count' elementos de 'iterable'
# a partir da posição 'start'. Se 'count' for menor que '0' (zero), lê todos os
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
	getopt.parse 3 "iterable:str:-:$1" "start:int:+:$2" "count:int:+:$3" ${@:4}

	local arr
	mapfile -t arr <<< "$1"
	printf '%s\n' "${arr[@]:$2:$(($3 < 0 ? ${#arr[@]} : $3))}"
	return 0	
}

# func fniter <[str]iterable> <[func]funcname> <[str]args> ... => [str]
#
# Chama 'iterfunc' a cada iteração passando o elemento atual como argumento posicional
# '$1' seguido de N'args' (opcional).
#
function fniter()
{
	getopt.parse -1 "iterable:str:-:$1" "funcname:func:+:$2" "args:str:-:$3" ... "${@:4}"

	local item; while read item; do $2 "$item" "${@:3}"; done <<< "$1"
	return 0
}

# func niter <[str]iterable> <[int]pos> => [str]
#
# Retorna o item na posição 'pos' em 'iterable'. Utilize notação negativa 
# para obter elementos na ordem reversa, considerando '-1' para o último 
# elemento, '-2' penúltimo, '-3' antipenúltimo e assim por diante.
#
function niter()
{
	getopt.parse 2 "iterable:str:-:$1" "pos:int:+:$2" ${@:3}

	local arr
	mapfile -t arr <<< "$1"
	echo "${arr[$2]}"
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
	getopt.parse 2 "x:int:+:$1" "y:int:+:$2" ${@:3}
	echo "$(($1/$2))|$(($1%$2))"
	return 0
}

# func count <[str]iterable> => [uint]
#
# Retorna o total de elementos contidos em uma lista iterável.
#
function count()
{
	getopt.parse 1 "iterable:str:-:$1" ${@:2}
	local c; while read _; do ((++c)); done <<< "$1"; echo $c
	return 0
}

# func all <[str]iterable> <[str]condition> ... => [str]
#
# Retorna os elementos de 'iterable' que satisfazem a todos os critérios
# condicionais estabelecidos em 'condition'. A cada iteração o elemento
# atual é validado por 'N' condition.
#
# São suportados todos os operadores condicionais do comando 'if' 
# 
# Exemplo 1:
#
# # Listando somente os números maiores que '10' e menores que '20' de
# # um determinado arquivo.
#
# #!/bin/bash
# 
# source builtin.sh
#
# all "$(< nums.txt)" '-gt 10' '-lt 20'
#
# Saida:
#
# 11
# 12
# 13
# 14
# 15
# 16
# 17
# 18
# 19
#
# Exemplo 2:
#
# # Lê uma lista de diretórios a partir de um arquivo e verifica qual elemento
# # é um path e um arquivo válido e se possui permissão de escrita.
# 
# dirs.txt
#
# /etc
# /home
# /etc/arquivo_invalido.txt
# /home/usuario/.bashrc
#
# #!/bin/bash
#
# source builtin.sh
#
# all "$(< dirs.txt)" '-e' '-f' '-w'
# 
# # Saída:
#
# /home/shaman/.bashrc
#
function all()
{
	getopt.parse -1 "iterable:str:-:$1" "cond:str:+:$2" ... "${@:3}"
	builtin.__iter_cond_any_all "$1" '&' "${@:2}"
	return 0
}

# func any <[str]iterable> <[str]condition> ... => [str]
#
# Retorna os elementos de 'iterable' que satisfazem a qualquer critério
# condicional estabelecido em 'condition'.
#
# São suportados todos os operadores condicionais do comando 'if' 
#
function any()
{
	getopt.parse -1 "iterable:str:-:$1" "cond:str:+:$2" ... "${@:3}"
	builtin.__iter_cond_any_all "$1" '|' "${@:2}"
	return 0
}

function builtin.__iter_cond_any_all()
{
	local op exp cond iv bit bits iter err

	while read iter; do
		for cond in "${@:3}"; do
			IFS=' ' read iv op exp <<< "$cond"
				[[ $iv != ! ]] && { exp=$op; op=$iv; unset iv; }
				case $op in
					=~) [[ "$iter" =~ $exp ]];;
					==) [[ "$iter" == "$exp" ]];;
					!=) [[ "$iter" != "$exp" ]];;
					-eq) [[ "$iter" -eq "$exp" ]];;
					-ge) [[ "$iter" -ge "$exp" ]];;
					-gt) [[ "$iter" -gt "$exp" ]];;
					-le) [[ "$iter" -le "$exp" ]];;
					-lt) [[ "$iter" -lt "$exp" ]];;
					-ne) [[ "$iter" -ne "$exp" ]];;
					-ef) [[ "$iter" -ef "$exp" ]];;
					-nt) [[ "$iter" -nt "$exp" ]];;
					-ot) [[ "$iter" -ot "$exp" ]];;
					-n) [[ -n "$iter" ]];;
					-z) [[ -z "$iter" ]];;
					-b) [[ -b "$iter" ]];;
					-c) [[ -c "$iter" ]];;
					-d) [[ -d "$iter" ]];;
					-e) [[ -e "$iter" ]];;
					-f) [[ -f "$iter" ]];;
					-g) [[ -g "$iter" ]];;
					-G) [[ -G "$iter" ]];;
					-h) [[ -h "$iter" ]];;
					-k) [[ -k "$iter" ]];;
					-L) [[ -L "$iter" ]];;
					-O) [[ -O "$iter" ]];;
					-p) [[ -p "$iter" ]];;
					-r) [[ -r "$iter" ]];;
					-s) [[ -s "$iter" ]];;
					-S) [[ -S "$iter" ]];;
					-t) [[ -t "$iter" ]];;
					-u) [[ -u "$iter" ]];;
					-w) [[ -w "$iter" ]];;
					-x) [[ -x "$iter" ]];;
					*) err=1;;
				esac &>/dev/null
				
				bit=$(($? ^ 1))
				[[ $iv ]] && bit=$(($bit ^ 1))
				bits+=" $bit $2"
				
				if [[ $err ]]; then
					error.trace def 'cond' 'str' "$cond" 'instrução condicional inválida'
					return $?
				fi
		done
		[[ $((${bits%$2})) -eq 1 ]] && echo "$iter"
		bits=''
	done <<< "$1"

	return 0	
}

# func del <[varname]varname> ... => [bool]
#
# O mesmo que __del__.
#
function del(){ __del__ "$@"; return $?; }

# func var <[varname]varname> ... <[type]typename>
#
# Implementa 'varname' com 'typename'
#
function var()
{
	getopt.parse -1 "varname:varname:+:$1" ... "${@:1:$((${#@}-1))}"
	
	local type fn proto fnref fntype var types
	local vet cv c narr obj attr init objm imp

	type=${@: -1}

	printf -v types '%s|' ${!__INIT_SRC_TYPES[@]}
	printf -v narr '%s|' ${__ARRAY_T[@]}
	printf -v obj '%s|' ${__INIT_SRC_TYPES[obj_t]}
	
	types=${types%|}
	obj=${obj%|}
	narr=${narr%|}
	
	if [[ $type != @($types) ]]; then
		error.trace def 'type' 'type' "$type" "$__ERR_BUILTIN_SRC_TYPE"
		return $?
	elif [[ $type == obj_t ]]; then
		error.trace def 'type' 'type' "$type" "$__ERR_BUILTIN_IMPLICIT_TYPE"
		return $?	
	fi

	for var in ${@:1:$((${#@}-1))}; do
		
		cv=''
		attr=''
		init=''
	
		if [[ $var =~ ${__FLAG_IN[farray]} ]]; then
			var=${BASH_REMATCH[1]}
			cv=${BASH_REMATCH[2]}
			attr=array
		fi

		if [[ $attr && $type == @($narr) ]]; then
			error.trace def 'varname' "$type" "$var" "$__ERR_BUILTIN_TYPE_ARRAY"
			return $?
		elif [[ ${__INIT_OBJ[$var]} ]]; then
			error.trace def 'varname' 'var' "$var" "$__ERR_BUILTIN_ALREADY_INIT"
			return $?
		elif [[ $type == struct_t ]]; then
			if ! [[ $var =~ ${__FLAG_TYPE[srctype]} ]]; then
				error.trace def 'varname' 'var' "$var" "$__ERR_BUILTIN_TYPE"
				return $?	
			elif [[ ${__INIT_SRC_TYPES[$var]} ]]; then
				error.trace src 'varname' 'var' "$var" "$__ERR_BUILTIN_TYPE_CONFLICT"
				return $?
			fi
		fi

		for ((c=0; c < ${cv:-1}; c++)); do
			for fn in ${__INIT_SRC_TYPES[$type]} ${__INIT_SRC_TYPES[obj_t]}; do

				[[ $init && $fn == @($obj) ]] && continue
				[[ $attr && $fn != @($obj) ]] && vet=$var[$c] || vet=''
				[[ ${__INIT_OBJ_TYPE[$type]} == struct_t ]] && objm=${fn#*.} || objm=${fn##*.}
				
				if declare -Fp ${vet:-$var}.$objm &>/dev/null; then
					error.trace imp "" "${vet:-$var}" "$objm" "$__ERR_BUILTIN_METHOD_CONFLICT"
					return $?
				elif [[ $fn == @($obj) ]]; then
					printf -v proto '%s.%s(){ %s "%s"; return $?; }' "$var" "$fn" "$fn" "$var"
				elif [[ ${__INIT_OBJ_TYPE[$type]} == struct_t ]]; then
					printf -v proto '%s.%s(){ 
										getopt.parse 2 "=:keyword:-:$1" "value:%s:-:$2" "${@:3}"; 
										[[ -n $1 ]] && __STRUCT_VAL_MEMBERS[$FUNCNAME]=$2 || 
										echo "${__STRUCT_VAL_MEMBERS[$FUNCNAME]}"; 
										return 0;
								 		}' "${vet:-$var}" "$objm" "${__STRUCT_MEMBER_TYPE[$type.$objm]}"
				else
					fntype=$(declare -fp $fn 2>/dev/null)
					fnref="getopt\.parse\s+-?[0-9]+\s+[\"'][^:]+:(var|map|array|func|$types):[+-]:[^\"']+[\"']"
		
					[[ $fntype =~ $fnref ]] && 
					proto='%s(){ %s "%s" "$@"; return $?; }' ||
					proto='%s(){ %s "${%s}" "$@"; return $?; }'
					
					printf -v proto "$proto" ${vet:-$var}.$objm $fn ${vet:-$var}
				fi
				eval "$proto" || error.trace def
				__INIT_OBJ_METHOD[${vet:-$var}]+="${vet:-$var}.$objm "
			done
			init=1
		done
		__INIT_OBJ_TYPE[$var]=$type
		__INIT_OBJ[$var]=true
		__INIT_OBJ_SIZE[$var]=$c
		__INIT_OBJ_ATTR[$var]=${attr:-var}
	done

	return 0
}


# func __del__ <[var]varname> ... => [bool]
#
# Apaga da memória os objetos implementados e seus elementos inclusive (somente array).
#
function __del__()
{
	getopt.parse -1 "varname:var:+:$1" ... "${@:2}"

	local var fn vet cv c

	for var in $@; do
		[[ ${__INIT_OBJ[$var]} ]] || continue
		[[ ${__INIT_OBJ_ATTR[$var]} == array ]] && vet=1 || vet=''
		cv=${__INIT_OBJ_SIZE[$var]}
		for ((c=0; c < cv; c++)); do
			vet=${vet:+$var[$c]}
			for fn in ${__INIT_OBJ_METHOD[${vet:-$var}]}; do
				unset __STRUCT_VAL_MEMBERS[$fn] \
					  __STRUCT_MEMBER_TYPE[$fn]
			done
			unset -f ${__INIT_OBJ_METHOD[${vet:-$var}]}
			unset	__INIT_OBJ_METHOD[${vet:-$var}] \
					__STRUCT_INIT[$var]
		done
		unset -f ${__INIT_OBJ_METHOD[$var]} 
		unset	__INIT_OBJ_TYPE[$var] \
				__INIT_SRC_TYPES[$var] \
				__INIT_OBJ[$var] \
				__INIT_OBJ_SIZE[$var] \
				__INIT_OBJ_ATTR[$var]

	done || error.trace def

	return 0
}

# func __attr__ <[var]object> => [str]
#
# Retorna o atributo do objeto implementado.
# Os atributos são: 'array' ou 'var'.
#
function __attr__()
{
	getopt.parse 1 "object:var:+:$1" ${@:2}
	echo "${__INIT_OBJ_ATTR[${1%%[*}]}"
	return 0
}

# func __imp__ <[var]object> => [str]
#
# Retorna os métodos implementados do objeto.
#
function __imp__()
{
	getopt.parse 1 "object:var:+:$1" ${@:2}

	local imp
	for imp in 	${__INIT_SRC_TYPES[${__INIT_OBJ_TYPE[${1%%[*}]}]} \
				${__INIT_SRC_TYPES[obj_t]}; do
		echo "$1.${imp##*.}"
	done

	return $?
}

# func __sizeof__ <[var]objname> => [uint]
#
# Retorna o tamanho do objeto
#
function __sizeof__()
{
	getopt.parse 1 "object:var:+:$1" ${@:2}
	echo "${__INIT_OBJ_SIZE[${1%%[*}]:-0}"
	return 0
}

# func __typeof__ <[var]name> => [str]
#
# Retorna o tipo do objeto implementado.
#
function __typeof__()
{
	getopt.parse 1 "object:var:+:$1" ${@:2}
	echo "${__INIT_OBJ_TYPE[${1%%[*}]}"
	return 0
}

# func __len__ <[var]name> => [str]|[uint]
#
# Retorna o índice/chave e o comprimento do elemento armazenado.
#
function __len__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do
		echo "$__elem|${#__byref[$__elem]}"
	done
	return 0
}

# func __quote__ <[var]name> => [str]
#
# Retorna o contéudo da variável escapando os caracteres especiais e não 
# imprimíveis com '\'.
#
function __quote__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	printf "%q\n" "${__byref[@]}"
	return 0
}

# func __typeval__ <[var]name> => [str]|[str]
#
# Retorna o índice/chave e o tipo do dado armazenado na variável.
# Se 'name' for um array, retorna o tipo de todos os elementos.
#
# string - cadeia de caracteres
# int    - número inteiro
# float  - número de ponto flutuante.

function __typeval__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	local __elem __type

	for	__elem in "${!__byref[@]}"; do
		for __type in int float string; do
			[[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[$__type]} ]] && break
		done
		echo "$__elem|$__type"
	done
	
	return 0
}

# func __isnum__ <[var]name> => [bool]
#
# Retorna 'true' se o valor de 'name' é um número.
# Se 'name' for um array, testa todos os elementos.
#
function __isnum__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	local __elem __bit

	for __elem in "${!__byref[@]}"; do
		[[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]]
		__bit+="$?|"
	done

	return $((${__bit%|}))
}

# func __isnull__ <[var]name> => [bool]
#
# Retorna 'true' se 'name' for nula.
#
function __isnull__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	[[ ! ${__byref[@]} ]]
	return $?
}

# func __in__ <[var]name>
#
# Incrementa o valor de 'name'.
# Se 'name' for um array incrementa todos os elementos.
#
function __in__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	local __elem
	
	for __elem in "${!__byref[@]}"; do
		if [[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]]; then
			[[ $($1.__typeof__) == ptr_t ]] &&
			((__byref[$__elem]++)) ||
			echo "$((${__byref[$__elem]}+1))"
		fi
	done
	
	return 0
}

# func __sum__ <[var]name> <[int]num> ...
#
# Incrementa 'name' com a soma de 'N' nums.
# Se 'name' for um array incrementa todos os elementos
#
function __sum__()
{
	getopt.parse -1 "var:var:+:$1" "num:int:-:$2" ... "${@:3}"

	declare -n __byref=$1
	local __tmp __nums __elem

	__tmp=(${*:2})
	__nums=${__tmp[@]}
	
	for __elem in "${!__byref[@]}"; do
		if [[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]]; then
			[[ $($1.__typeof__) == ptr_t ]] &&
			__byref[$__elem]=$((${__byref[$__elem]}+${__nums// /+})) ||
			echo "$((${__byref[$__elem]}+${__nums// /+}))"
		fi
	done

	return 0
}

# func __dec__ <[var]name>
#
# Decrementa o valor de 'name'.
# Se 'name' for um array decrementa todos os elementos.
#
function __dec__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	local __elem
	
	for __elem in "${!__byref[@]}"; do
		if [[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]]; then
			[[ $($1.__typeof__) == ptr_t ]] &&
			((__byref[$__elem]--)) ||
			echo "$((${__byref[$__elem]}-1))"
		fi
	done
	
	return 0
}

# func __eq__ <[var]name> <[str]exp> => [bool]
#
# Retorna 'true' se o valor de 'name' for igual a 'exp'. Caso contrário retorna 'false'.
# Se 'name' for um array verifica todos os elementos.
#
function __eq__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:+:$2" ${@:3}
	
	declare -n __byref=$1
	local __elem
	
	for __elem in "${!__byref[@]}"; do
		[[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]] &&
		[[ ${__byref[$__elem]} -eq $2 ]] ||
		[[ "${__byref[$__elem]}" == "$2" ]] && return 0
	done

	return 1
}

# func __ne__ <[var]name> <[str]exp> => [bool]
#
# Retorna 'true' se o valor de 'name' for diferente de 'exp'. Caso contrário retorna 'false'.
# Se 'name' for um array verifica todos os elementos.
#
function __ne__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:-:$2" ${@:3}

	declare -n __byref=$1
	local __elem
	
	for __elem in "${!__byref[@]}"; do	
		[[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]] &&
		[[ ${__byref[$__elem]} -ne $2 ]] ||
		[[ ${__byref[$__elem]} != $2 ]] && return 0
	done
	return 1
}

# func __gt__ <[var]name> <[str]exp> => [bool]
#
# Retorna 'true' se o valor de 'name' for maior que 'exp'. Caso contrário retorna 'false'.
# Se 'name' for um array verifica todos os elementos.
#
function __gt__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:-:$2" ${@:3}

	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do	
		[[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]] &&
		[[ ${__byref[$__elem]} -gt $2 ]] ||
		[[ ${__byref[$__elem]} > $2 ]] && return 0
	done
	return 1
}

# func __ge__ <[var]name> <[str]exp> => [bool]
#
# Retorna 'true' se o valor de 'name' for maior ou igual a 'exp'. Caso contrário retorna 'false'.
# Se 'name' for um array verifica todos os elementos.
#
function __ge__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:-:$2" ${@:3}
	
	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do
		[[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]] &&
		[[ ${__byref[$__elem]} -ge $2 ]] &&
		return 0
	done
	return 1
}

# func __lt__ <[var]name> <[str]exp> => [bool]
#
# Retorna 'true' se o valor de 'name' for menor que 'exp'. Caso contrário retorna 'false'.
# Se 'name' for um array verifica todos os elementos.
#
function __lt__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:-:$2" ${@:3}

	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do
		[[ ${__byref[@]} =~ ${__FLAG_TYPE[int]} ]] &&
		[[ ${__byref[$__elem]} -lt $2 ]] ||
		[[ ${__byref[$__elem]} < $2 ]] && return 0
	done
	return 1
}

# func __le__ <[var]name> <[str]exp> => [bool]
#
# Retorna 'true' se o valor de 'name' for menor ou igual a 'exp'. Caso contrário retorna 'false'.
# Se 'name' for um array verifica todos os elementos.
#
function __le__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:-:$2" ${@:3}

	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do
		[[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]] && 
		[[ ${__byref[$__elem]} -le $2 ]] && return 0
	done
	return 1
}

# func __float__ <[var]name>
#
# Converte o valor de 'name' para um inteiro de ponto flutuante (precisão).
# Se 'name' for um array converte todos os elementos.
#
function __float__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}

	declare -n __byref=$1
	local __elem
	
	for __elem in "${!__byref[@]}"; do
		if [[ ${__byref[$__elem]} =~ ${__FLAG_TYPE[int]} ]]; then
			[[ $($1.__typeof__) == ptr_t ]] && 
			printf -v __byref[$__elem] "%0.2f" "${__byref[$__elem]}" ||
			printf "%0.2f\n" "${__byref[$__elem]}"
		fi
	done
	return $?
}

# func __upper__ <[var]name>
#
# Converte a sequência de caracteres armazenados em 'name' para maiúsculo.
# Se 'name' for um array converte todos os elementos.
# 
function __upper__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}

	declare -n __byref=$1
	local __elem

	
	for __elem in "${!__byref[@]}"; do
		[[ $($1.__typeof__) == ptr_t ]] && 
		__byref[$__elem]=${__byref[$__elem]^^} ||
		echo "${__byref[$__elem]^^}"
	done
	return $?
}

# func __lower__ <[var]name>
#
# Converte a sequência de caracteres armazenados em 'name' para minúsculo.
# Se 'name' for um array converte todos os elementos.
#
function __lower__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do
		[[ $($1.__typeof__) == ptr_t ]] && 
		__byref[$__elem]=${__byref[$__elem],,} ||
		echo "${__byref[$__elem],,}"
	done
	return $?
}

# func __swapcase__ <[var]name>
#
# Inverte a formatação dos caracteres armazenados em 'name' para  maiúsculo e vice-versa.
# Se 'name' for um array inverte todos os elementos.
#
function __swapcase__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do
		[[ $($1.__typeof__) == ptr_t ]] && 
		__byref[$__elem]=${__byref[$__elem]~~} ||
		echo "${__byref[$__elem]~~}"
	done
	return $?
}

# func __rev__ <[var]name>
#
# Inverte a ordem dos caracteres armazenados em 'name'.
# Se 'name' for um array inverte todos os elementos.
#
function __rev__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}
	
	declare -n __byref=$1
	local __i __tmp __elem

	for __elem in "${!__byref[@]}"; do
		for ((__i=${#__byref[$__elem]}-1; __i >= 0; __i--)); do
			__tmp+=${__byref[$__elem]:$__i:1}
		done
		[[ $($1.__typeof__) == ptr_t ]] && 
		__byref[$__elem]=$__tmp ||
		echo "$__tmp"
		__tmp=''
	done
	return $?
}

# func __repl__ <[var]name> <[str]old> <[str]new>
#
# Substitui todas as ocorrências de 'old' por 'new' em 'name'.
# Se 'name' for um array substitui todos os elementos com a ocorrência.
#
function __repl__()
{
	getopt.parse 3 "var:var:+:$1" "old:str:-:$2" "new:str:-:$3" ${@:4}
	
	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do
		[[ $($1.__typeof__) == ptr_t ]] && 
		__byref[$__elem]=${__byref[$__elem]//$2/$3} ||
		echo "${__byref[$__elem]//$2/$3}"
	done
	return $?
}

# func __rm__ <[var]name> <[str]exp>
#
# Remove todas as ocorrências de 'exp' em 'name'.
# Se 'name' for um array remove a ocorrẽncia em todos os elementos.
#
function __rm__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:-:$2" ${@:3}
	
	declare -n __byref=$1
	local __elem

	for __elem in "${!__byref[@]}"; do
		[[ $($1.__typeof__) == ptr_t ]] && 
		__byref[$__elem]=${__byref[$__elem]//$2/} ||
		echo "${__byref[$__elem]//$2/}"
	done
	return $?
}

# func __ins__ <[var]name> <[str]prefix>
#
# Insere 'prefix' em 'name'.
# Se 'name' for um array, insere em todos os elementos.
#
function __ins__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:+:$2" ${@:3}

	declare -n __byref=$1
	local __elem
	
	for __elem in "${!__byref[@]}"; do
		[[ $($1.__typeof__) == ptr_t ]] && 
		__byref[$__elem]=${2}${__byref[$__elem]} ||
		echo "${2}${__byref[$__elem]}"
	done
	return $?
}

# func __app__ <[var]name> <[str]suffix>
#
# Anexa 'suffix' em 'name'.
# Se 'name' for um array, anexa em todos os elementos.
#
function __app__()
{
	getopt.parse 2 "var:var:+:$1" "exp:str:+:$2" ${@:3}

	declare -n __byref=$1
	local __elem
	
	for __elem in "${!__byref[@]}"; do
		[[ $($1.__typeof__) == ptr_t ]] && 
		__byref[$__elem]=${__byref[$__elem]}${2} ||
		echo "${__byref[$__elem]}${2}"
	done
	return $?
}

# func __fnmap__ <[var]name> <[func]funcname> <[str]args> ...
#
# Chama 'funcname'a cada iteração de caracteres ou elementos armazenados em 'name', passando
# automaticamente como parâmetro posicional '$1' o item atual com 'N'args (opcional).
#
function __fnmap__()
{
	getopt.parse -1 "var:var:+:$1" "funcname:func:+:$2" "args:str:-:$3" ... "${@:4}"
	
	local __tmp __i __attr
	declare -n __byref=$1

	if IFS=' ' read _ __attr _ < <(declare -p $1 2>/dev/null); then
		case $__attr in
			*a*|*A*)	for __i in "${!__byref[@]}"; do
							[[ $($1.__typeof__) == ptr_t ]] &&
							__byref[$__i]=$($2 "${__byref[$__i]}" "${@:3}") ||
							echo "$($2 "${__byref[$__i]}" "${@:3}")"
						done;;

			*)			for ((__i=0; __i < ${#__byref}; __i++)); do
							__tmp+=$($2 "${__byref:$__i:1}" "${@:3}")
						done
						[[ $($1.__typeof__) == ptr_t ]] &&
						__byref=$__tmp ||
						echo "$__tmp"
		esac
	fi

	return $?
}

# func __iter__ <[var]name> => [str]
#
# Retorna uma lista iterável contendo os elementos armazenados em 'name'. O retorno da função
# depende do tipo da variável, sendo:
#
# var       - retorna um caractere por linha.
# array|map - retorna um elemento por linha.
#
function __iter__()
{
	getopt.parse 1 "var:var:+:$1" ${@:2}

	local __attr __ch __i
	declare -n __byref=$1
	
	if IFS=' ' read _ __attr _ < <(declare -p $1 2>/dev/null); then
		case $__attr in
			*a*|*A*)	printf '%s\n' "${__byref[@]}";;
			*)			for ((__i=0; __i<${#__byref}; __i++)); do 
							__ch[$__i]=${__byref:$__i:1}; done
							printf "%s\n" "${__ch[@]}";;
		esac
	fi	

	return $?
}

function source.__INIT__()
{
	local attr type fn types func pkg err deps

	printf -v types '%s|' ${!__INIT_SRC_TYPES[@]}
	types=${types%|}
	
	for pkg in $__DEPS__; do
		command -v $pkg &>/dev/null || { err=1; deps+="$pkg, "; }
	done

	if [[ $err ]]; then
		error.trace deps '' "${BASH_SOURCE[-2]}" "${deps%, }" "$__ERR_BUILTIN_DEPS"
		return $?
	fi

	if IFS=' ' read _ attr _ < <(declare -p __TYPE__ 2>/dev/null) && ! [[ $attr =~ A ]]; then
		error.trace src '' "${BASH_SOURCE[-2]}" '' "'__TYPE__' não é um array associativo"
		return $?
	fi	

	for type in ${!__TYPE__[@]}; do
		if ! [[ $type =~ ${__FLAG_TYPE[srctype]} ]]; then
			error.trace def '' "${BASH_SOURCE[-2]}" "$type" "$__ERR_BUILTIN_TYPE"
			return $?	
		elif [[ $type == @($types) ]]; then
			error.trace src '' "${BASH_SOURCE[-2]}" "$type" "$__ERR_BUILTIN_TYPE_CONFLICT"
			return $?
		fi
		for fn in ${__TYPE__[$type]}; do
			if ! declare -Fp $fn &>/dev/null; then
				error.trace imp '' "$type" "$fn" "$__ERR_BUILTIN_METHOD_NOT_FOUND"
				return $?
			fi
		done
		__INIT_SRC_TYPES[$type]=${__TYPE__[$type]}
		unset __TYPE__[$type] || error.trace def
	done

	while IFS=' ' read _ _ func; do readonly -f $func; done < <(declare -Fp)
	
	__DEPS__=''
	
	return 0
}

source getopt.sh
source struct.sh
source error.sh

source.__INIT__

# /* BUILTIN_SH */
