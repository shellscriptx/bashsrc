#!/bin/bash

[[ $__STRUCT_SH ]] && return 0

readonly __STRUCT_SH=1

source builtin.sh

declare -A 	__STRUCT_VAL_MEMBERS \
			__STRUCT_MEMBERS

readonly __ERR_STRUCT_MEMBER_NAME='nome do membro da estrutura inválido'
readonly __ERR_STRUCT_NOT_FOUND='o objeto informado não é do tipo "struct"'
readonly __ERR_STRUCT_MEMBER_ALREADY_INIT='o membro da estrutura já foi inicializado'

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
	getopt.parse 1 "struct:var:+:$1"

	local member struct i

	[[ ${FUNCNAME[1]} == $1.__init__ ]] && i=2 || i=1

	for member in ${@:2}; do
		if [[ $member != +([a-zA-Z])*([a-zA-Z0-9_.]) ]]; then
			error.__trace def '' '' "$member" "$__ERR_STRUCT_MEMBER_NAME"
			return $?
		fi
		
		printf -v struct '%s.%s(){ struct.__set_and_get "${FUNCNAME[1]}" "%s" "%s" "$@"; return 0; }' \
		"$1" "$member" "$1" "$member"
	
		if ! eval "$struct" &>/dev/null; then
			error.__trace def 'struct' "$1" "$member" "$__ERR_STRUCT_MEMBER_ALREADY_INIT"
			return $?
		fi
		__STRUCT_MEMBERS[${FUNCNAME[$i]}.$1]+="$member "
	done
	
	return 0
}

# func struct.__members__ <[var]name> => [str]
#
# Lista os membros da estrutura.
#
function struct.__members__()
{
	getopt.parse 1 "struct:var:+:$1" "${@:2}"

	local i
	[[ ${FUNCNAME[1]} == $1.__members__ ]] && i=2 || i=1
	echo ${__STRUCT_MEMBERS[${FUNCNAME[$i]}.$1]}

	return 0
}

# func struct.__copy__ <[var]src> <[var]dest>
#
# Copia os dados da estrutura 'src' para 'dest'.
#
function struct.__copy__()
{
	getopt.parse 2 "st_src:var:+:$1" "st_dest:var:+:$2" "${@:3}"
	
	local member i
	
	[[ ${FUNCNAME[1]} == $1.__copy__ ]] && i=2 || i=1

	if [[ ${__VAR_REG_TYPES[$1]} != struct ]]; then
		error.__trace def 'st_src' 'struct' "$1" "$__ERR_STRUCT_NOT_FOUND"
		return $?
	elif [[ ${__VAR_REG_TYPES[$2]} != struct ]]; then
		error.__trace def 'st_dest' 'struct' "$2" "$__ERR_STRUCT_NOT_FOUND"
		return $?
	fi

	for member in ${__STRUCT_MEMBERS[${FUNCNAME[$i]}.$1]}; do
		__STRUCT_VAL_MEMBERS[${FUNCNAME[$i]}.$2.$member]=${__STRUCT_VAL_MEMBERS[${FUNCNAME[$i]}.$1.$member]}
	done

	__STRUCT_MEMBERS[${FUNCNAME[$i]}.$2]=${__STRUCT_MEMBERS[${FUNCNAME[$i]}.$1]}
	
	return 0
}

# func struct.__size__ => [uint]
#
# Retorna o total de elementos contidos na estrutura.
#
function struct.__size__()
{
	getopt.parse 1 "struct:var:+:$1" "${@:2}"

	local len i

	[[ ${FUNCNAME[1]} == $1.__size__ ]] && i=2 || i=1

	if [[ ${__VAR_REG_TYPES[$1]} != struct ]]; then
		error.__trace def 'st_src' 'struct' "$1" "$__ERR_STRUCT_NOT_FOUND"
		return $?
	fi

	len=(${__STRUCT_MEMBERS[${FUNCNAME[$i]}.$1]})
	echo ${#len[@]}

	return 0	
}

# func struct.__values__ => [str]
#
# Retorna uma lista iterável contendo os valores de cada elemento da estrutura.
# 
function struct.__values__()
{
	getopt.parse 1 "struct:var:+:$1" "${@:2}"

	local member i

	[[ ${FUNCNAME[1]} == $1.__values__ ]] && i=2 || i=1

	if [[ ${__VAR_REG_TYPES[$1]} != struct ]]; then
		error.__trace def 'st_src' 'struct' "$1" "$__ERR_STRUCT_NOT_FOUND"
		return $?
	fi

	for member in ${__STRUCT_MEMBERS[${FUNCNAME[$i]}.$1]}; do
		echo "${__STRUCT_VAL_MEMBERS[${FUNCNAME[$i]}.$1.$member]}"
	done

	return 0
}

# func struct.__items__ => [uint]|[str]|[str]
#
# Retorna uma lista iterável com o tamanho, nome e valor de cada membro
# da estrutura.
# 
function struct.__items__()
{
	getopt.parse 1 "struct:var:+:$1" "${@:2}"

	local member val i
	
	[[ ${FUNCNAME[1]} == $1.__items__ ]] && i=2 || i=1

	if [[ ${__VAR_REG_TYPES[$1]} != struct ]]; then
		error.__trace def 'st_src' 'struct' "$1" "$__ERR_STRUCT_NOT_FOUND"
		return $?
	fi

	for member in ${__STRUCT_MEMBERS[${FUNCNAME[$i]}.$1]}; do
		val=${__STRUCT_VAL_MEMBERS[${FUNCNAME[$i]}.$1.$member]}
		echo "${#val}|$member|${val}"
	done

	return 0
}

function struct.__set_and_get()
{
	getopt.parse 5 "scope:str:+:$1" "struct:var:+:$2" "member:str:+:$3" "=:keyword:-:$4" "value:str:-:$5" "${@:6}"

	case ${#@} in
		3)		echo "${__STRUCT_VAL_MEMBERS[$1.$2.$3]}";;
		4|5) 	__STRUCT_VAL_MEMBERS[$1.$2.$3]=$5;;
	esac
	return 0
}

source.__INIT__
# /* __STRUCT_SH */
