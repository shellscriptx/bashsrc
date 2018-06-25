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

[[ $__IO_SH ]] && return 0

readonly __IO_SH=1

source builtin.sh

__TYPE__[io_t]='
io.rmline
io.rmlinecontains
io.rmlinematch
'

# func io.rmline <[file]filename> <[bool]writer> <[bool]invert> <[uint]number> ... => [str]
#
# Remove linhas especificas.
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# invert   - Inverter a seleção especificada.
# number   - Número da linha a ser removida.
#
# Obs: Pode ser especificada uma ou mais linhas.
#
function io.rmline()
{
	getopt.parse -1 "filename:file:+:$1" "writer:bool:+:$2" "invert:bool:+:$3" "line:uint:+:$4" ... "${@:4}"
	
	local ln lns line tmp
	
	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	lns=${@:4}
	lns=${lns// /|}

	while read line; do
		if [[ $3 == false ]]; then
			[[ $((++ln)) == @($lns) ]]
		else
			[[ $((++ln)) != @($lns) ]]
		fi && continue
		echo "$line"
	done < "$1" >> $tmp

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"
	
	rm -f "$tmp"

	return $?
}

# func io.rmlinecontains <[file]filename> <[bool]writer> <[bool]invert> <[str]pattern> ... => [str]
#
# Remove a(s) linha(s) que contém a expressão.
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# invert   - Inverter a seleção especificada.
# pattern  - Sequência de caracateres que determina o padrão a casar.
#
# Obs: Pode ser especificado mais de um padrão.
#
function io.rmlinecontains()
{
	getopt.parse -1 "filename:file:+:$1" "writer:bool:+:$2" "invert:bool:+:$3" "pattern:str:+:$4" ... "${@:5}"
	
	local line tmp patterns

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	patterns=${@:4}
	patterns=${patterns// /|}

	while read line; do
		if [[ $3 == false ]]; then
			[[ $line == *@($patterns)* ]]
		else
			[[ $line != *@($patterns)* ]]
		fi && continue
		echo "$line"
	done < "$1" >> $tmp

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"
	
	rm -f "$tmp"

	return $?
}

# func io.rmlinematch <[file]filename> <[bool]writer> <[bool]invert> <[str]pattern> ... => [str]
#
# Remove a(s) linha(s) que conicide(m) com o padrão especificado.
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# invert   - Inverter a seleção especificada.
# pattern  - Sequência de caracateres que determina o padrão a casar. 
#            Suporta ERE (Expressão Regular Estendida).
#
# Obs: Pode ser especificado mais de um padrão.
#
function io.rmlinematch()
{
	getopt.parse -1 "filename:file:+:$1" "writer:bool:+:$2" "invert:bool:+:$3" "pattern:str:+:$4" ... "${@:5}"
	
	local line tmp patterns

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	patterns=${@:4}
	patterns=${patterns// /|}

	while read line; do
		if [[ $3 == false ]]; then
			[[ $line =~ $patterns ]]
		else
			[[ ! $line =~ $patterns ]]
		fi && continue
		echo "$line"
	done < "$1" >> $tmp

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"
	
	rm -f "$tmp"

	return $?
}


function io.__write_file()
{
	if ! echo "$(< "$1")" > "$2" &>/dev/null; then
		error.format 1 "falha ao gravar as alterações no arquivo '%s'" "$2"
		return $?
	fi

	return $?
}
source.__INIT__
# /* __IO_SH  */
