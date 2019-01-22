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

[ -v __BUILTIN_SH__ ] && return 0

if ! awk "BEGIN { exit ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]} < 4.3 }"; then
	echo "${0##*/}: erro: bashsrc requer o interpretador de comandos 'bash 4.3' ou superior." 1>&2
	exit 1
fi

# Inicializa.
readonly __BUILTIN_SH__=1

# BASH (config)
shopt -s 	checkwinsize			\
			cmdhist					\
			complete_fullquote		\
			expand_aliases			\
			extglob					\
			extquote				\
			force_fignore			\
			histappend				\
			interactive_comments	\
			progcomp				\
			promptvars				\
			sourcepath


# Mapa de padrões e protótipos.
readonly -A __BUILTIN__=(
[objname]='[a-zA-Z_][a-zA-Z0-9_]*'
[vector]='\[(0|[1-9][0-9]*)?\]'
[varname]="^${__BUILTIN__[objname]}$"
[vartype]="^(${__BUILTIN__[objname]})(${__BUILTIN__[vector]})?$"
[slice]='^(\[((0|-?[1-9][0-9]*):?|:?(0|-?[1-9][0-9]*)|(0|-?[1-9][0-9]*):(0|-?[1-9][0-9]*))\])+$'
)

# __BUILTIN_TYPES__
#
# Tipos básicos que são validados automaticamente pela função 'getopt.parse'.
#
# Tipos: (bool, str, char, int, uint, float, var, array, map e function)
#
readonly -A __BUILTIN_TYPES__=(
[bool]='^(true|false)$'
[str]='^.*$'
[char]='^.$'
[int]='^(0|-?[1-9][0-9]*)$'
[uint]='^(0|[1-9][0-9]*)$'
[float]='^(0|-?[1-9][0-9]*)\.[0-9]+$'
# Tipos com validação condicional.
[var]=
[array]=
[map]=
[function]=
)

# __REF_TYPES__
#
# Determina os tipos básicos implementados por referência.
#
# XXX ATENÇÃO XXX
#
# É altamente recomendado manter a configuração padrão. 
# Qualquer alteração pode comprometer todo ecossistema 
# do 'bashsrc' e a implementação das funções nas
# bibliotecas existentes.
#
readonly -a __REF_TYPES__=(
var
array
map
function
)

# __BUILTIN_METHODS__
#
# Métodos implementados por padrão por todos os tipos.
#
readonly -a __BUILTIN_METHODS__=(
__imp__
__size__
__type__
__del__
__func__
__src__
__comp__
)

# Objetos/Tipos
declare -Ag __OBJ_INIT__    \
            __SOURCE_TYPES__

# Tipos suportados
declare -g __ALL_TYPE_NAMES__=${!__BUILTIN_TYPES__[@]}' '${!__SOURCE_TYPES__[@]}

# .NAME
#
# builtin.sh
#

# .SYNOPSIS
#
# Implementa funções para inicialização e manipulação de objetos e tipos básicos.
#

# .DESCRIPTION
#
# A biblioteca 'builtin' é o coração do ecossistema 'bashsrc', através da qual
# os tipos são inicializados e gerenciados, cuja as funções e tipos não possuem
# composição, ou seja, o protótipo de declaração não é prefixada pela nomenclatura
# da biblioteca a qual pertence.
#
# Por padrão ela é e deve ser importada antes de qualquer outra biblioteca, seja em
# scripts ou outras bibliotecas afim de prover recursos, compatibilidade de objetos,
# tipos, protótipos, validações e etc.
#

# .VERSION
# 
#  1.0.0
#

# .AUTHORS
#
# Juliano Santos [SHAMAN] <juliano.santos.bm@gmail.com>
#

