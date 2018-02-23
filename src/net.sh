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

[[ $__NET_SH ]] && return 0

readonly __NET_SH=1

source builtin.sh
source struct.sh

readonly __SYS_NET=/sys/class/net

var iface_t struct_t

iface_t.__add__ \
	name		str \
	type		uint \
	address		mac \
	broadcast	mac \
	addr_len	uint \
	dev_id		hex \
	dev_port	uint \
	dev_type	str \
	flags		hex \
	ifindex		uint \
	iflink		uint \
	mtu			uint \
	state		str \
	ipv4		ipv4 \
	ipv6		ipv6
	
function net.interfaces
{
	getopt.parse 0 "$@"

	local iface

	while read iface; do
		echo "${iface##*/}"
	done < <(printf '%s\n' $__SYS_NET/*)
	
	return $?
}

function net.getiface()
{
	getopt.parse 2 "iface:str:+:$1" "buf:iface_t:+:$2" "${@:3}"

	if [[ -L $__SYS_NET/$1 ]]; then
		
		local iface=$__SYS_NET/$1
		local devtype
		
		[[ $(< $iface/uevent) =~ DEVTYPE=([a-zA-Z0-9_]+) ]]
		devtype=${BASH_REMATCH[1]}

		$2.name = "$1"
		$2.type = "$(< $iface/type)"
		$2.address = "$(< $iface/address)"
		$2.broadcast = "$(< $iface/broadcast)"
		$2.addr_len = "$(< $iface/addr_len)"
		$2.dev_id = "$(< $iface/dev_id)"
		$2.dev_port = "$(< $iface/dev_port)"
		$2.dev_type = "$devtype"
		$2.flags = "$(< $iface/flags)"
		$2.ifindex = "$(< $iface/ifindex)"
		$2.iflink = "$(< $iface/iflink)"
		$2.mtu = "$(< $iface/mtu)"
		$2.state = "$(< $iface/operstate)"
	else
		error.trace def 'iface' 'str' "$1" "interface de rede não encontrada"
		return $?
	fi
	
	return 0
}

source.__INIT__
# /* __NET_SH */
