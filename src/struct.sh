#!/bin/bash

[[ $__STRUCT_SH ]] && return 0

readonly __STRUCT_SH=1

source builtin.sh

declare -A 	__STRUCT_VAL_MEMBERS \
			__STRUCT_MEMBERS \
			__STRUCT_HANDLE

readonly __ERR_STRUCT_MEMBER_NAME='nome do membro da estrutura inválido'
readonly __ERR_STRUCT_ALREADY_INIT='a estrutura já foi inicializada'
readonly __ERR_STRUCT_MEMBER_CONFLICT='conflito de membros na estrutura'
readonly __ERR_STRUCT_TYPE='requer estrutura do tipo'

__NO_BUILTIN_T__='
struct_t
'

__TYPE__[struct_t]='
struct.__typedef__
struct.__add__
struct.__members__
struct.__copy__
struct.__len__
struct.__values__
struct.__items__
struct.__readonly__
struct.__handle__
__type__
'

# func struct.__typedef__ <[struct_t]name> <[struct_t]type>
#
# Inicializa 'name' com o tipo da estrutura especificada em 'type'.
#
function struct.__typedef__()
{
	getopt.parse 2 "new:struct_t:+:$1" "type:struct_t:+:$2" "${@:3}"

	local member members

	if [[ ${__STRUCT_MEMBERS[$1]} ]]; then	
		error.__trace def 'new' "struct_t" "$1" "$__ERR_STRUCT_ALREADY_INIT"
		return $?
	fi

	for member in ${__STRUCT_MEMBERS[$2]}; do
		members+="${member#*.} "
	done
	
	$1.__add__ $members
	__STRUCT_HANDLE[$1]=$2

	return 0	
}

# func struct.__readonly__ <[struct_t]name>
#
# Define o atributo somente-leitura para os membros da estrutura.
#
function struct.__readonly__()
{
	getopt.parse -1 "name:struct_t:+:$1" ... "${@:2}"

	local struct
	for struct in $@; do
		readonly -f ${__STRUCT_MEMBERS[$struct]}
	done
}

# func struct.__add__ <[struct_t]name> <[str]member> ...
#
# Adiciona 'N'membros a estrutura 'name'.
#
function struct.__add__(){
	getopt.parse -1 "name:struct_t:+:$1" "member:str:+:$2" ... "${@:3}"

	local member struct

	if [[ ${__STRUCT_MEMBERS[$1]} ]]; then	
		error.__trace def 'new' "struct_t" "$1" "$__ERR_STRUCT_ALREADY_INIT"
		return $?
	fi

	for member in ${@:2}; do
		if ! [[ $member =~ ${__HASH_TYPE[st_member]} ]]; then
			error.__trace def '' '' "$member" "$__ERR_STRUCT_MEMBER_NAME"
			return $?
		elif declare -Fp $1.$member &>/dev/null; then
			error.__trace def 'member' 'str' "$member" "$__ERR_STRUCT_MEMBER_CONFLICT"
			return $?
		fi

		printf -v struct '%s.%s(){ struct.__set_and_get "%s" "%s" "$@"; return 0; }' \
		"$1" "$member" "$1" "$member"

		eval "$struct" &>/dev/null || error.__trace def
		__STRUCT_MEMBERS[$1]+="$1.$member "
	done
	
	__STRUCT_HANDLE[$1]="$1"

	return 0
}

# func struct.__members__ <[struct_t]name> => [str]
#
# Lista os membros da estrutura.
#
function struct.__members__()
{
	getopt.parse 1 "name:struct_t:+:$1" "${@:2}"
	printf '%s\n' ${__STRUCT_MEMBERS[$1]}

	return 0
}

# func struct.__copy__ <[struct_t]src> <[struct_t]dest>
#
# Cria uma cópia de 'src' com a nomenclatura especificada em 'dest'.
#
function struct.__copy__()
{
	getopt.parse 2 "src:struct_t:+:$1" "dest:struct_t:+:$2" "${@:3}"
	
	local member members

	for member in ${__STRUCT_MEMBERS[$1]}; do
		members+="${member#*.} "
		__STRUCT_VAL_MEMBERS[$2.${member#*.}]=${__STRUCT_VAL_MEMBERS[$member]}
	done
	
	$2.__add__ $members

	return 0
}

# func struct.__len__ <[struct_t]name> => [uint]
#
# Retorna o total de elementos contidos na estrutura.
#
function struct.__len__()
{
	getopt.parse 1 "name:struct_t:+:$1" "${@:2}"

	local len=(${__STRUCT_MEMBERS[$1]})
	echo ${#len[@]}

	return 0	
}

# func struct.__values__ <[struct_t]name> => [str]
#
# Retorna uma lista iterável contendo os valores de cada elemento da estrutura.
# 
function struct.__values__()
{
	getopt.parse 1 "name:struct_t:+:$1" "${@:2}"

	local member
	
	for member in ${__STRUCT_MEMBERS[$1]}; do
		echo "${__STRUCT_VAL_MEMBERS[$member]}"
	done

	return 0
}

# func struct.__items__ <[struct_t]name> => [uint]|[str]|[str]
#
# Retorna uma lista iterável com o tamanho, nome e valor de cada membro
# da estrutura.
# 
function struct.__items__()
{
	getopt.parse 1 "name:struct_t:+:$1" "${@:2}"

	local member val
	for member in ${__STRUCT_MEMBERS[$1]}; do
		val=${__STRUCT_VAL_MEMBERS[$member]}
		echo "${#val}|$member|$val"
	done

	return 0
}

# func struct.__handle__ <[struct_t]name> => [str]
#
# Retorna a flag de identificação da estrutura.
#
function struct.__handle__()
{
	getopt.parse 1 "name:struct_t:+:$1" "${@:2}"
	echo "${__STRUCT_HANDLE[$1]}"
	return 0
}

function struct.__set_and_get()
{
	getopt.parse 4 "name:struct_t:+:$1" "member:str:+:$2" "=:keyword:-:$3" "value:str:-:$4" "${@:5}"

	case ${#@} in
		2)		echo "${__STRUCT_VAL_MEMBERS[$1.$2]}";;
		3|4) 	__STRUCT_VAL_MEMBERS[$1.$2]=$4;;
	esac
	return 0
}

source.__INIT__
# /* __STRUCT_SH */
