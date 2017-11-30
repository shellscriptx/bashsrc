#!/bin/bash

#----------------------------------------------#
# Source:           os.sh
# Data:             29 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__OS_SH ]] && return 0

readonly __OS_SH=1

source builtin.sh

readonly __HOSTNAME_FILE=/etc/hostname

# access
readonly F_OK=0
readonly X_OK=1
readonly W_OK=2
readonly R_OK=4

function os.hostname()
{
	getopt.parse "-:null:-:$*"
	[[ -e $__HOSTNAME_FILE ]] && echo $(< $__HOSTNAME_FILE)
	return 0
}

function os.access()
{
	getopt.parse "filename:str:+:$1" "flags:int:+:$2"
	
	local file=$1

	if [[ -e $file ]]; then
		:
	else
		:
	fi
}
