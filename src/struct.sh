#!/bin/bash

[[ $__STRUCT_SH ]] && return 0

readonly __STRUCT_SH=1

source builtin.sh

declare -A 	__STRUCT_VAL_MEMBERS \
			__STRUCT_MEMBERS

readonly __ERR_STRUCT_MEMBER_NAME='nome do membro da estrutura inválido'
readonly __ERR_STRUCT_ALREADY_INIT='a estrutura já foi inicializada'
readonly __ERR_STRUCT_MEMBER_CONFLICT='conflito de membros na estrutura'

__SRC_TYPES[struct]='
struct.__init__
struct.__members__
struct.__copy__
struct.__size__
struct.__values__
struct.__items__
'

# func struct.__init__ <[var]name> <[str]member> ...
#
# Inicializa a estrutura 'name' com 'N' members.
#
function struct.__init__(){
	getopt.parse -1 "name:struct:+:$1" "member:str:+:$2" ... "${@:3}"

	local member struct

	if [[ ${__STRUCT_MEMBERS[$1]} ]]; then	
		error.__trace def 'struct' "$1" "$member" "$__ERR_STRUCT_ALREADY_INIT"
		return $?
	fi

	for member in ${@:2}; do
		if [[ $member != *(_)+([a-zA-Z])*([a-zA-Z0-9_.]) ]]; then
			error.__trace def '' '' "$member" "$__ERR_STRUCT_MEMBER_NAME"
			return $?
		elif declare -Fp $1.$member &>/dev/null; then
			error.__trace def 'member' 'str' "$member" "$__ERR_STRUCT_MEMBER_CONFLICT"
			return $?
		fi

		printf -v struct '%s.%s(){ struct.__set_and_get "%s" "%s" "$@"; return 0; }' \
		"$1" "$member" "$1" "$member"

		eval "$struct" &>/dev/null || error.__trace def
		__STRUCT_MEMBERS[$1]+="$member "
	done
	
	return 0
}

# func struct.__members__ <[struct]name> => [str]
#
# Lista os membros da estrutura.
#
function struct.__members__()
{
	getopt.parse 1 "name:struct:+:$1" "${@:2}"
	echo ${__STRUCT_MEMBERS[$1]}

	return 0
}

# func struct.__copy__ <[struct]src> <[struct]dest>
#
# Cria uma cópia de 'src' com a nomenclatura especificada em 'dest'.
#
function struct.__copy__()
{
	getopt.parse 2 "src:struct:+:$1" "dest:struct:+:$2" "${@:3}"
	
	local member
	
	$2.__init__ $($1.__members__)

	for member in ${__STRUCT_MEMBERS[$1]}; do
		__STRUCT_VAL_MEMBERS[$2.$member]=${__STRUCT_VAL_MEMBERS[$1.$member]}
	done

	__STRUCT_MEMBERS[$2]=${__STRUCT_MEMBERS[$1]}

	return 0
}

# func struct.__size__ <[struct]name> => [uint]
#
# Retorna o total de elementos contidos na estrutura.
#
function struct.__size__()
{
	getopt.parse 1 "name:struct:+:$1" "${@:2}"

	local len
	len=(${__STRUCT_MEMBERS[$1]})
	echo ${#len[@]}

	return 0	
}

# func struct.__values__ <[struct]name> => [str]
#
# Retorna uma lista iterável contendo os valores de cada elemento da estrutura.
# 
function struct.__values__()
{
	getopt.parse 1 "name:struct:+:$1" "${@:2}"

	local member
	for member in ${__STRUCT_MEMBERS[$1]}; do
		echo "${__STRUCT_VAL_MEMBERS[$1.$member]}"
	done

	return 0
}

# func struct.__items__ <[struct]name> => [uint]|[str]|[str]
#
# Retorna uma lista iterável com o tamanho, nome e valor de cada membro
# da estrutura.
# 
function struct.__items__()
{
	getopt.parse 1 "name:struct:+:$1" "${@:2}"

	local member val
	for member in ${__STRUCT_MEMBERS[$1]}; do
		val=${__STRUCT_VAL_MEMBERS[$1.$member]}
		echo "${#val}|$member|${val}"
	done

	return 0
}

function struct.__set_and_get()
{
	getopt.parse 4 "name:struct:+:$1" "member:str:+:$2" "=:keyword:-:$3" "value:str:-:$4" "${@:5}"

	case ${#@} in
		2)		echo "${__STRUCT_VAL_MEMBERS[$1.$2]}";;
		3|4) 	__STRUCT_VAL_MEMBERS[$1.$2]=$4;;
	esac
	return 0
}

source.__INIT__
# /* __STRUCT_SH */
