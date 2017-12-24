#!/bin/bash

#----------------------------------------------#
# Source:           builtin.sh
# Data:             9 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:			shellscriptx@gmail.com
#----------------------------------------------#

[[ $__BUILTIN_SH ]] && return 0

readonly __BUILTIN_SH=1

source types.sh
source error.sh
source getopt.sh

# runtime
readonly __RUNTIME=$BASHSRC_PATH/.runtime

# erros
readonly __BUILTIN_ERR_FUNC_EXISTS='a função já existe ou é um comando interno'
readonly __BUILTIN_ERR_TYPE_REG='nomenclatura da variável é um tipo reservado'
readonly __BUILTIN_ERR_ALREADY_INIT='a variável já foi inicializada'
readonly __BUILTIN_ERR_TYPE_CONFLICT='foi detectado conflito de tipos: o tipo especificado já foi inicializado'
readonly __BUILTIN_ERR_METHOD_NOT_FOUND='o método de implementação não existe'

readonly NULL=0

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
	local __type __tmp

	read _ __type _ < <(declare -p $3 2>/dev/null)

	case $__type in
		*a*) __tmp=$(printf '%s|' "${__obj_ref[@]}"); [[ $1 =~ ^(${__tmp%|})$ ]];;
		*A*) __tmp=$(printf '%s|' "${!__obj_ref[@]}"); [[ $1 =~ ^(${__tmp%|})$ ]];;
		*) [[ $__obj_ref =~ $1 ]];;
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

	local -i tmp
	local nums
	tmp=($*); nums=${tmp[@]}
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
	
	getopt.parse "name:var:+:$1" "funcname:func:+:$2"
	
	declare -n __obj_ref=$1
	local __item __key __ch __type
	
	read _ __type _ < <(declare -p $1 2>/dev/null)

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
	getopt.parse "name:var:+:$1" "funcname:func:+:$2"
	
	declare -n __obj_ref=$1
	local __item __key __ch __type
	
	read _ __type _ < <(declare -p $1 2>/dev/null)

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
	getopt.parse "min:int:+:$1" "max:int:+:$2" "step:int:+:$3" "funcname:func:+:$4"

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
	getopt.parse "name:var:+:$1"
	[[ -v $1 ]]
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
	getopt.parse "funcname:func:+:$1" "new:funcname:+:$2"

	if which $2 &>/dev/null || declare -fp $2 &>/dev/null; then
		error.__exit "newtype" "funcname" "$2" "$__BUILTIN_ERR_FUNC_EXISTS"
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
	local __item __obj
	local -i __arr

	for __obj in $@; do
		getopt.parse "name:var:+:$__obj"
		
		declare -n __obj_ref=$__obj
		__arr+=(${__obj_ref[@]})

		declare +n __obj_ref
		unset __obj_ref
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
	local __item __obj
	local -i __arr

	for __obj in $@; do
		getopt.parse "name:var:+:$__obj"
		
		declare -n __obj_ref=$__obj
		__arr+=(${__obj_ref[@]})

		declare +n __obj_ref
		unset __obj_ref
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
	getopt.parse "list:var:+:$1"
	
	declare -n __obj_dest=$1
	local __item __type

	for __item in ${@:2}; do
		getopt.parse "source:var:+:$__item"
		declare -n __obj_ref=$__item

		read _ __type _ < <(declare -p $__item 2>/dev/null)

		case $__type in
			*a*|*A*) __obj_dest+=("${__obj_ref[@]}");;
			*) __obj_dest+=("$__obj_ref");;
		esac

		declare +n __obj_ref
		unset __obj_ref __type
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
	local __item __type

	for __item in $@; do
		getopt.parse "source:var:+:$__item"
		declare -n __obj_ref=$__item

		read _ __type _ < <(declare -p $__item 2>/dev/null)

		case $__type in
			*a*|*A*) printf '%s\n' "${__obj_ref[@]}";;
			*) printf '%s\n' $__obj_ref;;
		esac

		declare +n __obj_ref
		unset __obj_ref __type
	done | sort -u

	return 0	
}

