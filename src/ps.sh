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
	proc		ps_t \
	state		char \
	ppid		int \
	pgrp		int \
	session		int \
	tty			int \
	tpgid		int \
	flags		uint \
	minflt		uint \
	cminflt		uint \
	majflt		uint \
	cmajflt 	uint \
	utime		int \
	stime		int \
	cutime		int \
	cstime		int \
	counter		int \
	priority	int \
	timeout		uint \
	itrealvalue	uint \
	starttime	uint \
	vsize		uint \
	rss			uint \
	rlim		uint \
	startcode	uint \
	endcode		uint \
	startstack	uint \
	kstkesp		uint \
	kstkeip		uint \
	signal		int \
	blocked		int \
	sigignore	int \
	sigcatch	int \
	wchan		uint

__TYPE__[pid_t]='
ps.getprocess
ps.getpio
ps.getpmmap
'

function ps.getprocess()
{
	getopt.parse 2 "pid:uint:+:$1" "buf:ps_t:+:$2" "${@:3}"
	
	ps.__check_pid $1 || return $?

	local exe pid
	
	pid=/proc/$1
	exe=$(readlink $pid/exe)

	$2.pid = "$1"
	$2.comm = "$(< $pid/comm)"
	$2.name = "${exe##*/}"
	$2.exe = "$exe"
	$2.cwd = "$(readlink $pid/cwd)"
	$2.cmd = "$(< $pid/cmdline)"
	
	return $?
}

function ps.getpid()
{
	getopt.parse 1 "name:str:+:$1" "${@:2}"

	local pname proc ok
	
	ok=1

	printf '%s\n' /proc/[0-9]* | \
	while read proc; do
		pname=$(readlink $proc/exe) || continue
		if [[ ${pname##*/} == $1 ]]; then
			echo "${proc##*/}"
			ok=0
		fi
	done

	return $ok
}

function ps.getpio()
{
	getopt.parse 2 "pid:uint:+:$1" "buf:psio_t:+:$2" "${@:3}"
	
	ps.__check_pid $1 || return $?
	
	local flag bytes

	while read flag bytes; do
		case ${flag%:} in
			rchar)						$2.rchar = "$bytes";;
			wchar)						$2.wchar = "$bytes";;
			syscr)						$2.syscr = "$bytes";;
			syscw)						$2.syscw = "$bytes";;
			read_bytes) 				$2.rbytes = "$bytes";;
			write_bytes)				$2.wbytes = "$bytes";;
			cancelled_write_bytes) 		$2.cwbytes = "$bytes";;
		esac
	done < /proc/$1/io

	return $?	
}

function ps.getpmmap()
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
	done < /proc/$1/maps

	return $?
}

function ps.__check_pid(){ [[ -d /proc/$1 ]] || error.trace def 'pid' 'uint' "$1" "O pid do processo não existe"; return $?; }

source.__INIT__
# /* __PS_SH */
