#!/bin/bash
#
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

[[ $__JSON_SH ]] && return 0

readonly __JSON_SH=1

source builtin.sh

# DEPENDÊNCIA
__DEP__[jq]='>= 1.5'	# Processador de linha de comando JSON

__TYPE__[json_t]='
json.value
json.keys
json.values
json.filter
json.parse
json.type
'

# func json.values <[str]json> => [str]
#
# Retorna o valor de todas as chaves contidas em 'json'.
#
function json.values()
{
	getopt.parse 1 "json:str:+:$1" ${@:2}
	
	local val

	jq -M '[..|select(type == "number" or type == "string" or type == "boolean")|tostring]|.[]' <<< $1 2>/dev/null | while read -r val; do
		val=${val#\"}
		echo "${val%\"}"
	done

	return $?
}

# func json.keys <[str]json> => [str]
#
# Retorna todas as chaves contidas em 'json'.
#
function json.keys()
{
	getopt.parse 1 "json:str:+:$1" ${@:2}
	jq -Mr 'path(..)|map(if type == "number" then .|tostring|"["+.+"]" else . end)|join(".")|gsub(".\\[";"[")|if . != "" then . else empty end' <<< $1 2>/dev/null
	return $?
}

# func json.value <[str]json> <[str]key> ... => [str]
#
# Extrai o valor de 'key'.
# Obs: pode ser especificado uma ou mais chaves.
#
function json.value()
{
	getopt.parse -1 "json:str:+:$1" ... "key:str:+:$2" "${@:3}"
	
	local val parse

	parse=${@:2}
	parse=${parse// /,.}

	jq -Mc ".$parse" <<< $1 2>/dev/null | while read -r val; do
		val=${val#\"}
		echo "${val%\"}"
	done

	return $?
}

# func json.filter <[str]json> <[flag]type> ... => [str]
#
# Retorna uma lista iterável com os valores das chaves do(s) tipo(s) especificado(s).
# Obs: pode ser especificado um ou mais tipos.
#
# Tipos: array, object, string, number ou boolean
#
function json.filter()
{
	getopt.parse -1 "json:str:+:$1" ... "type:flag:+:$2" "${@:3}"
	
	if [[ $2 != @(array|object|string|number|boolean) ]]; then
		error.trace def "type" "flag" "$2" "flag type inválida"
		return $?
	fi

	local val type parse
	
	for type in "${@:2}"; do
		parse+=" type == \"$type\" or"
	done
	
	jq -Mc "..|select(${parse%or})" <<< $1 2>/dev/null | while read -r val; do
		val=${val#\"}
		echo "${val%\"}"
	done

	return $?
}

# func json.parse <[str]json> <[str]commands> => [str]
#
# Executa os comandos JavaScript Object Notation no objeto 'json'.
#
function json.parse()
{
	getopt.parse 2 "json:str:+:$1" "parse:str:+:$2" ${@:3}

	local val

	jq -Mc "$2" <<< $1 | while read -r val; do
		val=${val#\"}
		echo "${val%\"}"
	done
	
	return $?
}

# func json.type <[str]json> <[str]key> => [str]
#
# Retorna o tipo da chave especificada contida em 'json'.
#
function json.type()
{
	getopt.parse 2 "json:str:+:$1" "key:str:+:$2" "${@:3}"
	jq -r "$2|type" <<< $1 2>/dev/null
	return $?
}

source.__INIT__
# /* __JSON_SH */
