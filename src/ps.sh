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

[ -v __PS_SH__ ] && return 0

readonly __PS_SH__=1

source builtin.sh

# .FUNCTION ps.pids -> [uint]|[bool]
#
# Retorna uma lista iterável com o pid dos processos em execução.
#
function ps.pids()
{
	getopt.parse 0 "$@"
	
	local pid

	for pid in /proc/*; do
		pid=${pid##*/}
		[[ $pid == +([0-9]) ]] && 
		echo $pid
	done | sort -n

	return $?
}

# .FUNCTION ps.pidof <procname[str]> -> [uint]|[bool]
#
# Retorna o ID do processo do programa em execução.
#
function ps.pidof()
{
	getopt.parse 1 "procname:str:$1" "${@:2}"
	
	local pid exe

	for pid in $(ps.pids); do
		exe=$(readlink /proc/$pid/exe)
		[ "$1" == "${exe##*/}" ] 	&& 
		echo $pid 					&& 
		break
	done

	return $?
}

# .FUNCTION ps.stats <pid[uint]> <stats[map]> -> [bool]
#
# Obtém estatísticas do ID do processo.
#
# == EXEMPLO ==
#
# #!/bin/bash
#
# source ps.sh
#
# # Inicializa o mapa.
# declare -A stat=()
#
# var pid pspid_t     # Implementa os métodos do tipo 'pspid_t'
#
# # Obtém o ID do processo.
# pid=$(ps.pidof 'Telegram')
#
# # Salva em 'stat' as estatísticas do processo.
# pid.stats stat
#
# # Informações.
# echo "Processo:" ${stat[comm]}
# echo "PID:" ${stat[pid]}
# echo "Threads:" ${stat[num_threads]}
# echo "Prioridade:" ${stat[priority]}
#
# == SAÍDA ==
#
# Processo: Telegram
# PID: 2545
# Threads: 12
# Prioridade: 20
#
function ps.stats()
{
	getopt.parse 2 "pid:uint:$1" "stats:map:$2" "${@:3}"

	local __exe__ __stat__
	local -n __ref__=$2
	
	ps.__cpid__ $1 	&&
	__ref__=() 		|| return 1
	
	__exe__=$(readlink  /proc/$1/exe)
	IFS=' ' read -a __stat__ < /proc/$1/stat

	__ref__[pid]=$1
	__ref__[comm]=${__exe__##*/}
	__ref__[state]=${__stat__[-50]}
	__ref__[ppid]=${__stat__[-49]}
	__ref__[pgrp]=${__stat__[-48]}
	__ref__[session]=${__stat__[-47]}
	__ref__[tty_nr]=${__stat__[-46]}
	__ref__[tpgid]=${__stat__[-45]}
	__ref__[flags]=${__stat__[-44]}
	__ref__[minflt]=${__stat__[-43]}
	__ref__[cminflt]=${__stat__[-42]}
	__ref__[majflt]=${__stat__[-41]}
	__ref__[cmajflt]=${__stat__[-40]}
	__ref__[utime]=${__stat__[-39]}
	__ref__[stime]=${__stat__[-38]}
	__ref__[cutime]=${__stat__[-37]}
	__ref__[cstime]=${__stat__[-36]}
	__ref__[priority]=${__stat__[-35]}
	__ref__[nice]=${__stat__[-34]}
	__ref__[num_threads]=${__stat__[-33]}
	__ref__[itrealvalue]=${__stat__[-32]}
	__ref__[starttime]=${__stat__[-31]}
	__ref__[vsize]=${__stat__[-30]}
	__ref__[rss]=${__stat__[-29]}
	__ref__[rsslim]=${__stat__[-28]}
	__ref__[startcode]=${__stat__[-27]}
	__ref__[endcode]=${__stat__[-26]}
	__ref__[startstack]=${__stat__[-25]}
	__ref__[kstkesp]=${__stat__[-24]}
	__ref__[kstkeip]=${__stat__[-23]}
	__ref__[signal]=${__stat__[-22]}
	__ref__[blocked]=${__stat__[-21]}
	__ref__[sigignore]=${__stat__[-20]}
	__ref__[sigcatch]=${__stat__[-19]}
	__ref__[wchan]=${__stat__[-18]}
	__ref__[nswap]=${__stat__[-17]}
	__ref__[cnswap]=${__stat__[-16]}
	__ref__[exit_signal]=${__stat__[-15]}
	__ref__[processor]=${__stat__[-14]}
	__ref__[rt_priority]=${__stat__[-13]}
	__ref__[policy]=${__stat__[-12]}
	__ref__[delayacct_blkio_ticks]=${__stat__[-11]}
	__ref__[guest_time]=${__stat__[-10]}
	__ref__[cguest_time]=${__stat__[-9]}
	__ref__[start_data]=${__stat__[-8]}
	__ref__[end_data]=${__stat__[-7]}
	__ref__[start_brk]=${__stat__[-6]}
	__ref__[arg_start]=${__stat__[-5]}
	__ref__[arg_end]=${__stat__[-4]}
	__ref__[env_start]=${__stat__[-3]}
	__ref__[env_end]=${__stat__[-2]}
	__ref__[exit_code]=${__stat__[-1]}

	return $?
}

# .FUNCTION ps.mem <pid[uint]> <meminfo[map]> -> [bool]
#
# Obtém informações sobre o uso da memória pelo ID do processo.
#
function ps.mem()
{
	getopt.parse 2 "pid:uint:$1" "meminfo:map:$2" "${@:3}"
	
	local __size__
	local -n __ref__=$2

	ps.__cpid__ $1	&&
	__ref__=()		|| return 1
	
	IFS=' ' read -a __size__ < /proc/$1/statm
	
	__ref__[size]=${__size__[0]}
	__ref__[resident]=${__size__[1]}
	__ref__[share]=${__size__[2]}
	__ref__[text]=${__size__[3]}
	__ref__[lib]=${__size__[4]}
	__ref__[data]=${__size__[5]}
	__ref__[dt]=${__size__[6]}

	return $?	
}

# .FUNCTION ps.io <pid[uint]> <io[map]> -> [bool]
#
# Obtém estatísticas I/O do ID do processo.
#
function ps.io()
{
	getopt.parse 2 "pid:uint:$1" "io:map:$2" "${@:3}"
	
	local __flag__ __size__
	local -n __ref__=$2
	
	ps.__cpid__ $1	&&
	__ref__=()		|| return 1
	
	while IFS=':' read __flag__ __size__; do
		__ref__[${__flag__,,}]=$__size__
	done < /proc/$1/io

	return $?
}

# .FUNCTION ps.info <pid[uint]> <info[map]> -> [bool]
#
# Lê as informações associadas ao ID do processo.
#
# Inicializa o mapa 'S' com as chaves:
#
# S[tty]
# S[time]
# S[user]
# S[start]
# S[vsz]
# S[mem]
# S[pid]
# S[rss]
# S[state]
# S[cmd]
# S[cpu]
#
function ps.info()
{
	getopt.parse 2 "pid:uint:$1" "info:map:$2" "${@:3}"
	
	local __info__
	local -n __ref__=$2
	
	ps.__cpid__ $1	&&
	__ref__=()		|| return 1
	
	mapfile __info__ < <(ps -q $1 -o user,pid,%cpu,%mem,vsz,rss,tty,state,start,time,cmd)
	IFS=' ' read -a __info__ <<< ${__info__[-1]}

	__ref__[user]=${__info__[0]}
	__ref__[pid]=${__info__[1]}
	__ref__[cpu]=${__info__[2]}
	__ref__[mem]=${__info__[3]}
	__ref__[vsz]=${__info__[4]}
	__ref__[rss]=${__info__[5]}
	__ref__[tty]=${__info__[6]}
	__ref__[state]=${__info__[7]}
	__ref__[start]=${__info__[8]}
	__ref__[time]=${__info__[9]}
	__ref__[cmd]=${__info__[*]:10}
	
	return $?
}

function ps.__cpid__()
{
	[ -e /proc/$1 ] || error.error "'$1' pid do processo não encontrado"
	return $?
}

# .MAP stats
#
# Chaves:
#
# flags
# start_brk
# wchan
# guest_time
# processor
# sigcatch
# cutime
# priority
# cnswap
# exit_signal
# nice
# tty_nr
# kstkeip
# cstime
# cminflt
# nswap
# ppid
# comm
# sigignore
# pgrp
# majflt
# blocked
# arg_start
# signal
# endcode
# itrealvalue
# kstkesp
# pid
# stime
# startcode
# env_start
# session
# vsize
# cmajflt
# arg_end
# utime
# startstack
# rss
# policy
# rsslim
# delayacct_blkio_ticks
# starttime
# rt_priority
# minflt
# start_data
# cguest_time
# exit_code
# tpgid
# env_end
# state
# end_data
# num_threads
#

# .MAP meminfo
#
# Chaves:
#
# size
# resident
# share
# text
# lib
# data
# dt
#

# .MAP io
#
# Chaves:
#
# cancelled_write_bytes
# wchar
# read_bytes
# write_bytes
# syscw
# syscr
# rchar
#

# .TYPE pspid_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.stats
# S.mem
# S.io
# S.info
#
typedef pspid_t	ps.stats	\
				ps.mem		\
				ps.io		\
				ps.info

# Funções (somente-leitura)
readonly -f ps.pids		\
			ps.pidof	\
			ps.stats	\
			ps.mem		\
			ps.io		\
			ps.info		\
			ps.__cpid__
					
# /* __PS_SH__ */
