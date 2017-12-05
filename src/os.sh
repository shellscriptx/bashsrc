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

os.hostname(){ echo "$HOSTNAME"; return 0; }