# .FUNCTION var <obj[var]> ... <type[type]> -> [bool]
#
# Inicializa o objeto com o tipo especificado e implementa seus métodos.
#
# obj  - O identificador do objeto. (Suporta array)
# type - Tipo do objeto a ser implementado.
#
# Obs: Pode ser especificado mais de um objeto na mesma instancia.
#
# == EXEMPLO ==
#
# # Inicializa um objeto do tipo 'var_t'
# var my_obj var_t
# my_obj='linux'	# Atribuir valor
# 
# # Chama método
# my_obj.upper
#
# == SAÍDA ==
# LINUX
#
# # Inicializar um array com '3' dimensões.
# var obj var_t[3]
# obj[0]='shell'
# obj[1]='script'
# obj[2]='LINUX'
# 
# # Chamando métodos
# obj[0].upper
# obj[1].upper
# obj[2].lower
#
# == SAÍDA ==
# SHELL
# SCRIPT
# linux
#
function var()
{
	local type var i func funcs method size proto methods reftypes

	[[ ${*: -1} =~ ${__BUILTIN__[vartype]} ]] || error.fatal "'${*: -1}' erro de sintaxe"

	# Extrai tipo e comprimento.
	type=${BASH_REMATCH[1]}
	size=${BASH_REMATCH[3]}

	# Analisa sintaxe.
	[[ -v __SOURCE_TYPES__[$type] ]] || error.fatal "'$type' tipo desconhecido"

	# Tipos definidos
	reftypes=${__REF_TYPES__[@]}' '${!__SOURCE_TYPES__[@]}

	# Lista os identificadores.
	for var in ${*:1:${#*}-1}; do

		# Verifica identificador da variável.
		[[ $var =~ ${__BUILTIN__[varname]} ]] || error.fatal "'$var' não é um identificador válido"
		[[ -v __OBJ_INIT__[$var] ]] && error.fatal "'$var' o objeto já foi inicializado"

		methods=()

		for ((i=0; i < ${size:-1}; i++)); do
			# Extrai as funções vinculadas ao tipo.
			IFS='|' read _ funcs _ <<< ${__SOURCE_TYPES__[$type]}
			for func in $funcs; do
				# Define o nome do método com base no comprimento do tipo.
				# Caso o tipo seja um array anexa o indíce do elemento ao
				# identificador do método.
				#
				# Exemplo:
				#
				# var 	-> 	varname.method
				# array -> 	varname[n].method
				#
				method=${var}${size:+[$i]}.${func#*.}

				# Se há conflitos entre métodos implementados.
				[[ $(type -t $method) == function ]] && error.fatal "conflito de método: '$method' o método já foi implementado"

				# Verifica o protótipo da função para determinar o método de immplementação.
				# Se o primeiro argumento da função for um tipo definido a implementação é realizada por 'referência', 
				# ou seja, a função irá receber o identificador do objeto implementado, caso contrário a função recebe
				# o valor armazenado.
				[[ $(declare -fp $func 2>/dev/null) =~ ${__GETOPT__[parse]}(${reftypes// /|})(\[[^]]*\])?: ]]	&&
				proto='%s(){ %s "%s" "$@"; return $?; }'																	||	# referência
				proto='%s(){ %s "${%s}" "$@"; return $?; }'																		# valor
		
				# Implementa o método
				printf -v proto "$proto" $method $func ${var}${size:+[$i]}
				eval "$proto" 2>/dev/null || error.fatal "'$method' não foi possível implementar o método"
				# Anexa o novo método.
				methods+=($method)
				
				# Define a função como somente-leitura protegendo o método
				# implementado de uma chamada inválida.
				readonly -f $func
			done
		done
		
		# Funções (builtin)
		#
		# As funções builtin são implementas por todos os tipos (type_t) recebendo seu
		# identificador literal (sem vetores).
		for func in ${__BUILTIN_METHODS__[@]}; do
			method=${var}.${func#.*}

			[[ $(declare -fp $func 2>/dev/null) =~ ${__GETOPT__[parse]}(${reftypes// /|})(\[[^]]*\])?: ]]	&&
			proto='%s(){ %s "%s" "$@"; return $?; }'																	||
			proto='%s(){ %s "${%s}" "$@"; return $?; }'
			
			printf -v proto "$proto" $method $func $var
			eval "$proto" 2>/dev/null || error.fatal "'$method' não foi possível implementar o método"

			methods+=($method)
			readonly -f $func
		done
		# Registra a variável e define os seus atributos:
		# 
		# * tipo
		# * comprimento
		# * métodos implementados
		#
		__OBJ_INIT__[$var]="$type|${size:-0}|${methods[*]}"
	done

	return $?
}

# .FUNCTION typedef <typename[str]> <func[str]> ... -> [bool]
#
# Define o tipo e os métodos de implementação.
#
# obj      - Identificador do tipo.
# func - Identificador da função a ser implementada.
#
# Obs: Pode ser especificada mais de uma função.
#
# == EXEMPLO ==
#
# #!/bin/bash
#
# source builtin.sh
# 
# # Criando as funções
# somar(){ echo $(($1+$2)); }
# subtrair(){ echo $(($1-$2)); }
# dividir(){ echo $(($1/$2)); }
# multiplicar() echo $(($1*$2)); }
#
# # Definindo o tipo 'calc_t' que implementa as funções aritméticas acima.
# typedef calc_t somar subtrair dividir multiplicar
#
# # Cria um objeto com o novo tipo.
# var num calc_t
#
# # Atribui o valor para operação.
# num=10
# 
# # Chama cada método passando o valor armazenado em 'num' e executa a 
# # respectiva operação arimética.
# num.somar 30
# num.subtrair 5
# num.dividir 2
# num.multiplicar 10
#
# == SAÍDA ==
#
# 40
# 5
# 5
# 100
#
function typedef()
{
	getopt.parse -1 "typename:str:$1" "func:function:$2" ... "${@:3}"

	local type srctypes src

	type=$1

	# Carrega os tipos já inicializados
	srctypes=${!__SOURCE_TYPES__[@]}

	# Verifica conflitos.
	if [[ $type == @(${srctypes// /|}) ]]; then
		IFS='|' read src _ <<< ${__SOURCE_TYPES__[$type]}
		error.fatalf "conflito de tipos\n\ntipo: $type\n\nsource: ${BASH_SOURCE[-2]}\nsource: $src\n"
	fi

	# Registra/atualiza tipos suportados.
	__SOURCE_TYPES__[$type]=${BASH_SOURCE[-1]}'|'${@:2}
	__ALL_TYPE_NAMES__=${!__BUILTIN_TYPES__[@]}' '${!__SOURCE_TYPES__[@]}
	
	return $?
}

# .FUNCTION del <obj[var]> ... -> [bool]
#
# Apaga da memória o objeto implementado.
# --
# Obs: Pode ser especificado mais de um objeto.
#
function del()
{
    getopt.parse -1 "obj:var:$1" ... "${@:2}"

    local __funcs__ __var__

    for __var__ in $@; do
		# Remove objeto da memória.
		IFS='|' read _ _ __funcs__ _ <<< ${__OBJ_INIT__[$__var__]}
        unset -f $__funcs__
        unset   $__var__					\
                __OBJ_INIT__[$__var__]		\
                __SOURCE_TYPES__[$__var__]

    done 2>/dev/null || error.fatal "'$__var__' não foi possível deletar o objeto"

    return $?
}

# .FUNCTION len <obj[var]> -> [uint]|[bool]
#
# Retorna um inteiro sem sinal que representa o comprimento de uma
# cadeia de caracteres armazenados em 'obj'. Caso seja um array é
# retornado o total de elementos no container.
#
function len()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"
	
	local -i __len__
	local -n __ref__=$1

	[[ $1 =~ ${__BUILTIN__[vector]} ]] 	&& 
	__len__=${#__ref__}						||
	__len__=${#__ref__[@]}

	echo $__len__
	
	return $?
}

# .FUNCTION typeval <expr[str]> -> [str]|[bool]
#
# Retorna o tipo básico contido na expressão.
#
function typeval()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	local type
	
	for type in bool uint int float char str; do
		[[ $1 =~ ${__BUILTIN_TYPES__[$type]} ]] && break
	done

	echo "$type"

	return $?
}

# .FUNCTION typeof <obj[var]> -> [str]|[bool]
#
# Retorna o tipo do objeto.
#
function typeof()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	local type
	IFS='|' read type _ <<< ${__OBJ_INIT__[${1%[*}]}
	echo "$type"
	return $?
}

# .FUNCTION sizeof <obj[var]> -> [uint]|[bool]
#
# Retorna um inteiro sem sinal que indica o tamanho do objeto implementado.
# Se for '> 0' o objeto é um array.
# 
function sizeof()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"
	
	local -i size
	IFS='|' read _ size _ <<< ${__OBJ_INIT__[${1%[*}]}
	echo "$size"
	return $?
}

# .FUNCTION assert <cond[str]> <error[str]> -> [str]|[bool]
#
# Testa a condição e dispara uma mensagem de erro caso seja falsa e interrompe
# a execução do programa com status '1'.
#
function assert()
{
	getopt.parse 2 "cond:str:$1" "error:str:$2" "${@:3}"

	[ $1 ] 2>/dev/null || error.fatal "$2"
	return $?
}

# .FUNCTION iif <cond[str]> <true[str]> <false[str]> -> [str]|[bool]
#
# Testa a condição e retorna a expressão 'true' se for verdadeiro, caso
# contrário retorna a expressão 'false'.
#
function iif()
{
	getopt.parse 3 "cond:str:$1" "true:str:$2" "false:str:$3" "${@:4}"

	[ $1 ] 2>/dev/null && echo "$2" || echo "$3"
	return $?
}

# .FUNCTION input <type[str]> <prompt[str]> -> [str]|[bool]
#
# Lê os dados da entrada padrão exibindo o prompt de inserção.
# Retorna nulo se o valor não satisfazer os critérios do tipo determinado.
# > São suportados somente os tipos básicos: char, str, int, uint, float ou bool.
#
# == EXEMPLO ==
#
# #!/bin/bash
#
# source builtin.sh
#
# # Lê os dados
# nome=$(input str 'nome:')			<- Francisco
# idade=$(input uint 'idade:')		<- 30f			/* INVÁLIDO */
#
# # Imprimindo valores
# echo "Nome: " $nome
# echo "Idade: " $idade
#
# == SAÍDA ==
#
# Francisco
#
#
function input()
{
	getopt.parse 2 "type:str:+:$1" "prompt:str:$2" "${@:3}"
	
	[[ $1 != @(bool|str|char|int|uint|float) ]] && error.fatal "'$1' tipo básico desconhecido"

	local val
	read -rp "$2" val
	[[ $val =~ ${__BUILTIN_TYPES__[$1]} ]] && echo "$val"
	return $?
}

# .FUNCTION has <expr[str]> <substr[str]> -> [bool]
#
# Retorna true se 'expr' contém 'substr', caso contrário 'false'.
#
function has()
{
	getopt.parse 2 "expr:str:$1" "substr:str:$2" "${@:3}"
	
	[[ $1 == *$2* ]]
	return $?	
}

# .FUNCTION all <iterable[array]> <cond[str]> -> [bool]
# 
# Retorna 'true' se todos os elementos em iterable satisfazer os critérios
# estabelecidos, caso contrário 'false'. 
#
# > Utilize a variável '$?' para receber o elemento iterável.
# > Suporta todos os operadores lógicos. Para mais informações: 'man test'
# > Obs: Use aspas simples (') na passagem dos argumentos para suprimir
#        a expansão da variável '$?'.
#
# == EXEMPLO ==
#
# source builtin.sh
#
# # Arquivos
# arqs=('/etc/group' '/etc/passwd' '/etc/shadow')
#
# # Verifica se todos os arquivos contidos na lista existem. 
# if all arqs '-e $?'; then
# 	echo "Todos existem"
# else
# 	echo "Nem todos"
# fi
#
# == SAÍDA ==
#
# Todos existem
#
function all()
{
	getopt.parse 2 "iterable:array:$1" "cond:str:$2" "${@:3}"

	local -n __ref__=$1
	local __iter__ __ret__

	for __iter__ in "${__ref__[@]}"; do
		[ ${2//$\?/$__iter__} ]
		__ret__+="$?|"
	done 2>/dev/null

	return $((${__ret__%|}))
}

# .FUNCTION any <iterable[array]> <cond[str]> -> [bool]
#
# Retorna 'true' se pelo menos um elemento em iterable satisfazer o critério
# condicional estabelecido, caso contrário 'false'.
#
# > Utilize a variável '$?' para receber o elemento iterável.
# > Suporta todos os operadores lógicos. Para mais informações: 'man test'
# > Obs: Use aspas simples (') na passagem dos argumentos para suprimir
#        a expansão prematura da variável '$?'.
#
function any()
{
	getopt.parse 2 "iterable:array:$1" "cond:str:$2" "${@:3}"

	local -n __ref__=$1
	local __iter__

	for __iter__ in "${__ref__[@]}"; do
		[ ${2//$\?/$__iter__} ] && break
	done 2>/dev/null

	return $?
}

# .FUNCTION bin <num[int]> -> [str]|[bool]
#
# Retorna a representação binária de um inteiro.
#
# == EXEMPLO ==
#
# $ bin 27325
# 110101010111101
#
function bin()
{
	getopt.parse 1 "num:int:$1" "${@:2}"

	local i bit
	for ((i=${1#-}; i > 0; i >>= 1)); do bit=$((i&1))$bit; done
	echo ${1//[^-]/}${bit:-0}
	return $?
}

# .FUNCTION swap <obj1[var]> <obj2[var]> -> [bool]
#
# Troca os valores entre 'obj1' e 'obj2'.
#
function swap()
{
	getopt.parse 2 "obj1:var:$1" "obj2:var:$2" "${@:3}"

	local -n __ref1__=$1 __ref2__=$2
	local __tmp__=$__ref1__
	__ref1__=$__ref2__
	__ref2__=$__tmp__
	return $?
}

# .FUNCTION sum <interable[array]> -> [int]|[bool]
#
# Soma todos os valores em 'iterable'. Elementos não numéricos são ignorados.
#
# == EXEMPLO ==
#
# $ nums=({10..100})
# $ sum nums
# 5005
#
function sum()
{
	getopt.parse 1 "iterable:array:$1" "${@:2}"

	local -n __ref__=$1
	local __val__
	printf -v __val__ '+%d' "${__ref__[@]}" 2>/dev/null
	echo $((__val__))
	return $?
}

# .FUNCTION fnfilter <iterable[array]> <func[function]> [str]|[bool]
#
# Executa a função filtro passando o elemento iterável e imprime somente 
# se o retorno da função for 'true'.
#
# == EXEMPLO ==
#
# #!/bin/bash
#
# source builtin.sh
#
# # Função (filtro)
# func_iniciais()
# {
#	# '$1' Contém o elemento atual na chamada da função.
#
# 	[[ $1 == J* ]]	# Verifica se o nome inicia com a letra 'J'.
#	return $?       # Retorna o status da expressão condicional.
# }
#
# # Lista de nomes
# nomes=('Juliano' 'Francisco' 'Adriana' 'Janice' 'Jader' 'Maria')
#
# # Filtra o array
# fnfilter nomes func_iniciais
# 
# == SAÍDA ==
#
# Juliano
# Janice
# Jader
# 
function fnfilter()
{
	getopt.parse 2 "iterable:array:$1" "func:function:$2" "${@:3}"

	local -n __ref__=$1
	local __iter__

	for __iter__ in "${__ref__[@]}"; do
		$2 "$__iter__" && echo "$__iter__"
	done

	return $?
}

# .FUNCTION chr <code[uint]> -> [char]|[bool]
#
# Retorna uma string unicode de um caractere ordinal.
#
function chr()
{
	getopt.parse 1 "code:uint:$1" "${@:2}"
	
	printf \\$(printf '%03o' $1)'\n'
	return $?
}

# .FUNCTION ord <ch[char]> -> [uint]|[bool]
#
# Retorna código Unicode de um caractere.
#
function ord()
{
	getopt.parse 1 "ch:char:$1" "${@:2}"

	printf '%d\n' "'$1"
	return $?
}

# .FUNCTION hex <num[int]> -> [str]|[bool]
#
# Retorna a representação hexadecimal de um inteiro.
#
function hex()
{
	getopt.parse 1 "num:int:$1" "${@:2}"

	printf '0x%x\n' $1
	return $?
}

# .FUNCTION oct <num[int]> -> [int]|[bool]
#
# Retorna a representação octal de um inteiro.
#
function oct()
{
	getopt.parse 1 "num:int:$1" "${@:2}"

	printf '0%o\n' $1
	return $?
}

# .FUNCTION htoi <hex[str]> -> [int]|[bool]
#
# Converte base hexadecimal para inteiro.
#
function htoi()
{
	getopt.parse 1 "hex:str:$1" "${@:2}"

	printf '%d\n' $1
	return $?
}

# .FUNCTION btoi <bin[str]> -> [int]|[bool]
#
# Converte base binária para inteiro.
#
function btoi()
{
	getopt.parse 1 "bin:str:$1" "${@:2}"

	echo $((2#$1))
	return $?
}

# .FUNCTION otoi <oct[str]> -> [int]|[bool]
# 
# Converte base octal para inteiro.
#
function otoi()
{
	getopt.parse 1 "oct:str:$1" "${@:2}"

	echo $((8#$1))
	return $?
}

# .FUNCTION range <start[int]> <stop[int]> <step[int]> -> [int]|[bool]
#
# Retorna uma sequência de inteiros entre 'start' e 'stop' com 'step' saltos.
#
function range()
{
	getopt.parse 3 "start:int:$1" "stop:int:$2" "max:int:$3" "${@:4}"

	local i op
	[[ $3 -lt 0 ]] && op='>=' || op='<='
	for ((i=$1; i $op $2; i=i+$3)); do echo $i; done
	return $?
}

# .FUNCTION isobj <obj[var]> -> [bool]
#
# Retorna 'true' se a variável for um objeto implementado, caso contrário 'false'.
#
# == EXEMPLO ==
#
# source builtin.sh
#
# var obj var_t    # Objeto
# obj=20
#
# num=10           # Variável
# 
# isobj obj && echo true || echo false
# isobj num && echo true || echo false
#
# == SAÍDA ==
#
# true
# false
#
function isobj()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	[[ -v __OBJ_INIT__[${1:--}] ]]
	return $?
}

# .FUNCTION fnmap <iterable[array]> <func[function]> <args[str]> ... -> [bool]
#
# Executa a função passando o elemento iterável com 'N' args (opcional).
#
function fnmap()
{
	getopt.parse -1 "iterable:array:$1" "func:function:$2" "args:str:$3" ... "${@:4}"

	local -n __ref__=$1
	local __iter__

	for __iter__ in "${__ref__[@]}"; do
		$2 "$__iter__" "${@:3}"
	done
	return $?
}

# .FUNCTION iter <obj[var]> <expr[str]> -> [bool]
#
# Converte a expressão delimitada por '\n' nova-linha em uma
# lista iterável apontada por 'obj'.
#
# == EXEMPLO ==
#
# source builtin.sh
#
# # Cria lista iterável.
# iter lista "$(< /etc/passwd)"
#
# # Exibindo a linha 10.
# echo ${lista[9]}
#
#  == SAÍDA ==
#
# lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
#
function iter()
{
	getopt.parse 2 "obj:var:$1" "expr:str:$2" "${@:3}"

	mapfile -t $1 <<< "$2"
	return $?
}

# .FUNCTION enum <iterable[array]> <start[int]> -> [str]|[bool]
#
# Enumera os elementos de uma lista iterável a partir de 'start'.
#
function enum()
{
	getopt.parse 2 "iterable:array:$1" "start:int:$2" "${@:3}"

	local -n __ref__=$1
	local __iter__ __i__=$2

	for __iter__ in "${__ref__[@]}"; do
		echo "$((__i__++)) $__iter__"
	done

	return $?
}

# .FUNCTION listobj -> [str]|[bool]
#
# Retorna uma lista iterável com os objetos implementados no formato 'nome:tipo'.
#
function listobj()
{
	getopt.parse 0 "$@"
	
	local obj type objs
	for obj in ${!__OBJ_INIT__[@]}; do
		IFS='|' read type _ <<< ${__OBJ_INIT__[$obj]}
		objs+=($obj:$type)
	done
	printf '%s\n' "${objs[@]}"
	return $?
}

# .FUNCTION min <iterable[array]> -> [str]|[bool]
#
# Retorna o menor item em uma lista iterável.
#
function min()
{
	getopt.parse 1 "iterable:array:$1" "${@:2}"

	local -n __ref__=$1
	local __iter__ __min__

	__min__=${__ref__[0]}

	for __iter__ in "${__ref__[@]}"; do
		[[ $__iter__ < $__min__ ]] && __min__=$__iter__
	done

	echo "$__min__"

	return $?
}

# .FUNCTION max <iterable[array]> -> [str]|[bool]
#
# Retorna o maior item em uma lista iterável.
#
function max()
{
	getopt.parse 1 "iterable:array:$1" "${@:2}"

	local -n __ref__=$1
	local __iter__ __max__

	__max__=${__ref__[0]}

	for __iter__ in "${__ref__[@]}"; do
		[[ $__iter__ > $__max__ ]] && __max__=$__iter__
	done

	echo "$__max__"

	return $?
}

# .FUNCTION count <iterable[array]> -> [int]|[bool]
#
# Retorna o total de elementos em uma lista iterável.
#
function count()
{
	getopt.parse 1 "iterable:array:$1" "${@:2}"

	local -n __ref__=$1
	echo ${#__ref__[@]}
	return $?
}

# .FUNCTION reversed <iterable[array]> -> [str]|[bool]
#
# Inverter o iterador sobre os valores da sequência.
#
function reversed()
{
	getopt.parse 1 "iterable:array:$1" "${@:2}"

	local -n __ref__=$1
	printf '%s\n' "${__ref__[@]}" | tac
	return $?
}

# .FUNCTION unique <iterable[array]> -> [str]|[bool]
#
# Emite somente itens únicos em uma lista iterável.
#
function unique()
{
	getopt.parse 1 "iterable:array:$1" "${@:2}"

	local -n __ref__=$1
	printf '%s\n' "${__ref__[@]}" | sort -du
	return $?
}

# .FUNCTION sorted <iterable[array]> -> [str]|[bool]
#
# Retorna uma lista classificada do objeto iterável especificado.
# Cadeias contendo somente números são ordenadas numericamente, caso
# contrário são ordenadas alfabéticamente.
# 
function sorted()
{
	getopt.parse 1 "iterable:array:$1" "${@:2}"

	local -n __ref__=$1
	local __opt__  __re__
	
	__re__='^(\s*[+-]?[0-9]+(.[0-9]+)?\s*)+$'

	[[ ${__ref__[@]} =~ $__re__ ]] && __opt__=n
	printf '%s\n' "${__ref__[@]}" | sort -${__opt__:-d}
	
	return $?
}

# .FUNCTION isnull <obj[var]> -> [bool]
#
# Retorna 'true' se o valor de 'var' for nulo, caso contrário 'false'.
#
function isnull()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	[[ -z ${!1} ]]
	return $?
}

# .FUNCTION quote <obj[var]> -> [str]|[bool]
#
# Imprime em um formato que pode ser reutilizado como shell de entrada, 
# escapando caracteres não imprimíveis com o POSIX proposto na sintaxe $' '.
#
function quote()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	local __tmp__

	printf -v __tmp__ '%q' "${!1}"

	[[ $(typeof $1) == ptr_t ]] && 
	printf -v $1 "$__tmp__"		||
	echo "$__tmp__"

	return $?
}

# .FUNCTION float <obj[var]> -> [float]|[bool]
#
# Converte uma string em um número de ponto flutuante, se possível.
#
function float()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"
	
	local __tmp__

	printf -v __tmp__ '%f' "${!1}" 2>/dev/null
	__tmp__=${__tmp__//,/.}

	[[ $(typeof $1) == ptr_t ]] && 
	printf -v $1 "$__tmp__" 	|| 
	echo "$__tmp__"

	return $?
}

# .FUNCTION upper <obj[var]> -> [str]|[bool]
#
# Retorna o valor de 'var' convertida para maiúscula.
#
function upper()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	[[ $(typeof $1) == ptr_t ]] && 
	printf -v $1 "${!1^^}"		||
	echo "${!1^^}"

	return $?
}

# .FUNCTION lower <obj[var]> -> [str]|[bool]
#
# Retorna o valor de 'var' convertida para minúscula.
#
function lower()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	[[ $(typeof $1) == ptr_t ]] && 
	printf -v $1 "${!1,,}"		||
	echo "${!1,,}"

	return $?
}

# .FUNCTION swapcase <obj[var]> -> [str]|[bool]
#
# Retorna uma cópia de 'var' com caracteres maiúsculos convertidos para 
# letras minúsculas e vice-versa.
#
function swapcase()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	[[ $(typeof $1) == ptr_t ]]	&& 
	printf -v $1 "${!1~~}"		|| 
	echo "${!1~~}"

	return $?
}

# .FUNCTION replace <obj[var]> <old[str]> <new[str]> <recursive[bool]> -> [str]|[bool]
#
# Retorna uma cópia de 'var' substituindo a ocorrência da substring 'old' por 'new'. 
# Se 'recursive' for igual a 'true' a substituição é realizada em todas as ocorrências,
# caso contrário somente na primeira.
#
# == EXEMPLO ==
#
# texto='Programação shell script com bash'
#
# replace texto 's' 'S' false
# replace texto 's' 'S' true
#
# == SAÍDA ==
#
# Programação Shell script com bash
# Programação Shell Script com baSh'
#
function replace()
{
	getopt.parse 4 "obj:var:$1" "old:str:$2" "new:str:$3" "recursive:bool:$4" "${@:5}"

	local __tmp__

	$4 && __tmp__=${!1//$2/$3} || __tmp__=${!1/$2/$3}

	[[ $(typeof $1) == ptr_t ]] && 
	printf -v $1 "$__tmp__" 	|| 
	echo "$__tmp__"
	
	return $?
}

# .FUNCTION reverse <obj[var]> -> [str]|[bool]
#
# Inverte a sequência de uma cadeia de caracteres.
#
function reverse()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	local __tmp__=$(rev <<< "${!1}")

	[[ $(typeof $1) == ptr_t ]]	&& 
	printf -v $1 "$__tmp__" 	|| 
	echo "$__tmp__"

	return $?
}

# .FUNCTION contains <expr[str]> <substr[str]> -> [bool]
#
# Retorna 'true' se a expressão contém a substring.
#
function contains()
{
	getopt.parse 2 "expr:str:$1" "substr:str:$2" "${@:3}"

	[[ $1 == *$2* ]]
	return $?
}

# .FUNCTION isnum  <expr[str]> -> [bool]
#
# Retorna 'true' se a expressão é um valor númerico.
#
function isnum()
{
	getopt.parse 1 "expr:str:$1" "${@:2}"

	[[ $1 =~ ${__BUILTIN_TYPES__[int]} 		]] ||
	[[ $1 =~ ${__BUILTIN_TYPES__[float]}	]]
	return $?
}

# .FUNCTION insert <obj[var]> <expr[str]> -> [str]|[bool]
#
# Retorna uma string inserindo a expressão no inicio da cadeia de caracteres.
#
function insert()
{
	getopt.parse 2 "obj:var:$1" "expr:str:$2" "${@:3}"

	[[ $(typeof $1) == ptr_t ]] && 
	printf -v $1 "${2}${!1}"	||
	echo "${2}${!1}"

	return $?
}

# .FUNCTION append <obj[var]> <expr[str]> -> [str]|[bool]
#
# Retorna uma string anexando a expressão no final da cadeia de caracteres.
#
function append()
{
	getopt.parse 2 "obj:var:$1" "expr:str:$2" "${@:3}"

	[[ $(typeof $1) == ptr_t ]] && 
	printf -v $1 "${!1}${2}"	||
	echo "${!1}${2}"
	
	return $?
}

# .FUNCTION slice <obj[var]> <slice[str]> -> [str]|[bool]
#
# Retorna uma substring contendo uma sequência de caracteres dentro
# do 'slice' especificado e deve respeitar o seguinte formato: 
#
# [start:len] ...
#
# start - Posição inicial na cadeia de caracteres. 
#         > Se for omitido assume a posição '0'.
#
# len   - Total de caracteres a partir de 'start'. 
#         > Se for omitido assume o comprimento total da string.
# ---
# > Pode ser especificado um ou mais slices.
# > Utilize notação negativa para captura reversa.
# > Não pode conter espaço entre valores e slices.
#
# == EXEMPLO ==
#
# source builtin.sh
#
# # Implementa tipo.
# var texto var_t
#
# # Frase
# texto='Seja livre use Linux!!'
#
# # Fatiando.
# texto.slice '[:10]'
# texto.slice '[11:]'
# texto.slice '[:-2]'
# texto.slice '[-7]'
# texto.slice '[15:][:-2][2:4]'
#
# == SAÍDA ==
#
# Seja livre
# use Linux!!
# Seja livre use Linux
# L
# nux
#
function slice()
{
	getopt.parse 2 "obj:var:$1" "slice:str:$2" "${@:3}"

	[[ $2 =~ ${__BUILTIN__[slice]} ]] || error.fatal "'$2' erro de sintaxe na expressão slice"

	local __str__=${!1}
	local __slice__=$2
   	local __ini__ __len__

	while [[ $__slice__ =~ \[([^]]+)\] ]]; do
		IFS=':' read __ini__ __len__ <<< "${BASH_REMATCH[1]}"
		[[ ${__len__#-} -gt ${#__str__} ]] && __str__='' && break
		[[ ${BASH_REMATCH[1]} != *@(:)* ]] && __len__=1
		__ini__=${__ini__:-0}
		__len__=${__len__:-$((${#__str__}-$__ini__))}
		__str__=${__str__:$__ini__:$__len__}
		__slice__=${__slice__/\[${BASH_REMATCH[1]}\]/}
	done

	[[ $(typeof $1) == ptr_t ]] && 
	printf -v $1 "$__str__"		||
	echo "$__str__"

	return $?
}

### BUILTIN (MÉTODOS) ###

# .FUNCTION __imp__ <obj[var]> -> [str]|[bool]
#
# Retorna os métodos implementados por 'obj'.
#
function __imp__()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	local imp
	IFS='|' read _ _ imp _ <<< ${__OBJ_INIT__[${1:--}]}
	printf '%s\n' $imp
	return $?
}

# .FUNCTION __type__ <obj[var]> -> [str]|[bool]
#
# Retorna o tipo do objeto.
#
function __type__()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	typeof $1
	return $?
}

# .FUNCTION __size__ <obj[var]> -> [int]|[bool]
#
# Retorna o tamanho do objeto implementado.
# > Se '> 0' o objeto é um array.
#
# == EXEMPLO ==
#
# source builtin.sh
#
# var var1 var2[3] var_t
#
# var1.__size__
# var2.__size__
#
# == SAÍDA ==
#
# 0
# 3
#
function __size__()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"

	sizeof $1
	return  $?
}

# .FUNCTION __del__ <obj[var]> -> [bool]
#
# Apaga o objeto da memória.
#
function __del__()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"
	del $1
	return $?
}

# .FUNCTION __func__ <obj[var]> -> [str]|[bool]
#
# Retorna as funções referênciadas por 'obj'.
#
function __func__()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"
	
	local info
	IFS='|' read info _ <<< ${__OBJ_INIT__[${1:--}]}
	IFS='|' read _ info _ <<< ${__SOURCE_TYPES__[${info:--}]}
	printf '%s\n' $info "${__BUILTIN_METHODS__[@]}"
	return $?
}

# .FUNCTION __src__ <obj[var]> -> [str]|[bool]
#
# Retorna o arquivo-fonte onde o objeto foi instanciado.
#
function __src__()
{
	getopt.parse 1 "obj:var:$1" "${@:2}"
	
	local info
	IFS='|' read info _ <<< ${__OBJ_INIT__[${1:--}]}
	IFS='|' read info _ <<< ${__SOURCE_TYPES__[${info:--}]}
	echo $info
	return $?
}

# .FUNCTION __comp__ <obj1[var]> <obj2[var]> -> [bool]
#
# Retorna 'true' se os objetos forem iguais, caso contrário 'false'.
#
function __comp__()
{
	getopt.parse 2 "obj1:var:$1" "obj2:var:$2" "${@:3}"

	[[ $(typeof $1) == $(typeof $2) ]]
	return $?
}

# .FUNCTION __null__ -> [bool]
function __null__(){ :; }

# .FUNCTION __eq__ <expr1[str]> <expr2[str]> -> [bool]
#
# Retorna 'true' se 'expr1' for igual a 'expr2', caso contrário 'false'.
# 
function __eq__()
{
	getopt.parse 2 "expr1:str:$1" "expr2:str:$2" "${@:3}"
	[[ $1 == $2 ]]
	return $?
}

# .FUNCTION __ne__ <expr1[str]> <expr2[str]> -> [bool]
#
# Retorna 'true' se 'expr1' for diferente de 'expr2', caso contrário 'false'.
#
function __ne__()
{
	getopt.parse 2 "expr1:str:$1" "expr2:str:$2" "${@:3}"
	[[ $1 != $2 ]]
	return $?
}

# .FUNCTION __gt__ <expr1[str]> <expr2[str]> -> [bool]
#
# Retorna 'true' se  'expr1' for maior que 'expr2', caso contrário 'false'.
# Se ambas expressões forem números a comparação será numérica, senão a
# comparação será lexical.
#
function __gt__()
{
	getopt.parse 2 "expr1:str:$1" "expr2:str:$2" "${@:3}"

	[[ $1 =~ ${__BUILTIN_TYPES__[int]} && $2 =~ ${__BUILTIN_TYPES__[int]} ]] &&
	[[ $1 -gt $2 ]] ||
	[[ $1 > $2 ]]
	return $?
}

# .FUNCTION __ge__ <num1[int]> <num2[int]> -> [bool]
#
# Retorna 'true' se 'num1' for maior ou igual a 'num2', caso contrário 'false'.
#
function __ge__()
{
	getopt.parse 2 "num1:int:$1" "num2:int:$2" "${@:3}"

	[[ $1 -ge $2 ]]
	return $?
}

# .FUNCTION __lt__ <exp1[str]> <exp2[str]> -> [bool]
#
# Retorna 'true' se  'expr1' for menor que 'expr2', caso contrário 'false'.
# Se ambas expressões forem números a comparação será numérica, senão a
# comparação será lexical.
#
function __lt__()
{
	getopt.parse 2 "expr1:str:$1" "expr2:str:$2" "${@:3}"

	[[ $1 =~ ${__BUILTIN_TYPES__[int]} && $2 =~ ${__BUILTIN_TYPES__[int]} ]] &&
	[[ $1 -lt $2 ]] ||
	[[ $1 < $2 ]]
	return $?
}

# .FUNCTION __le__ <num1[int]> <num2[int]> -> [bool]
#
# Retorna 'true' se 'num1' for menor ou igual a 'num2', caso contrário 'false'.
#
function __le__()
{
	getopt.parse 2 "num1:int:$1" "num2:int:$2" "${@:3}"

	[[ $1 -le $2 ]]
	return $?
}

# Imports
source getopt.sh
source error.sh

# .TYPE var_t
#
# O tipo 'var_t' implementa métodos e funções 'builtin' para manipulação
# de valores atribuidos ao objeto.
#
# Implementa objeto 'S' com os métodos:
#
# S.reverse
# S.replace
# S.swapcase
# S.lower
# S.upper
# S.float
# S.quote
# S.contains
# S.isnum
# S.isnull
# S.insert
# S.append
# S.slice
# S.__le__
# S.__lt__
# S.__ge__
# S.__gt__
# S.__ne__
# S.__ne__
# S.__eq__
#
typedef var_t		\
	   	reverse		\
		replace		\
		swapcase	\
		lower		\
		upper		\
		float		\
		quote		\
		contains	\
		isnum		\
		isnull		\
		insert		\
		append		\
		slice		\
		__le__		\
		__lt__		\
		__ge__		\
		__gt__		\
		__ne__		\
		__eq__

# .TYPE ptr_t
#
# O tipo 'ptr_t' é um ponteiro que implementa os métodos e funções 'builtin' para
# alteração dos valores atribuídos. Os métodos implementados por esse tipo não
# retornam dados na saída padrão, porém é alterado o valor do objeto implementado.
#
# Implementa objeto 'S' com os métodos:
#
# S.reverse
# S.replace
# S.swapcase
# S.lower
# S.upper
# S.float
# S.quote
# S.contains
# S.isnum
# S.isnull
# S.insert
# S.append
# S.slice
# S.__le__
# S.__lt__
# S.__ge__
# S.__gt__
# S.__ne__
# S.__ne__
# S.__eq__
#
typedef ptr_t		\
	   	reverse		\
		replace		\
		swapcase	\
		lower		\
		upper		\
		float		\
		quote		\
		contains	\
		isnum		\
		isnull		\
		insert		\
		append		\
		slice		\
		__le__		\
		__lt__		\
		__ge__		\
		__gt__		\
		__ne__		\
		__eq__

# somente-leiura
readonly -f	typedef		\
			var			\
			len			\
			sizeof		\
			typeof		\
			del			\
			len			\
			input		\
			assert		\
			iif			\
			has			\
			all			\
			any			\
			bin			\
			swap		\
			sum			\
			fnfilter	\
			chr			\
			ord			\
			hex			\
			oct			\
			htoi		\
			btoi		\
			otoi		\
			range		\
			isobj		\
			fnmap		\
			iter		\
			enum		\
			listobj		\
			min			\
			max			\
			count		\
			reversed	\
			unique		\
			isnull		\
			quote		\
			float		\
			upper		\
			lower		\
			swapcase	\
			replace		\
			reverse		\
			contains	\
			isnum		\
			sorted		\
			insert		\
			append		\
			__imp__		\
			__type__	\
			__size__	\
			__del__		\
			__func__	\
			__src__		\
			__comp__	\
			__null__	\
			__eq__		\
			__ne__		\
			__gt__		\
			__ge__		\
			__lt__		\
			__le__

# /* __BUILTIN_SH__ */
