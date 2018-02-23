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

[[ $__SYS_SH ]] && return 0

readonly __SYS_SH=1

source builtin.sh
source struct.sh

readonly __SYS_KERNEL=/proc/sys/kernel

readonly F_OK=0
readonly X_OK=1
readonly W_OK=2
readonly R_OK=4

var utsname_t struct_t

utsname_t.__add__ \
	sysname 	str \
	nodename	str \
	release		str \
	version		str \
	machine		str \
	domainname	str

# func sys.uname <[utsname_t]buf> => [bool]
#
# Retorna as informações do sistema e salva na estrutura apontada por 'buf'.
# Retorna 'true' para sucesso, caso contrário 'false'.
#
function sys.uname()
{
	getopt.parse 1 "buf:utsname_t:+:$1" "${@:2}"
	
	local arch
	
	((1<<64)) && arch=x86_64 || arch=i386
	
	$1.sysname = "$(< $__SYS_KERNEL/ostype)"
	$1.nodename = "$(< $__SYS_KERNEL/hostname)"
	$1.release = "$(< $__SYS_KERNEL/osrelease)"
	$1.version = "$(< $__SYS_KERNEL/version)"
	$1.domainname = "$(< $__SYS_KERNEL/domainname)"
	$1.machine = "$arch"

	return $?
}

# func sys.gethostname => [str]
#
# Retorna o nome da máquina.
#
function sys.gethostname()
{
	getopt.parse 0 "$@"
	echo "$(< $__SYS_KERNEL/hostname)"
	return $?
}

# func sys.getdomainname => [str]
#
# Retorna o domínio atual.
#
function sys.getdomainname()
{
	getopt.parse 0 "$@"
	echo "$(< $__SYS_KERNEL/domainname)"
	return $?
}

# func sys.access <[path]filepath> <[uint]mode> => [bool]
#
# Verifica as permissões do usuário para o arquivo especificado em 'filepath'.
# Retorna 'true' se o usuário possui as permissões em 'mode', caso contrário 'false'.
#
function sys.access()
{
	getopt.parse 2 "filepath:path:+:$1" "mode:uint:+:$2" "${@:3}"

	case $2 in
		0) [[ -f $1 ]];;
		1) [[ -x $1 ]];;
		2) [[ -w $1 ]];;
		3) [[ -x $1 && -w $1 ]];;
		4) [[ -r $1 ]];;
		5) [[ -x $1 && -r $1 ]];;
		6) [[ -w $1 && -r $1 ]];;
		7) [[ -x $1 && -w $1 && -r $1 ]];;
		*) error.trace def 'mode' 'uint' 'modo de acesso inválido'; return $?;;
	esac
	
	return $?	
}

source.__INIT__
# /* __SYS_SH */
