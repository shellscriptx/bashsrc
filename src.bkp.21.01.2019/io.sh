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
io.delline
io.delnline
io.delbline
io.delaline
io.delfline
io.delllast
io.insline
io.insnline
io.appline
io.appnline
io.chline
io.chnline
io.cpline
io.cpnline
'

# func io.open <[io_t]file> <[file]filename> <[flag]mode> => [bool]
function io.open()
{
	getopt.parse 3 "file:io_t:+:$1" "filename:file:+:$2" "mode:flag:+:$3" "${@:4}"
	
	
}
# func io.delline <[file]filename> <[bool]writer> <[str]pattern> <[bool]invert> => [str]
#
# Apaga a(s) linha(s) que contém o padrão especificado.
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# pattern  - Sequência de caracteres que determina o padrão a casar. 
#            Suporta ERE (Expressão Regular Estendida).
# invert   - Inverter seleção.

#
# Obs: O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.delline
{
	getopt.parse 4 "filename:file:+:$1" "writer:bool:+:$2" "pattern:str:+:$3" "invert:bool:+:$4" "${@:5}"
	
	local line tmp

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)

	while read line; do
		if [[ $4 == false ]]; then
			[[ $line =~ $3 ]]
		else
			[[ ! $line =~ $3 ]]
		fi || echo -e "$line"
	done < "$1" >> "$tmp"
	
	[[ $2 == false ]] && cat "$tmp" || io.__write_file "$tmp" "$1"

	return $?
}

