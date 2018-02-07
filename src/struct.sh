#!/bin/bash

[[ $__STRUCT_SH ]] && return 0

readonly __STRUCT_SH=1

source builtin.sh

declare -A  __STRUCT_VAL_MEMBERS \
			__INIT_STRUCT

readonly __ERR_STRUCT_MEMBER_NAME='nome do membro da estrutura inválido'
readonly __ERR_STRUCT_ALREADY_INIT='a estrutura já foi inicializada'
readonly __ERR_STRUCT_MEMBER_CONFLICT='conflito de membros na estrutura'
readonly __ERR_STRUCT_TYPE='requer estrutura do tipo'
readonly __ERR_STRUCT_NOT_FOUND='nome da estrutura inválida'

__TYPE__[struct_t]='
struct.__add__
struct.__members__
struct.__len__
__type__
'

# func struct.__add__ <[struct_t]name> <[str]member> ...
#
# Adiciona 'N' membros a estrutura 'name'.
#
function struct.__add__(){
	getopt.parse -1 "name:struct_t:+:$1" "member:st_member:+:$2" ... "${@:3}"

	local member smember stcomp st_type

	if [[ ${__INIT_STRUCT[$1]} ]]; then
		error.__trace def 'new' "struct_t" "$1" "$__ERR_STRUCT_ALREADY_INIT"
		return $?
	fi

	for member in ${@:2}; do
		if [[ $member =~ ${__HASH_TYPE[ptr]} ]]; then
			st_type=${member:1}
			st_comp=1
			continue
		elif declare -Fp $1.$member &>/dev/null; then
			error.__trace def 'member' 'str' "$member" "$__ERR_STRUCT_MEMBER_CONFLICT"
			return $?
		fi
		if [[ $st_comp ]]; then
			if [[ ${__INIT_OBJ_TYPE[$st_type]} != struct_t ]]; then	
				error.__trace def 'member' "struct_t" "$st_type" "$__ERR_STRUCT_NOT_FOUND"
				return $?
			fi
			for smember in $($st_type.__members__); do
				__INIT_SRC_TYPES[$1]+="$1.$member.$smember "
			done
			st_comp=''
		else
			__INIT_SRC_TYPES[$1]+="$1.$member "
		fi
	done
	
	__INIT_STRUCT[$1]=true
	
	return 0
}

# func struct.__members__ <[struct_t]name> => [str]
#
# Lista os membros da estrutura.
#
function struct.__members__()
{
	getopt.parse 1 "name:struct_t:+:$1" "${@:2}"
	local mem
	for mem in ${__INIT_SRC_TYPES[$1]}; do
		echo "${mem#*.}"
	done
	return 0
}

# func struct.__len__ <[struct_t]name> => [uint]
#
# Retorna o total de elementos contidos na estrutura.
#
function struct.__len__()
{
	getopt.parse 1 "name:struct_t:+:$1" "${@:2}"

	local len=(${__INIT_SRC_TYPES[$1]})
	echo ${#len[@]}

	return 0	
}

source.__INIT__
# /* __STRUCT_SH */
