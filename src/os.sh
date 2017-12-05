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

os.gethostname(){ echo "$HOSTNAME"; return 0; }

os.getfqdn()
{
	local ip hosts host name

	if [[ -e /etc/hosts ]]; then
		while read ip host; do
			if [[ "$ip" == "127.0.1.1" ]]; then
				hosts=($host)
				for name in ${hosts[@]}; do
					echo "$name"
				done				
			fi
		done < /etc/hosts
	fi

	return $?
}
