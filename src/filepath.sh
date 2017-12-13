#!/bin/bash

[[ $__FILEPATH_SH ]] && return 0

readonly __FILEPATH_SH=1

source builtin.sh

function filepath.ext()
{
    getopt.parse "path:str:+:$1"
    [[ $1 =~ \.[a-zA-Z0-9_-]+$ ]]
    echo "${BASH_REMATCH[0]}"
    return 0
}

function filepath.basename()
{
    getopt.parse "path:str:+:$1"
    echo "${1##*/}"
    return 0
}

function filepath.dirname()
{
    getopt.parse "path:str:+:$1"
    echo "${1%/*}"
    return 0
}

function filepath.relpath()
{
    getopt.parse "path:str:+:$1"

    local IFSbkp cur path relpath slash item i

    IFSbkp=$IFS; IFS='/'
    cur=(${PWD#\/}); path=(${1#\/})
    IFS=$IFSbkp
        
    for ((i=${#cur[@]}-1; i >= 0; i--)); do
        [[ "${cur[$i]}" == "${path[0]}" ]] && break
        slash+='../'
    done
        
    for item in "${path[@]:$((i >= 0 ? 1 : 0))}"; do
        relpath+=$item'/'
    done

    relpath=${slash}${relpath%\/}

    echo "${relpath:-.}"

    return 0
}

function filepath.split()
{
	getopt.parse "path:str:+:$1"
	echo "$(filepath.dirname "$1")|$(filepath.basename "$1")"
	return 0
}

# func filepath.slash <[str]path> => [str]
#
# Retorna uma lita iterável removendo o separador de diretório '/'.
#
function filepath.slash()
{
	getopt.parse "path:str:+:$1"
	local path=$(str.ltrim "$1" "/")
	echo -e "${path//\//\\n}"
	return 0	
}

readonly -f filepath.ext \
			filepath.basename \
			filepath.dirname \
			filepath.relpath

# /* __FILEPATH_SH */
