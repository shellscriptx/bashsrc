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

[ -v __OS_SH__ ] && return 0

readonly __OS_SH__=1

source builtin.sh

# .FUNCTION os.uname <uts[map]> -> [bool]
#
# Obtém informações sobre o kernel atual.
#
function os.uname()
{
	getopt.parse 1 "uts:map:$1" "${@:2}"
	
	local __kernel__=/proc/sys/kernel
	local -n __ref__=$1
	
	__ref__=() || return 1

	__ref__[sysname]=$(< $__kernel__/ostype)
	__ref__[nodename]=$(< $__kernel__/hostname)
	__ref__[release]=$(< $__kernel__/osrelease)
	__ref__[version]=$(< $__kernel__/version)
	__ref__[domainname]=$(< $__kernel__/domainname)
	__ref__[machine]=$(arch)

	return $?
}

# .MAP uts
#
# Chaves:
#
# sysname
# nodename
# release
# version
# domainname
# machine
#

# Função (somente leitura)
readonly -f os.uname

# /* __OS_SH__ */
