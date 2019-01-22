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
[[ $__TEXTUTIL_SH ]] && return 0

readonly __TEXTUTIL_SH=1

source builtin.sh
source struct.sh

source textutil.fonts

readonly __C_ESC='\x1b'

readonly AT_RESET=0
readonly AT_BOLD=1
readonly AT_DIM=2
readonly AT_SMSO=3
readonly AT_UNDER=4
readonly AT_BLINK=5
readonly AT_REVERSE=7
readonly AT_HIDDEN=8

readonly FG_BLACK=30
readonly FG_RED=31
readonly FG_GREEN=32
readonly FG_YELLOW=33
readonly FG_BLUE=34
readonly FG_MAGENTA=35
readonly FG_CYAN=36
readonly FG_WHITE=37

readonly BG_BLACK=40
readonly BG_RED=41
readonly BG_GREEN=42
readonly BG_YELLOW=43
readonly BG_BLUE=44
readonly BG_MAGENTA=45
readonly BG_CYAN=46
readonly BG_WHITE=47

__TYPE__[textutil_t]='
textutil.text
textutil.align
textutil.index
textutil.label
'

var color_t struct_t
var text_t struct_t
var pos_t struct_t
var label_t struct_t

pos_t.__add__ \
	x	uint \
	y	uint

color_t.__add__ \
	fg	uint \
	bg	uint

text_t.__add__ \
	text	str \
	align	flag \
	attr	uint \
	color	color_t \
	pos		pos_t

label_t.__add__ \
	text	str \
	font	flag \
	mode	flag \
	align	flag \
	color	color_t

# func textutil.text <[str]text> <[flag]align> <[uint]foreground> <[uint]background> <[uint]attr> => [str]
#
# Retorna 'text' aplicando os atributos especificados.
#
# align - alinhamento do texto. (left, center ou right)
# fg    - cor do primeiro plano. (constantes 'FG_*')
# bg    - cor de fundo. (constantes 'BG_*')
# attr  - atributo do texto. (constantes 'AT_*')
#
function textutil.text()
{
	getopt.parse 5 "text:str:-:$1" "align:flag:+:$2" "foreground:uint:+:$3" "background:uint:+:$4" "attr:uint:+:$5" "${@:6}"
	
	echo -en "${__C_ESC}[${5};${4};${3}m"
	textutil.align "$1" "$2"	
	echo -en "${__C_ESC}[0;m"

	return 0
}

# func textutil.label <[str]text> <[flag]font> <[flag]mode> <[flag]align> <[uint]foreground> <[uint]background> = [str]
#
# Converte o texto em um label com os atributos especificados.
#
# font - fonte do texto.
# mode - modo de exibição do label. (normal, iris, random)
# align - alinhamento do texto. (left, center ou right)
# foreground - cor do primeiro plano. (constantes FG_*)
# backgorund - cor do segundo plano. (constantes BG_*)
#
# Se 'mode' for igual à 'iris' a cor definida em 'foreground' é ignorada.
#
# Fonts: mini, banner, big, block, bubble, digital, lean, standard, smslant
# smshadow, smscript, small, slant, shadow, script
#
function textutil.label()
{
	getopt.parse 6 "text:str:-:$1" "font:flag:+:$2" "mode:flag:+:$3" "align:flag:+:$4" "foreground:uint:+:$5" "background:uint:+:$6" "${@:7}"

	local i ch asc line spc cols c fg

	if ! [[ ${__FONT_SIZE[$2]} ]]; then
		error.trace def 'font' 'flag' "$2" 'fonte não encontrada'
		return $?
	fi

	IFS=' ' read _ cols < <(stty size)

	for ((c=30, i=0; i<${__FONT_SIZE[$2]}; i++, c++)); do
		
		while read -n1 ch; do
			printf -v asc '%d' \'"${ch:- }"
			line+=${__FONT[$2:$asc:$i]}
		done <<< "$1"
		
		case $3 in
			iris) ((c > 37)) && c=30; fg=$c;;
			random) fg=$(((RANDOM%8)+30));;
			normal) fg=$5;;
			*) error.trace def 'mode' 'flag' "$3" 'flag inválida'; return $?;;
		esac
		
		case $4 in
			center)	spc=$(((cols/2)+(${#line}/2)+1));;
			right) spc=$cols;;
			left) spc=0;;
			*) error.trace def 'align' 'flag' "$2" 'flag inválida'; return $?;;
		esac

		echo -en "${__C_ESC}[${6};${fg}m"
		printf '%*s\n' $spc "$line"

		line=''
	done

	echo -en "${__C_ESC}[0;m"

	return 0
}

# func textutil.align <[str]text> <[flag]align> => [str]
#
# Exibe 'text' aplicando o alinhamento especificado.
#
# Flag    Descrição
#
# left    alinhado à esquerda.
# center  centralizado.
# right   alinhado à direita.
#
function textutil.align()
{
	getopt.parse 2 "text:str:-:$1" "align:flag:+:$2" "${@:3}"

	local cols line spc

	read _ cols < <(stty size)

	while read line; do
		case $2 in
			center) spc=$(((cols/2)+(${#line}/2)+1));;
			right) spc=$cols;;
			left) spc=0;;
			*) error.trace def 'align' 'flag' "$2" 'flag inválida'; return $?;;
		esac	
		printf '%*s\n' $spc "${line}"
	done <<< "$1"

	return 0
}

