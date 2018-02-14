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

[[ $__GRP_SH ]] && return 0

readonly __GRP_SH=1

source builtin.sh
source struct.sh

var group_t struct_t

group_t.__add__ \
	gr_name		str \
	gr_passwd 	str \
	gr_gid		uint \
	gr_mem		str


# func grp.getgrall => [str]
#
# Retorna uma lista iterável de todos os grupos do sistema.
#
function grp.getgrall(){
	getopt.parse 0 $@
	grp.__get_grinfo grall
	return $?
}

# func grp.getgrgid <[group_t]struct> <[uint]gid>
#
# Salva em 'struct' as informações do 'gid' especificado.
#
function grp.getgrgid(){
	getopt.parse 2 "struct:group_t:+:$1" "gid:uint:+:$2" "${@:3}"
	grp.__get_grinfo grgid $1 $2
	return $?
}

# func grp.getgrnam <[group_t]struct> <[str]name>
#
# Salva em 'struct' as informações do grupo 'name'.
#
function grp.getgrnam(){
	getopt.parse 2 "struct:group_t:+:$1" "name:str:+:$2" "${@:3}"
	grp.__get_grinfo grnam $1 $2
	return $?
}

function grp.__get_grinfo()
{
	local name pass gid mem flag

	while IFS=':' read name pass gid mem; do
		case $1 in
			grall) echo "$name";;
			grgid|grnam)	[[ $1 == grgid ]] && flag=$gid
							[[ $3 == ${flag:-$name} ]] && {
								$2.gr_name = "$name"
								$2.gr_passwd = "$pass"
								$2.gr_gid = "$gid"
								$2.gr_mem = "$mem"
								break
							};;
		esac
	done < /etc/group 2>/dev/null || {
		error.trace def
		return $?
	}

	return 0
}

source.__INIT__
# /* __GRP_SH */
