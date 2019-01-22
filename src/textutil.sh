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
#

[ -v __TEXTUTIL_SH__ ] && return 0

readonly __TEXTUTIL_SH__=1

source builtin.sh
source struct.sh
source textutil.fonts

# .FUNCTION textutil.fonts -> [str]|[bool]
#
# Retorna as fontes disponíveis.
#
function textutil.fonts()
{
	getopt.parse 0 "$@"
	printf '%s\n' "${!__FONT_SIZE__[@]}"
	return $?
}

# .FUNCTION textutil.text <text[str]> <align[uint]> <foreground[uint]> <background[uint]> <attr[uint]> => [str]|[bool]
#
# Imprime o texto com os atributos especificados.
#
function textutil.text()
{
	getopt.parse 5 "text:str:$1" "align:uint:$2" "foreground:uint:$3" "background:uint:$4" "attr:uint:$5" "${@:6}"
	
	echo -en "${__C_ESC__}[${5};${4};${3}m"
	textutil.align "$1" "$2"	
	echo -en "${__C_ESC__}[0;m"

	return $?
}

# .FUNCTION textutil.label <text[str]> <font[str]> <mode[uint]> <align[uint]> <foreground[uint]> <background[uint]> = [str]|[bool]
#
# Imprime um label com os atributos especificados.
#
function textutil.label()
{
	getopt.parse 6 "text:str:$1" "font:str:$2" "mode:uint:$3" "align:uint:$4" "foreground:uint:$5" "background:uint:$6" "${@:7}"

	local i ch asc line spc cols c fg

	[ ! -v __FONT_SIZE__[$2] ] && error.fatal "'$2' fonte não encontrada"

	IFS=' ' read _ cols < <(stty size)

	for ((c=30, i=0; i<${__FONT_SIZE__[$2]}; i++, c++)); do
		
		while read -n1 ch; do
			printf -v asc '%d' \'"${ch:- }"
			line+=${__FONT__[$2:$asc:$i]}
		done <<< "$1"
		
		case $3 in
			1) ((c > 37)) && c=30; fg=$c;;
			2) fg=$(((RANDOM%8)+30));;
			*) fg=$5;;
		esac
		
		case $4 in
			1)	spc=$(((cols/2)+(${#line}/2)+1));;
			2) spc=$cols;;
			*) spc=0;;
		esac

		echo -en "${__C_ESC__}[${6};${fg}m"
		printf '%*s\n' $spc "$line"

		line=''
	done

	echo -en "${__C_ESC__}[0;m"

	return 0
}

# .FUNCTION textutil.align <text[str]> <align[uint]> -> [str]|[bool]
#
# Imprime o texto aplicando o alinhamento especificado.
#
function textutil.align()
{
	getopt.parse 2 "text:str:$1" "align:uint:$2" "${@:3}"

	local cols line spc

	read _ cols < <(stty size)

	while read line; do
		case $2 in
			1) spc=$(((cols/2)+(${#line}/2)+1));;
			2) spc=$cols;;
			*) spc=0;;
		esac	
		printf '%*s\n' $spc "${line}"
	done <<< "$1"

	return 0
}

# .FUNCTION textutil.showlabel <label[label_st]> -> [str]|[bool]
#
# Imprime o label com os atributos da estrutura.
#
function textutil.showlabel()
{
	getopt.parse 1 "label:label_st:$1" "${@:2}"
	
	local 	__text__=$($1.text) 	\
			__font__=$($1.font)		\
			__mode__=$($1.mode) 	\
			__align__=$($1.align)	\
			__cfg__=$($1.color.fg)	\
			__cbg__=$($1.color.bg)
	
	textutil.label 	"${__text__}" 		\
					"${__font__}" 		\
					"${__mode__:-0}" 	\
					"${__align__:-0}"	\
					"${__cfg__:-0}"		\
					"${__cbg__:-0}"
	
	return $?
}

# .FUNCTION textutil.showtext <text[text_st]> -> [str]|[bool]
#
# Imprime o texto com os atributos da estrutura.
#
function textutil.showtext()
{
	getopt.parse 1 "text:text_st:$1" "${@:2}"

	local 	__text__=$($1.text) 	\
			__align__=$($1.align)	\
			__attr__=$($1.attr)		\
			__cfg__=$($1.color.fg)	\
			__cbg__=$($1.color.bg)	\
			__posx__=$($1.pos.x)	\
			__posy__=$($1.pos.y)

	echo -en "${__C_ESC__}[${__posy__:-0};${__posx__:-0}H${__C_ESC__}[${__attr__:-0};${__cbg__:-0};${__cfg__:-0}m"
	textutil.align "${__text__}" "${__align__:-0}"
	echo -en "${__C_ESC__}[0;m"
	
	return 0
}

# .FUNCTION textutil.index <iterable[array]> <len[uint]> <start[int]> -> [str]|[bool]
#
# Retorna uma lista iterável dos elementos de 'list' no formato de índice,
# iniciando a partir do índice 'start' com o comprimento do campo para 'len' dígitos.
# 
function textutil.index()
{
	getopt.parse 3 "iterable:array:$1" "len:uint:$2" "start:int:$3" "${@:4}"

	local -n __ref__=$1
	local __i__ __dot__ __item__ __cols__

	__i__=$3

	IFS=' ' read _ __cols__ < <(stty size)

	for __item__ in "${__ref__[@]}"; do
		printf -v __dot__ '%*s' $(((__cols__-${#__item__})-($2+2)))
		printf "%s%$(($2+1))d\n" "${__item__} ${__dot__// /.}" "$__i__"
		((__i__++))
	done
	
	return $?
}

# .FUNCTION textutil.color <foreground[uint]> <background[uint]> -> [bool]
#
# Define a paleta de cores. (constantes 'FG_*' e 'BG_*')
#
function textutil.color()
{
	getopt.parse 2 "foreground:uint:$1" "background:uint:$2" "${@:3}"

	echo -en "${__C_ESC__}[${2};${1}m"
	return $?
}

# .FUNCTION textutil.attr <attr[uint]>
#
# Define os atributos do texto. (constantes 'AT_*')
#
function textutil.attr()
{
	getopt.parse 1 "attr:uint:$1" "${@:2}"
	
	echo -en "${__C_ESC__}[$1m"
	return $?
}

# .FUNCTION textutil.gotoxy <x[uint]> <y[uint]> -> [bool]
#
# Posiciona o cursor nas coordenadas 'x' e 'y'.
#
function textutil.gotoxy()
{
	getopt.parse 2 "x:uint:$1" "y:uint:$2" "${@:3}"
	
	echo -en "${__C_ESC__}[${2};${1}H"
	return $?
}

# .FUNCTION textutil.hcpos -> [bool]
#
# Posiciona o cursor na coordenada inicial 'x=0,y=0'.
#
function textutil.hcpos()
{
	getopt.parse 0 "$@"
	
	echo -en "${__C_ESC__}[H"
	return $?
}

# .FUNCTION textutil.scpos -> [bool]
#
# Salva a posição do cursor.
#
function textutil.scpos()
{
	getopt.parse 0 "$@"

	echo -ne "${__C_ESC__}7"
	return $?
}

# .FUNCTION textutil.rcpos -> [bool]
#
# Restaura a posição do cursor.
#
function textutil.rcpos()
{
	getopt.parse 0 "$@"

	echo -en "${__C_ESC__}8"
	return $?
}

# .FUNCTION textutil.cursor <enabled[bool]> -> [bool]
#
# Habilita/desabilita a exibição do cursor.
#
function textutil.cursor()
{
	getopt.parse 1 "status:bool:$1" "${@:2}"

	$1 && 	echo -en "${__C_ESC__}[?25h" || 
			echo -en "${__C_ESC__}[?25l"

	return $?
}

# .FUNCTION textutil.clrctoe -> [bool]
#
# Limpa partir da posição atual do cursor até o final da linha.
#
function textutil.clrctoe()
{
	getopt.parse 0 "$@"

	echo -en "${__C_ESC__}[K"
	return $?
}

# .FUNCTION textutil.clrbtoc -> [bool]
#
# Limpa do inicio da linha até a posição atual do cursor.
#
function textutil.clrbtoc()
{
	getopt.parse 0 "$@"

	echo -en "${__C_ESC__}[1K"
	return $?
}

# .FUNCTION textutil.clrc -> [bool]
#
# Limpa a posição atual do cursor.
#
function textutil.clrc()
{
	getopt.parse 0 "$@"

	echo -en "${__C_ESC__}[2K"
	return $?
}

# .FUNCTION textutil.curpos <curpos[map]> -> [bool]
#
# Obtém as coordenadas do cursor.
#
function textutil.curpos()
{
	getopt.parse 1 "curpos:map:$1" "${@:2}"
	
	local -n __ref__=$1
	local __pos__
	
	echo -en "${__C_ESC__}[6n"
	read -sd R __pos__

	__pos__=${__pos__#*[}
	__ref__[x]=${__pos__#*;}
	__ref__[y]=${__pos__%;*}
	
	return $?
}

readonly __C_ESC__='\x1b'

# .MAP curpos
#
# Chaves:
#
# x
# y
#

# .CONST AT_
#
# AT_RESET
# AT_BOLD
# AT_DIM
# AT_SMSO
# AT_UNDER
# AT_BLINK
# AT_REVERSE
# AT_HIDDEN
#
readonly AT_RESET=0
readonly AT_BOLD=1
readonly AT_DIM=2
readonly AT_SMSO=3
readonly AT_UNDER=4
readonly AT_BLINK=5
readonly AT_REVERSE=7
readonly AT_HIDDEN=8

# .CONST FG_
#
# FG_BLACK
# FG_RED
# FG_GREEN
# FG_YELLOW
# FG_BLUE
# FG_MAGENTA
# FG_CYAN
# FG_WHITE
#
readonly FG_BLACK=30
readonly FG_RED=31
readonly FG_GREEN=32
readonly FG_YELLOW=33
readonly FG_BLUE=34
readonly FG_MAGENTA=35
readonly FG_CYAN=36
readonly FG_WHITE=37

# .CONST BG_
#
# BG_BLACK
# BG_RED
# BG_GREEN
# BG_YELLOW
# BG_BLUE
# BG_MAGENTA
# BG_CYAN
# BG_WHITE
#
readonly BG_BLACK=40
readonly BG_RED=41
readonly BG_GREEN=42
readonly BG_YELLOW=43
readonly BG_BLUE=44
readonly BG_MAGENTA=45
readonly BG_CYAN=46
readonly BG_WHITE=47

# .CONST TA_
#
# TA_LEFT
# TA_CENTER
# TA_RIGHT
#
readonly TA_LEFT=0
readonly TA_CENTER=1
readonly TA_RIGHT=2

# .CONST VM_
#
# VM_NORMAL
# VM_IRIS
# VM_RANDOM
#
readonly VM_NORMAL=0
readonly VM_IRIS=1
readonly VM_RANDOM=2

# Estruturas
var color_st struct_t
var text_st struct_t
var pos_st struct_t
var label_st struct_t

# .STRUCT pos_st
#
# Implementa o objeto 'S' com os membros:
#
# S.x    [uint]
# S.y    [uint]
#
pos_st.__add__ 	x	uint \
				y 	uint

# .STRUCT color_st
#
# Implementa o objeto 'S' com os membros:
#
# S.fg    [uint]
# S.bg    [uint]
#
color_st.__add__ 	fg	uint \
					bg	uint

# .STRUCT text_st
#
# Implementa o objeto 'S' com os membros:
#
# S.text     [str]
# S.align    [uint]
# S.attr     [uint]
# S.color    [color_st]
# S.pos      [pos_st]
#
text_st.__add__		text	str			\
					align	uint 		\
					attr	uint 		\
					color	color_st 	\
					pos		pos_st

# .STRUCT label_st
#
# Implementa o objeto 'S' com os membros:
#
# S.text     [str]
# S.font     [str]
# S.mode     [uint]
# S.align    [uint]
# S.color    [color_st]
#
label_st.__add__	text	str 		\
					font	str 		\
					mode	uint 		\
					align	uint 		\
					color	color_st

# .TYPE textutil_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.text
# S.align
# S.index
# S.label
#
typedef textutil_t	textutil.text 	\
					textutil.align	\
					textutil.index	\
					textutil.label

# Funções (somente-leitura)
readonly -f textutil.fonts		\
			textutil.text		\
			textutil.label		\
			textutil.align		\
			textutil.showlabel	\
			textutil.showtext	\
			textutil.index		\
			textutil.color		\
			textutil.attr		\
			textutil.gotoxy		\
			textutil.hcpos		\
			textutil.scpos		\
			textutil.rcpos		\
			textutil.cursor		\
			textutil.clrctoe	\
			textutil.clrbtoc	\
			textutil.clrc		\
			textutil.curpos

# /* __TEXTUTIL_SH__ */
