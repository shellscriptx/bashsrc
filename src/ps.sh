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

[[ $__PS_SH ]] && return 0

readonly __PS_SH=1

source builtin.sh
source struct.sh

var psio_t struct_t
var psstat_t struct_t
var ps_t struct_t

ps_t.__add__ \
	pid		uint \
	comm	str \
	name	str \
	exe		str \
	cwd		str \
	cmd		str 

psio_t.__add__ \
	rchar		uint \
	wchar		uint \
	syscr		uint \
	syscw		uint \
	rbytes		uint \
	wbytes		uint \
	cwbytes		uint

psstat_t.__add__ \
	pid						uint \
	comm					str \
	state					char \
	ppid					int \
	pgrp					int \
	session					int \
	tty						int \
	tpgid					int \
	flags					uint \
	minflt					uint \
	cminflt					uint \
	majflt					uint \
	cmajflt 				uint \
	utime					int \
	stime					int \
	cutime					int \
	cstime					int \
	priority				int \
	nice					int \
	threads					uint \
	itrealvalue				uint \
	starttime				uint \
	vsize					uint \
	rss						uint \
	rlim					uint \
	startcode				uint \
	endcode					uint \
	startstack				uint \
	kstkesp					uint \
	kstkeip					uint \
	signal					int \
	blocked					int \
	sigignore				int \
	sigcatch				int \
	wchan					uint \
	nswap					uint \
	cnswap					uint \
	exit_signal				int \
	processor				int \
	rt_priority 			uint \
	policy					uint \
	delayacct_blkio_ticks 	uint \
	guest_time				uint \
	cguest_time 			int \
	start_data				uint \
	end_data				uint \
	start_brk				uint \
	arg_start				uint \
	arg_end					uint \
	env_start				uint \
	env_end					uint \
	exit_code				int


__TYPE__[pid_t]='
ps.proc
ps.io
ps.mmap
ps.stats
'

# func ps.getallpids => [uint]
#
# Retorna uma lista iterável contendo o pid de todos os
# processos em execução.
#
function ps.getallpids()
{
	getopt.parse 0 "$@"

	while read proc; do
		echo "${proc##*/}"
	done < <(printf '%s\n' /proc/[0-9]*)

	return $?
}

# func ps.pidof <[str]procname> => [uint]
#
# Retorna o pid do processo apontado por 'procname'.
#
function ps.pidof()
{
	getopt.parse 1 "procname:str:+:$1" "${@:2}"
	
	local ok proc

	ok=1

	while read proc; do
		if [[ -e $proc/cmdline && $(< $proc/cmdline) == *@($1)* ]]; then
			echo "${proc##*/}"
			ok=0
		fi
	done < <(printf '%s\n' /proc/[0-9]*)

	return $ok
}

# func ps.proc <[uint]pid> <[ps_t]buf> => [bool]
#
# Obtem os atributos do 'pid' e salva na estrutura apontada por 'buf'.
#
function ps.proc()
{
	getopt.parse 2 "pid:uint:+:$1" "buf:ps_t:+:$2" "${@:3}"
	
	ps.__check_pid $1 || return $?

	local exe pid
	
	pid=/proc/$1
	exe=$(readlink $pid/exe) || { error.trace def; return 1; }

	$2.pid = "$1"
	$2.comm = "$(< $pid/comm)"
	$2.name = "${exe##*/}"
	$2.exe = "$exe"
	$2.cwd = "$(readlink $pid/cwd)"
	$2.cmd = "$(< $pid/cmdline)"
	
	return $?
}

# func ps.io <[uint]pid> <[psio_t]buf> => [bool]
#
# Salva as estatísticas de leitura e escrita do processo 
# na estrutura apontada por 'buf'.
#
function ps.io()
{
	getopt.parse 2 "pid:uint:+:$1" "buf:psio_t:+:$2" "${@:3}"
	
	ps.__check_pid $1 || return $?
	
	local flag bytes

	while read flag bytes; do
		case ${flag%:} in
			rchar)		$2.rchar = "$bytes";;
			wchar)		$2.wchar = "$bytes";;
			syscr)		$2.syscr = "$bytes";;
			syscw)		$2.syscw = "$bytes";;
			rbytes)		$2.rbytes = "$bytes";;
			wbytes)		$2.wbytes = "$bytes";;
			cwbytes)	$2.cwbytes = "$bytes";;
		esac
	done < /proc/$1/io || error.trace def

	return $?	
}

