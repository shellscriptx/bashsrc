#!/bin/bash

#----------------------------------------------#
# Source:           socket.sh
# Data:             5 de dezembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__SOCKET_SH ]] && return 0

readonly __SOCKET_SH=1

source builtin.sh

socket.gethostname()
{
	getopt.parse 0 ${@:1}
	echo "$HOSTNAME"
	return 0
}

socket.getfqdn()
{
	getopt.parse 0 ${@:1}

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