# func textutil.tlabel <[label_t]labelopt> => [str]
#
# Covnerte a estrutura apontada por 'labelopt' em um label.
#
function textutil.tlabel()
{
	getopt.parse 1 "labelopt:label_t:+:$1" "${@:2}"
	textutil.label "$($1.text)" "$($1.font)" "$($1.mode)" "$($1.align)" "$($1.color.fg)" "$($1.color.bg)"
	return $?
}

# func textutil.ttext <[text_t]textopt> => [str]
#
# Retorna a estrutura apontada por 'textopt' aplicando os atributos definidos.
#
function textutil.ttext()
{
	getopt.parse 1 "textopt:text_t:+:$1" "${@:2}"

	echo -en "${__C_ESC}[$($1.pos.y);$($1.pos.x)H${__C_ESC}[$($1.attr);$($1.color.bg);$($1.color.fg)m"
	textutil.align "$($1.text)" "$($1.align)"
	echo -en "${__C_ESC}[0;m"
	
	return 0
}

# func textutil.index <[str]list> <[uint]len> <[int]start> => [str]
#
# Retorna uma lista iterável com os elementos de 'list' no formato de índice,
# iniciando a partir do índice 'start' com o comprimento do campo para 'len' dígitos.
# 
function textutil.index()
{
	getopt.parse 3 "list:str:-:$1" "len:uint:+:$2" "start:int:+:$3" "${@:4}"
	
	local i dot line cols

	i=$3

	IFS=' ' read _ cols < <(stty size)

	while read line; do
		printf -v dot '%*s' $(((cols-${#line})-($2+2)))
		printf "%s%$(($2+1))d\n" "${line} ${dot// /.}" "$i"
		((i++))
	done <<< "$1"
	
	return 0	
}

# func textutil.color <[uint]foreground> <[uint]background>
#
# Define a paleta de cores. (constantes 'FG_*' e 'BG_*')
#
function textutil.color()
{
	getopt.parse 2 "foreground:uint:+:$1" "background:uint:+:$2" "${@:3}"

	echo -en "${__C_ESC}[${2};${1}m"
	return 0
}

# func textutil.attr <[uint]attr>
#
# Define os atributos do texto. (constantes 'AT_*')
#
function textutil.attr()
{
	getopt.parse 1 "attr:uint:+:$1" "${@:2}"
	
	echo -en "${__C_ESC}[$1m"
	return 0
}

# func textutil.gotoxy <[uint]x> <[uint]>y>
#
# Posiciona o cursor nas coordenadas 'x' e 'y'.
#
function textutil.gotoxy()
{
	getopt.parse 2 "x:uint:+:$1" "y:uint:+:$2" "${@:3}"
	
	echo -en "${__C_ESC}[${2};${1}H"
	return 0
}

# func textutil.hcpos
#
# Posiciona o cursor na coordenada inicial '0 0'
#
function textutil.hcpos()
{
	getopt.parse 0 "$@"
	
	echo -en "${__C_ESC}[H"
	return 0
}

# func textutil.scpos
#
# Salva a posição do cursor.
#
function textutil.scpos()
{
	getopt.parse 0 "$@"

	echo -ne "${__C_ESC}7"
	return 0
}

# func textutil.rcpos
#
# Restaura a posição do cursor.
#
function textutil.rcpos()
{
	getopt.parse 0 "$@"

	echo -en "${__C_ESC}8"
	return 0
}

# func textutil.cursor <[bool]enabled>
#
# Habilita/desabilita a exibição do cursor.
#
function textutil.cursor()
{
	getopt.parse 1 "status:bool:+:$1" "${@:2}"

	local def
	[[ $1 == true ]] && def="${__C_ESC}[?25h" || def="${__C_ESC}[?25l"
	echo -en "$def"

	return 0
}

# func textutil.clrctoe
#
# Limpa partir da posição atual do cursor até o final da linha.
#
function textutil.clrctoe()
{
	getopt.parse 0 "$@"

	echo -en "${__C_ESC}[K"
	return 0
}

# func textutil.clrbtoc
#
# Limpa do inicio da linha até a posição atual do cursor.
#
function textutil.clrbtoc()
{
	getopt.parse 0 "$@"

	echo -en "${__C_ESC}[1K"
	return 0
}

# func textutil.clrc
#
# Limpa a posição atual do cursor.
#
function textutil.clrc()
{
	getopt.parse 0 "$@"

	echo -en "${__C_ESC}[2K"
	return 0
}

# func textutil.getpos <[pos_t]buf>
#
# Salva na estrutura apontada por 'buf' as coordenadas do cursor.
#
function textutil.getpos()
{
	getopt.parse 1 "buf:pos_t:+:$1" "${@:2}"

	local pos x y
	
	echo -en "${__C_ESC}[6n"
	read -sd R pos

	pos=${pos#*[}
	x=${pos#*;}
	y=${pos%;*}
	
	$1.x = "$x"
	$1.y = "$y"

	return 0
}

source.__INIT__
# /* __TEXTUTIL_SH */