# func io.delnline <[file]filename> <[bool]writer> <[uint]lineno> ... => [str]
#
# Apaga a(s) linha(s) especificada(s).
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# lineno   - Número da linha a ser removida.
#
# Obs: Pode ser informado uma ou mais linhas.
#      O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.delnline
{
	getopt.parse -1 "filename:file:+:$1" "writer:bool:+:$2" "lineno:uint:+:$3" ... "${@:4}"
	
	local ln lns line tmp
	
	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	lns=${@:3}
	lns=${lns// /|}

	while read line; do
		[[ $((++ln)) == @($lns) ]] || echo -e "$line"
	done < "$1" >> $tmp

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"
	
	return $?
}

# func io.delbline <[file]filename> <[bool]writer> <[str]pattern> <[uint]count> => [str]
#
# Apaga N linha(s) anteriores ao padrão casado (inclusive).
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# pattern  - Sequência de caracteres que determina o padrão a casar. 
#            Suporta ERE (Expressão Regular Estendida).
# count    - Total de linhas a serem removidas.
#
# Obs: O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.delbline
{
	getopt.parse 4 "filename:file:+:$1" "writer:bool:+:$2" "pattern:str:+:$3" "count:uint:+:$4" "${@:5}"
	
	local line tmp bl ln

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	
	while read line; do
		((++ln))
		bl+=("$line")
		if [[ $ln -le $4 && $line =~ $3 ]]; then
			tl=$((${#bl[@]}-$4))
			[[ $tl -lt 0 ]] && tl=$((${#bl[@]}-1))
			bl=("${bl[@]:0:$tl}")
			ln=0
		elif [[ $ln -ge $4 ]]; then
			ln=0
		fi
	done < "$1"
	
	printf '%s\n' "${bl[@]}" > "$tmp"

	[[ $2 == false ]] && cat "$tmp" || io.__write_file "$tmp" "$1"

	return $?
}

# func io.delaline <[file]filename> <[bool]writer> <[str]pattern> <[uint]count> => [str]
#
# Apaga N linha(s) posteriores ao padrão casado (inclusive).
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# pattern  - Sequência de caracteres que determina o padrão a casar. 
#            Suporta ERE (Expressão Regular Estendida).
# count    - Total de linhas a serem removidas.
#
# Obs: O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.delaline()
{
	getopt.parse 4 "filename:file:+:$1" "writer:bool:+:$2" "pattern:str:+:$3" "count:uint:+:$4" "${@:5}"
	
	local line cc ln

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)

	while read line; do
		[[ $cc ]] && ((++ln))
		if [[ $line =~ $3 ]]; then cc=1
		elif [[ ! $cc && $ln -le $4 ]]; then echo -e "$line"
		elif [[ $ln -gt $4 ]]; then ln=0; cc=''
		fi
	done < "$1" >> "$tmp"
	
	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
}

# func io.delfline <[file]filename> <[bool]writer> <[uint]count> => [str]
#
# Apaga as primeiras N linhas.
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# count    - Total de linhas a serem apagadas.
#
# Obs: O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.delfline()
{
	getopt.parse 3 "filename:file:+:$1" "writer:bool:+:$2" "count:uint:+:$3" "${@:4}"

	local line ln tmp
	
	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)

	while read line; do
		[[ $((++ln)) -le $3 ]] || echo -e "$line"	
	done < "$1" >> "$tmp"

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?

}

# func io.dellline <[file]filename> <[bool]writer> <[uint]count> => [str]
#
# Apaga as últimas N linhas.
#
# filename - Caminho completo do arquivo.
# writer   - Gravar alterações no arquivo.
# count    - Total de linhas a serem apagadas.
#
# Obs: O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.dellline()
{
	getopt.parse 3 "filename:file:+:$1" "writer:bool:+:$2" "count:uint:+:$3" "${@:4}"

	local line ln tl tmp
	
	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)

	while read _; do ((++tl)); done < "$1"
	[[ $3 -ge $tl ]] && return 0
	tl=$((tl-$3))

	while read line; do
		[[ $((++ln)) -gt $tl ]] && break
		echo -e "$line"
	done < "$1" >> "$tmp"

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?

}

# func io.insline <[file]filename> <[bool]writer> <[str]pattern> <[str]expression> <[bool]invert> => [str]
#
# Insere uma expressão antes das linhas que contém o padrão casado.
#
# filename   - Caminho completo do arquivo.
# writer     - Gravar alterações no arquivo.
# pattern  -   Sequência de caracteres que determina o padrão a casar. 
#              Suporta ERE (Expressão Regular Estendida).
# expression - Uma sequẽncia de caracteres.
# invert     - Inverter seleção.
#
# Obs: O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.insline()
{
	getopt.parse 5 "filename:file:+:$1" "writer:bool:+:$2" "pattern:str:+:$3" "expression:str:+:$4" "invert:bool:+:$5" "${@:6}"
	
	local line tmp 

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	
	while read line; do
		if [[ $5 == false ]]; then
			[[ $line =~ $3 ]] && echo -e "$4"
		else
			[[ $line =~ $3 ]] || echo -e "$4"
		fi
		echo -e "$line"
	done < "$1" >> "$tmp"

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
}

# func io.insnline <[file]filename> <[bool]writer> <[str]expression> <[uint]lineno> ... => [str]
#
# Insere uma expressão antes da(s) linha(s) especificada(s).
#
# filename   - Caminho completo do arquivo.
# writer     - Gravar alterações no arquivo.
# expression - Uma sequẽncia de caracteres.
# lineno     - Número da linha.
#
# Obs: Pode ser especificada uma ou mais linhas.
#      O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.insnline()
{
	getopt.parse -1 "filename:file:+:$1" "writer:bool:+:$2" "expression:str:+:$3" "lineno:uint:+:$4"  ... "${@:5}"
	
	local line ln tmp nums

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	nums=${@:4}

	while read line; do
		((++ln))
		[[ $ln == @(${nums// /|}) ]] && echo -e "$3"
		echo -e "$line"
	done < "$1" >> "$tmp"

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
}

# func io.appline <[file]filename> <[bool]writer> <[str]pattern> <[str]expression> <[bool]invert> => [str]
#
# Insere uma expressão após as linhas que contém o padrão casado.
#
# filename   - Caminho completo do arquivo.
# writer     - Gravar alterações no arquivo.
# pattern    - Sequência de caracteres que determina o padrão a casar. 
#              Suporta ERE (Expressão Regular Estendida).
# expression - Uma sequẽncia de caracteres.
# invert     - Inverter seleção.
#
# Obs: O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.appline
{
	getopt.parse 5 "filename:file:+:$1" "writer:bool:+:$2" "pattern:str:+:$3" "expression:str:+:$4" "invert:bool:+:$5" "${@:6}"
	
	local line tmp 

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	
	while read line; do
		echo -e "$line"
		if [[ $5 == false ]]; then
			[[ $line =~ $3 ]] && echo -e "$4"
		else
			[[ $line =~ $3 ]] || echo -e "$4"
		fi
	done < "$1" >> "$tmp"

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
}

# func io.appnline <[file]filename> <[bool]writer> <[str]expression> <[uint]lineno> ... => [str]
#
# Insere uma expressão após a(s) linha(s) especificada(s).
#
# filename   - Caminho completo do arquivo.
# writer     - Gravar alterações no arquivo.
# expression - Uma sequẽncia de caracteres.
# lineno     - Número da linha.
#
# Obs: Pode ser especificada uma ou mais linhas.
#      O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.appnline()
{
	getopt.parse -1 "filename:file:+:$1" "writer:bool:+:$2" "expression:str:+:$3" "lineno:uint:+:$4"  ... "${@:5}"
	
	local line ln tmp nums

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	nums=${@:4}

	while read line; do
		((++ln))
		echo -e "$line"
		[[ $ln == @(${nums// /|}) ]] && echo -e "$3"
	done < "$1" >> "$tmp"

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
}

# func io.chline <[file]filename> <[bool]writer> <[str]pattern> <[str]expression> <[bool]invert> => [str]
#
# Substitui a linha contendo o padrão casado pela expressão especificada.
#
# filename   - Caminho completo do arquivo.
# writer     - Gravar alterações no arquivo.
# pattern    - Sequência de caracteres que determina o padrão a casar. 
#              Suporta ERE (Expressão Regular Estendida).
# expression - Uma sequẽncia de caracteres.
# invert     - Inverter seleção.
#
# Obs: O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.chline()
{
	getopt.parse 5 "filename:file:+:$1" "writer:bool:+:$2" "pattern:str:+:$3" "expression:str:+:$4" "invert:bool:+:$5" "${@:6}"
	
	local line tmp 

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	
	while read line; do
		if [[ $5 == false ]]; then
			[[ $line =~ $3 ]] && echo -e "$4"
		else
			[[ ! $line =~ $3 ]] && echo -e "$4"
		fi || echo -e "$line"
	done < "$1" >> "$tmp"

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
}

# func io.chline <[file]filename> <[bool]writer> <[str]expression> <[uint]lineno> ... => [str]
#
# Substitui N linhas pela expressão especificada.
#
# filename   - Caminho completo do arquivo.
# writer     - Gravar alterações no arquivo.
# expression - Uma sequẽncia de caracteres.
# lineno     - Número da linha.
#
# Obs: Pode ser especificada uma ou mais linhas.
#      O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.chnline()
{
	getopt.parse -1 "filename:file:+:$1" "writer:bool:+:$2" "expression:str:+:$3" "lineno:uint:+:$4"  ... "${@:5}"
	
	local line ln tmp nums

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	nums=${@:4}

	while read line; do
		((++ln))
		[[ $ln == @(${nums// /|}) ]] && echo -e "$3" || echo -e "$line"
	done < "$1" >> "$tmp"

	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
}

# func io.cpnline <[file]filename> <[bool]writer> <[uint]from_lineno> <[bool]append> <[uint]to_lineno> ... => [str]
#
# Copia N linha origem para N's linha(s) destino.
#
# filename    - Caminho completo do arquivo.
# writer      - Gravar alterações no arquivo.
# from_lineno - Linha origem.
# append      - Anexar cópia. 
#		true:  Anexa a linha copiada após a linha destino.
#		false: Sobrescreve a linha destino.
# to_lineno   - Linha(s) destino.
#               
# Obs: Pode ser especificada uma ou mais linhas. (to_lineno)
#      O retorno da função é omitido caso 'writer' seja igual à 'true'.
#
function io.cpnline()
{
	getopt.parse -1 "filename:file:+:$1" "writer:bool:+:$2" "from_lineno:uint:+:$3" "append:bool:+:$4" "to_lineno:uint:+:$5" ... "${@:6}"

	local tmp nums line ln cpln

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io)
	nums=${@:5}
	
	while read line; do
		if [[ $((++ln)) -eq $3 ]]; then
			cpln=$line
			break
		fi
	done < "$1"

	ln=0

	while read line; do
		((++ln))
		if [[ $ln == @(${nums// /|}) ]]; then	[[ $4 == true ]] && printf '%s\n' "$line" "$cpln" || echo -e "$cpln"
		else					echo -e "$line"
		fi
	done < "$1" >> "$tmp"
		
	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
	
}

# func io.cpline <[file]filename> <[bool]writer> <[str]from_pattern> <[bool]from_invert> <[str]to_pattern> <[bool]to_invert> <[bool]append> => [str]
#
# Copia as linhas que contém o padrão casado de origem para a(s) linha(s) que contém o padrão destino.
# Se mais de um padrão de origem for encontrado, é criada uma pilha de agrupamento anexando a linha
# casada ao final da pilha.
#
# filename     - Caminho completo do arquivo.
# writer       - Gravar alterações no arquivo.
# from_pattern - Padrão de origem.
# from_invert  - Inverte seleção de origem.
# to_pattern   - Padrão de destino.
# to_invert    - Inverte seleção de destino.
# append      - Anexar cópia. 
#		true:  Anexa a linha copiada após a linha destino.
#		false: Sobrescreve a linha destino.
# 
function io.cpline()
{
	getopt.parse 7 "filename:file:+:$1" "writer:bool:+:$2" "from_pattern:str:+:$3" "from_invert:bool:+:$4" "to_pattern:str:+:$5" "to_invert:bool:+:$6" "append:bool:+:$7" "${@:8}"

	local time tmp match

	tmp=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.io) || return $?

	while read line; do
		if [[ $4 == false ]]; then	[[ $line =~ $3 ]] && match+=("$line")
		else				[[ $line =~ $3 ]] || match+=("$line")
		fi

		if [[ $6 == false ]]; then
			if [[ $line =~ $5 ]]; then	[[ $7 == true ]] && printf '%s\n' "$line" "${match[@]}" || printf '%s\n' "${match[@]}"
			else				echo -e "$line"
			fi
		else
			if ! [[ $line =~ $5 ]]; then	[[ $7 == true ]] && printf '%s\n' "$line" "${match[@]}" || printf '%s\n' "${match[@]}"
			else				echo -e "$line"	
			fi
		fi
	done < "$1" >> "$tmp"
	
	[[ $2 == false ]] && cat $tmp || io.__write_file "$tmp" "$1"

	return $?
}

function io.__write_file()
{
	trap "rm -f '$1'" SIGINT SIGTERM RETURN

	if ! cat "$1" > "$2" 2>/dev/null; then
		error.format 1 "falha ao gravar as alterações no arquivo '%s'" "$2"
		return $?
	fi

	return $?
}

source.__INIT__
# /* __IO_SH  */