# func reversed <[str]iterable> => [str]
#
# Reverte os elementos contidos em 'iterable'.
#
function reversed()
{
	getopt.parse "iterable:str:-:$1"

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
	getopt.parse "start:int:+:$2" "count:int:+:$3"

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
	getopt.parse "funcname:func:+:$2"
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
	getopt.parse "pos:int:+:$2"

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
	getopt.parse "x:int:+:$1" "y:int:+:$2"
	echo "$(($1/$2))|$(($1%$2))"
	return 0
}

# func count <[str]iterable> => [uint]
#
# Retorna o total de elementos contidos em uma lista iterável.
#
function count()
{
	getopt.parse "iterable:str:-:$1"

	local arr
	mapfile -t arr <<< "$1"
	echo ${#arr[@]}
	return 0
}

# func all <[str]iterable> <[str]condition> ... => [str]
#
# Retorna os elementos de 'iterable' que satisfazem a todos os critérios
# condicionais estabelecidos em 'condition'.
#
function all()
{
	getopt.parse "iterable:str:-:$1" "cond:str:+:$2"
	builtin.__iter_cond_any_all "$1" '&' "${@:2}"
	return 0
}

# func any <[str]iterable> <[str]condition> ... => [str]
#
# Retorna os elementos de 'iterable' que satisfazem a um ou mais critérios
# condicionais estabelecidos em 'condition'.
#
function any()
{
	getopt.parse "iterable:str:-:$1" "cond:str:+:$2"
	builtin.__iter_cond_any_all "$1" '|' "${@:2}"
	return 0
}

function builtin.__iter_cond_any_all()
{
	local cond iv bit bits iter
	local re="^\s*\[\s+((!)\s+)?(!=|=[=~]|-(eq|ge|gt|le|lt|ne|ef|nt|ot|n|z|b|c|d|e|f|g|G|h|k|L|O|p|r|s|S|t|u|w|x))(\s+[\"']?([^\"']+)[\"']?)?\s+\]\s*$"

	while read iter; do
		for cond in "${@:3}"; do
			if [[ $cond =~ $re ]]; then
				iv=${BASH_REMATCH[2]}
				case ${BASH_REMATCH[3]} in
					=~) [[ "$iter" =~ ${BASH_REMATCH[6]} ]];;
					==) [[ "$iter" == "${BASH_REMATCH[6]}" ]];;
					!=) [[ "$iter" != "${BASH_REMATCH[6]}" ]];;
					-eq) [[ "$iter" -eq "${BASH_REMATCH[6]}" ]];;
					-ge) [[ "$iter" -ge "${BASH_REMATCH[6]}" ]];;
					-gt) [[ "$iter" -gt "${BASH_REMATCH[6]}" ]];;
					-le) [[ "$iter" -le "${BASH_REMATCH[6]}" ]];;
					-lt) [[ "$iter" -lt "${BASH_REMATCH[6]}" ]];;
					-ne) [[ "$iter" -ne "${BASH_REMATCH[6]}" ]];;
					-ef) [[ "$iter" -ef "${BASH_REMATCH[6]}" ]];;
					-nt) [[ "$iter" -nt "${BASH_REMATCH[6]}" ]];;
					-ot) [[ "$iter" -ot "${BASH_REMATCH[6]}" ]];;
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
				esac &>/dev/null
				bit=$(($? ^ 1))
				[[ $iv ]] && bit=$(($bit ^ 1))
				bits+=" $bit $2"
			else
				error.__exit 'cond' 'str' "$cond" 'instrução condicional inválida'
				return 1
			fi
		done
		[[ $((${bits%$2})) -eq 1 ]] && echo "$iter"
		unset bits
	done <<< "$1"

	return 0	
}

# func del <[var]varname> ...
#
# Apaga da memória as variáveis inicializadas.
#
function del()
{
	local obj func init
	
	for obj in $@; do
		getopt.parse "varname:var:+:$obj"
		for func in ${__REG_LIST_VAR[${FUNCNAME[1]}.${obj}]}; do
			unset -f $func
			init=1
		done
		[[ $init ]] && unset __REG_LIST_VAR[${FUNCNAME[1]}.${obj}] $obj init
	done

	return 0
}

