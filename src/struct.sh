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

[ -v __STRUCT_SH__ ] && return 0

readonly __STRUCT_SH__=1

# Imports
source builtin.sh

# Protótipos
readonly -A __STRUCT__=(
[member]='^[a-zA-Z][a-zA-Z0-9_]*$'
)

# .FUNCTION struct.__add__  <obj[struct_t]> <member[str]> <typename[type]> ... [bool]
#
# Adiciona membro a estrutura com o tipo especificado.
# > Pode ser especificado mais de um membro.
# 
# == EXEMPLO ==
#
# source struct.sh
#
# # Implementando uma estrutura.
# # Utilize o sufixo '_st' para facilitar a identificação do tipo. (recomendado)
# var cliente_st struct_t
#
# # Definindo membros e tipos.
# cliente_st.__add__ nome      str \
#                    sobrenome str \
#                    idade     uint \
#                    telefone  str
#
#
# # Implementando a nova estrutura.
# var cliente cliente_st
#
# # Atribuindo valores.
# cliente.nome = 'Lucas'
# cliente.sobrenome = 'Morais'
# cliente.idade = 27
# cliente.telefone = 98841-1232
#
# # Acessando valores
# cliente.nome
# cliente.sobrenome
# cliente.idade
# cliente.telefone
#
# == SAÍDA ==
# 
# Lucas
# Morais
# 27
# 98841-1232
#
function struct.__add__()
{
	getopt.parse -1 "obj:struct_t:$1" "member:str:$2" ... "${@:3}"

	local __obj__=$1
	local -n __ref__=$1
	local __mbrs__

	# Define o objeto como map para armazenar os campos/valores da estrutura.
	declare -Ag $__obj__ || error.fatal "'$__obj__' não foi possível definir a estrutura do objeto"

	# Analisa argumentos posicionais subsequentes.
	set "${@:2}"

	while [[ $@ ]]
	do
		[[ $1 =~ ${__STRUCT__[member]}					]]	|| error.fatal "'$1' não é um identificador válido"
		[[ $2 =~ ${__BUILTIN__[vartype]} 				]]	|| error.fatal "'$2' erro de sintaxe"
		[[ ${2%[*} == @(${__ALL_TYPE_NAMES__// /|})		]]	|| error.fatal "'$2' tipo do objeto desconhecido"
		
		struct.__get__ $__obj__ $1 $2 	# Lê estrutura
		shift 2							# desloca os argumentos tratados.
	done

	# Implementa os membros da estrutura.
	typedef $__obj__ ${__ref__[__MEMBERS__:$__obj__]}
	
	return $?
}

# .FUNCTION struct.__members__ <obj[struct_t]> -> [str]|[bool]
function struct.__members__()
{
	getopt.parse 1 "obj:struct_t:$1" "${@:2}"

	local -n __ref__=$1
	local __mbr__

	for __mbr__ in ${__ref__[__MEMBERS__:$1]}; do
		echo "${__mbr__#*.}"
	done

	return $?
}

# .FUNCTION struct.__repr__ <obj[struct_t]> -> [str|str]|[bool]
function struct.__repr__()
{
	getopt.parse 1 "obj:struct_t:$1" "${@:2}"
	
	local -n __ref__=$1
	printf '%s\n' ${__ref__[__REPR__:$1]}

	return $?
}

# .FUNCTION struct.__kind__ <obj[struct_t]> <member[str]> -> [str]|[bool]
function struct.__kind__()
{
	getopt.parse 2 "obj:struct_t:$1" "member:str:$2" "${@:3}"

	local __obj__=$1[__KIND__:$2]

	[[ -v $__obj__ ]] || error.fatal "'$2' não é membro da estrutura '$1'"
	echo ${!__obj__}

	return $?
}

# struct.__get__ <obj[var]> <member[str]>  <typename[type]>
struct.__get__()
{
	local __mem__ __kind__

	# Se o membro for implementado por outra estrutura inicia uma leitura
	# recursiva até que todos elementos sejam definidos.
	if [[ $(typeof $3) == struct_t && $3 =~ ${__BUILTIN__[varname]} ]]; then
		for __mem__ in $($3.__members__); do
			# Obtem o tipo do objeto na sub-estrutura
			__kind__=$($3.__kind__ $__mem__)
			[[ $(typeof $__kind__) == struct_t ]] 	&&
			struct.__get__ $1 $2.$__mem__ $__kind__	||	# Lê a próxima estrutura. (recursivo)
			struct.__set__ $1 $2.$__mem__ $__kind__		# Define o membro.
		done
	else
		# (não estrutura)
		struct.__set__ $1 $2 $3
	fi

	return $?
}

# struct.__set__ <obj[var]> <member[str]> <typename[type]>
struct.__set__()
{	
	local -n __ref__=$1

	# Verifica conflitos
	[[ $2 == @(${__mbrs__}) ]] && error.fatal "'$2' conflito de membros na estrutura"

	# Define o protótipo do membro na estutura determinando o nome e tipo suportado.
	# O tratamento dos argumentos do campo é condicional, ou seja, o comportamento
	# irá depender de como o membro é chamado.
	#
	# Exemplo:
	#
	# estrutura.membro    			-> Obtém valor
	# estrutura.membro = 'foo'		-> Atribui valor
	#
	local __struct__='%s()
	{
		# Converte o objeto para o tipo "map" (global).
		declare -Ag ${1%%%%[*} || error.fatal "não foi possível inicializar a estrutura."

		local -n __ref__=${1%%%%[*}		# referência
		local __vet__

		# Captura o índice do objeto (se existir).
		[[ $1 =~ \[[0-9]+\] ]] 
		__vet__=$BASH_REMATCH

		# Retorna o valor armazenado na chave se a implementação for chamada sem argumentos.
		[[ ${#@} -eq 1 ]] && echo "${__ref__[${__vet__}${FUNCNAME#*.}]}" && return $?

		# Trata os valores.
		getopt.parse 3 "__obj__:var:${1%%%%[*}" "operator:char:$2" "${FUNCNAME##*.}:%s%s:$3" "${@:4}"

		[[ $2 != = ]] && error.fatal "\\"$2\\" operador de atribuição inválido"

		# Salva o valor em sua respectiva chave.
		__ref__[${__vet__}${FUNCNAME#*.}]=$3

		return $?
	}'

	# Inicializa protótipo.
	printf -v __struct__ "$__struct__" 	"$1.$2" "$3"
	eval "$__struct__" || error.fatal "'$1.$2' não foi possível definir o membro da estrutura"

	# Anexa membro
	__mbrs__+=${__mbrs__:+|}${2}

	# Registra a estrutura
	__ref__[__KIND__:$2]=$3				# Tipo 			
	__ref__[__MEMBERS__:$1]+=$1.$2' '	# Membros 		(estrutura.membro)
	__ref__[__REPR__:$1]+=$1.$2'|'$3' '	# Representação (estrutura.membro|tipo)
	__ref__[__STRUCT__:$1]=true			# Status

	return $?
}

# .TYPE struct_t
#
# O tipo 'struct_t' implementa métodos para construção de uma
# estrutura genérica com definição de membros e tipos.
#
# Implementa o objeto 'S" com os métodos:
#
# S.__add__
# S.__members__
# S.__repr__
# S.__kind__
#
typedef struct_t 			\
		struct.__add__		\
		struct.__members__	\
		struct.__kind__		\
		struct.__repr__

readonly -f struct.__add__ 		\
			struct.__members__	\
			struct.__kind__		\
			struct.__repr__		\
			struct.__set__		\
			struct.__get__

# /* __STRUCT_SH__ */