# func ps.mmap <[uint]pid> <[array]buf> => [bool]
#
# Mapeia os atributos de acesso do 'pid' na memória e salva no array apontado por 'buf'.
#
# Os elementos são armazenados em um array indexado, sendo um endereçamento por vetor no seguinte formato:
#
# address|perms|offset|dev|inode|pathname
#
function ps.mmap()
{
	getopt.parse 2 "pid:uint:+:$1" "mapbuf:array:+:$2" "${@:3}"
	
	ps.__check_pid $1 || return $?

	local __addr  __perms __offset __dev __inode __path __i

	while read __addr __perms __offset __dev __inode __path; do
		printf -v $2[$((__i++))] '%s|%s|%s|%s|%s|%s\n' 	"$__addr" \
														"$__perms" \
														"$__offset" \
														"$__dev" \
														"$__inode" \
														"$__path"
	done < /proc/$1/maps || error.trace def

	return $?
}

# func ps.stats <[uint]pid> <[psstat_t]buf> => [bool]
#
# Lê as estatíticas e propriedades do processo referênciado por 'pid' e salva na
# estrutura apontada por 'buf'.
#
function ps.stats()
{
	getopt.parse 2 "pid:uint:+:$1" "buf:psstat_t:+:$2" "${@:3}"

	ps.__check_pid $1 || return $?

	local pid inf stat exe comm
	
	pid=/proc/$1
	inf=$(< $pid/stat) || { error.trace def; return 1; }
	exe=$(readlink $pid/exe)

	[[ $inf =~ ${__FLAG_IN[proc_stat]} ]]
	read -a stat <<< "$BASH_REMATCH"

	[[ $inf =~ ${__FLAG_IN[parenth]} ]]
	comm=${BASH_REMATCH[1]}
	
	$2.pid = "$1"
	$2.comm = "$comm"
	$2.state = "${stat[0]}"
	$2.ppid = "${stat[1]}"
	$2.pgrp = "${stat[2]}"
	$2.session = "${stat[3]}"
	$2.tty = "${stat[4]}"
	$2.tpgid = "${stat[5]}"
	$2.flags = "${stat[6]}"
	$2.minflt = "${stat[7]}"
	$2.cminflt = "${stat[8]}"
	$2.majflt = "${stat[9]}"
	$2.cmajflt = "${stat[10]}"
	$2.utime = "${stat[11]}"
	$2.stime = "${stat[12]}"
	$2.cutime = "${stat[13]}"
	$2.cstime = "${stat[14]}"
	$2.priority = "${stat[15]}"
	$2.nice = "${stat[16]}"
	$2.threads = "${stat[17]}"
	$2.itrealvalue = "${stat[18]}"
	$2.starttime = "${stat[19]}"
	$2.vsize = "${stat[20]}"
	$2.rss = "${stat[21]}"
	$2.rlim = "${stat[22]}"
	$2.startcode = "${stat[23]}"
	$2.endcode = "${stat[24]}"
	$2.startstack = "${stat[25]}"
	$2.kstkesp = "${stat[26]}"
	$2.kstkeip = "${stat[27]}"
	$2.signal = "${stat[28]}"
	$2.blocked = "${stat[29]}"
	$2.sigignore = "${stat[30]}"
	$2.sigcatch = "${stat[31]}"
	$2.wchan = "${stat[32]}"
	$2.nswap = "${stat[33]}"
	$2.cnswap = "${stat[34]}"
	$2.exit_signal = "${stat[35]}"
	$2.processor = "${stat[36]}"
	$2.rt_priority = "${stat[37]}"
	$2.policy = "${stat[38]}"
	$2.delayacct_blkio_ticks = "${stat[39]}"
	$2.guest_time = "${stat[40]}"
	$2.cguest_time = "${stat[41]}"
	$2.start_data = "${stat[42]}"
	$2.end_data = "${stat[43]}"
	$2.start_brk = "${stat[44]}"
	$2.arg_start = "${stat[45]}"
	$2.arg_end = "${stat[46]}"
	$2.env_start = "${stat[47]}"
	$2.env_end = "${stat[48]}"
	$2.exit_code = "${stat[49]}"

	return $?	
}

function ps.__check_pid(){ [[ -d /proc/$1 ]] || error.trace def 'pid' 'uint' "$1" "O pid do processo não existe"; return $?; }

source.__INIT__
# /* __PS_SH */