# func var <[var]varname> ... <[type]typename>
#
# Inicializa uma ou mais variáveis do tipo especificado em 'typename' e
# implementa seus métodos disponíveis.
# 
function var()
{
	getopt.parse "varname:var:+:$1" "type:type:+:${@: -1}"

	local type regtypes method proto ptr_func struct_func var attr err builtin_method
	type=${@: -1}

	regtypes="${!__BUILTIN_TYPE_IMPLEMENTS[@]}${__INIT_TYPE_IMPLEMENTS[@]:+ ${!__INIT_TYPE_IMPLEMENTS[@]}}"
			
	for var in ${@:1:$((${#@}-1))}; do
		getopt.parse "varname:var:+:$var"

		if [[ $var =~ ^(${regtypes// /|})$ ]]; then
			error.__exit 'varname' 'var' "$var" "$__BUILTIN_ERR_TYPE_REG"
		elif [[ ${__REG_LIST_VAR[${FUNCNAME[1]}.$var]} ]]; then
			error.__exit 'varname' 'var' "$var" "$__BUILTIN_ERR_ALREADY_INIT"
		else
	
			[[ "$type" == "map" ]] && declare -Ag $var
			[[ "$type" != "builtin" ]] && builtin_method=${__BUILTIN_TYPE_IMPLEMENTS[builtin]}
				
			eval "$var.__type__(){ echo $type; return 0; }"
			__REG_LIST_VAR[${FUNCNAME[1]}.$var]+="$var.__type__ "
			
			for method in 	${__BUILTIN_TYPE_IMPLEMENTS[$type]} \
							${__INIT_TYPE_IMPLEMENTS[$type]} \
							$builtin_method; do
			
				ptr_func="^\s*${method//./\\.}\s*\(\)\s*\{\s*getopt\.parse\s+[\"'][a-zA-Z_]+:(var|map|array|func):[+-]:[^\"']+[\"']"

				if struct_func=$(declare -fp $method 2>/dev/null); then
					if [[ $struct_func =~ $ptr_func ]]; then
						proto="%s(){ %s %s \"\$@\"; return \$?; }"
					else
						proto="%s(){ %s \"\$%s\" \"\$@\"; return \$?; }"
					fi
					eval "$(printf "$proto\n" $var.${method##*.} $method $var)"
					__REG_LIST_VAR[${FUNCNAME[1]}.$var]+="$var.${method##*.} "
				else
					error.__exit "$var" "$type" "$method" "$__BUILTIN_ERR_METHOD_NOT_FOUND" 1
					
				fi
			done
		fi
	done

	return $?
}

function builtin.__INIT__()
{
	getopt.parse "-:null:-:$*"

	local attr type reg_types method

	if read _ attr _ < <(declare -p SRC_TYPE_IMPLEMENTS 2>/dev/null); then

		if [[ "$attr" =~ r ]]; then
			error.__exit '' "$__IMPORT_SOURCE" '' "'SRC_TYPE_IMPLEMENTS' o array possui atributo somente leitura" 2
		elif [[ ! "$attr" =~ A ]]; then
			error.__exit '' "$__IMPORT_SOURCE" '' "'SRC_TYPE_IMPLEMENTS' não é um array associativo" 2
		elif [[ ${SRC_TYPE_IMPLEMENTS[@]} ]]; then
				
			reg_types="${!__BUILTIN_TYPE_IMPLEMENTS[@]}${__INIT_TYPE_IMPLEMENTS[@]:+ ${!__INIT_TYPE_IMPLEMENTS[@]}}"

			for type in ${!SRC_TYPE_IMPLEMENTS[@]}; do
				if [[ $type =~ ^(${reg_types// /|})$ ]]; then
					error.__exit '' "${BASH_SOURCE[-2]}" "$type" "$__BUILTIN_ERR_TYPE_CONFLICT" 2
				else
					for method in ${SRC_TYPE_IMPLEMENTS[$type]}; do
						if ! readonly -f $method 2>/dev/null; then
							error.__exit '' "$type" "$method" "$__BUILTIN_ERR_METHOD_NOT_FOUND" 1
							break 2
						fi
					done

					__INIT_TYPE_IMPLEMENTS[$type]=${SRC_TYPE_IMPLEMENTS[$type]}
					unset SRC_TYPE_IMPLEMENTS[$type]
				fi
			done
		fi
	fi

	return $?
}

function builtin.__extfncall(){ [[ "${FUNCNAME[-2]}" != "${FUNCNAME[1]}" ]]; return $?; }

function builtin.__len__()
{
	getopt.parse "var:var:+:$1"
	builtin.__extfncall && len "$1"
	return 0
}

function builtin.__quote__()
{
	getopt.parse "var:var:+:$1"
	if builtin.__extfncall; then
		declare -n __byref=$1
		printf "%q\n" "${__byref[@]}"
	fi
	return 0
}

function builtin.__typeval__()
{
	if builtin.__extfncall; then
		local t
		if [[ ! $1 ]]; then	t='null'
		elif [[ $1 == ?(-|+)+([0-9]) ]]; then t='int'
		else t='string'; fi
	fi

	echo "$t"

	return 0
}

function builtin.__isnum__()
{
	builtin.__extfncall && [[ $1 == ?(-|+)+([0-9]) ]]
	return $?
}

function builtin.__isnull__()
{
	builtin.__extfncall && [[ ! $1 ]]
	return $?
}

function builtin.__in__()
{
	getopt.parse "var:var:+:$1"
	if builtin.__extfncall; then
		declare -n __byref=$1
		[[ $__byref == ?(-|+)+([0-9]) ]] && ((__byref++))
	fi
	return $?
}

function builtin.__dec__()
{
	getopt.parse "var:var:+:$1"
	if builtin.__extfncall; then
		declare -n __byref=$1
		[[ $__byref == ?(-|+)+([0-9]) ]] && ((__byref--))
	fi
	return $?
}

function builtin.__eq__()
{
	if builtin.__extfncall; then
		[[ $1 == ?(-|+)+([0-9]) ]] && [[ $1 -eq $2 ]] || [[ "$1" == "$2" ]]
	fi
	return $?
}

function builtin.__ne__()
{
	if builtin.__extfncall; then
		[[ $1 == ?(-|+)+([0-9]) ]] && [[ $1 -ne $2 ]] || [[ "$1" != "$2" ]]
	fi
	return $?
}

function builtin.__gt__()
{
	if builtin.__extfncall; then
		[[ $1 == ?(-|+)+([0-9]) ]] && [[ $1 -gt $2 ]] || [[ "$1" > "$2" ]]
	fi
	return $?
}

function builtin.__ge__()
{
	if builtin.__extfncall; then
		[[ $1 == ?(-|+)+([0-9]) ]] && [[ $1 -ge $2 ]]
	fi
	return $?
}

function builtin.__lt__()
{
	if builtin.__extfncall; then
		[[ $1 == ?(-|+)+([0-9]) ]] && [[ $1 -lt $2 ]] || [[ "$1" < "$2" ]]
	fi
	return $?
}

function builtin.__le__()
{
	if builtin.__extfncall; then
		[[ $1 == ?(-|+)+([0-9]) ]] && [[ $1 -le $2 ]]
	fi
	return $?
}

function builtin.__float__()
{
	if builtin.__extfncall; then
		[[ $1 == ?(-|+)+([0-9]) ]] && printf "%0.2f\n" "$1"
	fi
	return $?
}

function builtin.__upper__()
{
	getopt.parse "var:var:+:$1"
	builtin.__extfncall && declare -n __byref=$1 && __byref=${__byref^^}
	return 0
}

function builtin.__lower__()
{
	getopt.parse "var:var:+:$1"
	builtin.__extfncall && declare -n __byref=$1 && __byref=${__byref,,}
	return 0
}

function builtin.__swap__()
{
	getopt.parse "var:var:+:$1"
	builtin.__extfncall && declare -n __byref=$1 && __byref=${__byref~~}
	return 0
}

function builtin.__rev__()
{
	getopt.parse "var:var:+:$1"
	if builtin.__extfncall; then
		declare -n __byref=$1
		local __i __tmp
		for ((__i=${#__byref}-1; __i >= 0; __i--)); do
			__tmp+=${__byref:$__i:1}
		done
		__byref=$__tmp
	fi
	return 0
}

function builtin.__repl__()
{
	getopt.parse "var:var:+:$1" "old:str:-:$2" "new:str:-:$3"
	builtin.__extfncall && declare -n __byref=$1 && __byref=${__byref//$2/$3}
	return 0
}

function builtin.__rm__()
{
	getopt.parse "var:var:+:$1"
	builtin.__extfncall && declare -n __byref=$1 && __byref=${__byref//$2/}
	return 0
}

function builtin.__fnmap__()
{
	getopt.parse "var:var:+:$1" "funcname:func:+:$2"
	
	if builtin.__extfncall; then
		local __tmp __i
		declare -n __byref=$1
		for ((__i=0; __i < ${#__byref}; __i++)); do
			__tmp+=$($2 "${__byref:$__i:1}" "${@:3}")
		done
		__byref=$__tmp
	fi

	return 0
}

function builtin.__fn__()
{
	getopt.parse "var:var:+:$1" "funcname:func:+:$2"
	builtin.__extfncall && declare -n __byref=$1 && __byref=$($2 "$__byref" "${@:3}")
	return 0
}

function builtin.__iter__()
{
	getopt.parse "var:var:+:$1"
	if builtin.__extfncall; then
		local __attr __ch __i
		declare -n __byref=$1
		if read _ __attr _ < <(declare -p $1 2>/dev/null); then
			case $__attr in
				*a*|*A*)	printf '%s\n' "${__byref[@]}";;
				*)		for ((__i=0; __i<${#__byref}; __i++)); do 
							__ch[$__i]=${__byref:$__i:1}; done
							printf "%s\n" "${__ch[@]}";;
			esac
		fi	
	fi

	return $?
}


function builtin.__init()
{
	error.resume off

    local depends=(touch mkdir stat cp)
    local dep deps

    for dep in ${depends[@]}; do
        if ! command -v $dep &>/dev/null; then
            deps+=($dep)
        fi
    done

    [[ $deps ]] && error.__depends $FUNCNAME ${BASH_SOURCE##*/} "${deps[*]}"
	
	if ! mkdir -p "$__RUNTIME" &>/dev/null; then
		error.__exit '' '' "$__RUNTIME" 'não foi possível gerar os arquivos temporários'
	fi

	# conf
	shopt -s extglob
	shopt -u nocasematch

	# definições
	declare -Ag __INIT_TYPE_IMPLEMENTS \
				__REG_LIST_VAR \
				SRC_TYPE_IMPLEMENTS

	trap "rm -rf $__RUNTIME/$$ &>/dev/null" INT QUIT ABRT KILL TERM 

    return 0
}

builtin.__init

readonly -f has \
			swap \
			sum \
			fnmap \
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
			isobj \
			sorted \
			fndef \
			enum \
			min \
			max \
			list \
			unique \
			reversed \
			iter \
			fniter \
			niter \
			mod \
			count \
			del \
			var \
			all \
			any \
			builtin.__INIT__ \
			builtin.__len__ \
			builtin.__quote__ \
			builtin.__typeval__ \
			builtin.__isnum__ \
			builtin.__isnull__ \
			builtin.__in__ \
			builtin.__dec__ \
			builtin.__eq__ \
			builtin.__ne__ \
			builtin.__gt__ \
			builtin.__lt__ \
			builtin.__ge__ \
			builtin.__le__ \
			builtin.__float__ \
			builtin.__fn__ \
			builtin.__fnmap__ \
			builtin.__upper__ \
			builtin.__lower__ \
			builtin.__rev__ \
			builtin.__repl__ \
			builtin.__rm__ \
			builtin.__swap__ \
			builtin.__iter__ \
			builtin.__extfncall \
			builtin.__init \
			builtin.__iter_cond_any_all 

# /* BUILTIN_SRC */
