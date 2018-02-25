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
var ifacestat_t struct_t
var inet_t struct_t
var inet6_t struct_t

inet_t.__add__ \
	addr		ipv4 \
	mask		ipv4 \
	vlan		uint

inet6_t.__add__ \
	addr		ipv6 \
	mask		ipv6 \
	vlan		uint

ifacestat_t.__add__ \
	tx_packets		uint \
	rx_packets		uint \
	tx_bytes		uint \
	rx_bytes		uint \
	rx_dropped		uint \
	tx_dropped		uint \
	rx_errors		uint \
	tx_errors		uint

iface_t.__add__ \
	name		str \
	dev			str \
	hwaddr		mac \
	broadcast	mac \
	mtu			uint \
	state		str \
	ipv4		inet_t \
	ipv6		inet6_t \
	data		ifacestat_t

# func net.getifaces => [str]
#
# Retorna as interfaces de rede do sistema.
#
function net.getifaces()
{
	getopt.parse 0 "$@"

	local iface; printf '%s\n' $__SYS_NET/* | \
	while read iface; do echo "${iface##*/}"; done

	return $?
}

# func net.getifaddrs <[str]iface> <[iface_t]ifa> => [bool]
#
# Lê as informações da interface 'iface' e salva na estrutura apontada por 'ifa'.
# Retorna 'true' para sucesso, caso contário 'false'.
#
function net.getifaddrs()
{
	getopt.parse 2 "iface:str:+:$1" "ifa:iface_t:+:$2" "${@:3}"

	net.__check_iface $1 || return $?
	
	local iface stats dev inet4 inet6
	
	iface=$__SYS_NET/$1
	stats=$__SYS_NET/$1/statistics

	[[ $(< $iface/uevent) =~ DEVTYPE=([a-zA-Z0-9_]+) ]]
	dev=${BASH_REMATCH[1]}

	IFS='|' read -a inet4 <<< $(net.__get_ifa_addr 4 $1)
	IFS='|' read -a inet6 <<< $(net.__get_ifa_addr 6 $1)

	$2.name = "$1"
	$2.dev = "$dev"
	$2.hwaddr = "$(< $iface/address)"
	$2.broadcast = "$(< $iface/broadcast)"
	$2.mtu = "$(< $iface/mtu)"
	$2.state = "$(< $iface/operstate)"
	$2.ipv4.addr = "${inet4[0]}"
	$2.ipv4.mask = "${inet4[1]}"
	$2.ipv4.vlan = "${inet4[2]}"
	$2.ipv6.addr = "${inet6[0]}"
	$2.ipv6.mask = "${inet6[1]}"
	$2.ipv6.vlan = "${inet6[2]}"
	
	$2.data.tx_packets = "$(< $stats/tx_packets)"
	$2.data.rx_packets = "$(< $stats/rx_packets)"
	$2.data.tx_bytes = "$(< $stats/tx_bytes)"
	$2.data.rx_bytes = "$(< $stats/rx_bytes)"
	$2.data.tx_dropped = "$(< $stats/tx_dropped)"
	$2.data.rx_dropped = "$(< $stats/rx_dropped)"
	$2.data.tx_errors = "$(< $stats/tx_errors)"
	$2.data.rx_errors = "$(< $stats/rx_errors)"
	
	return $?
}

# func net.getifstats <[str]iface> <[ifacestat_t]ifa> => [bool]
#
# Lê os dados de estatísticas da interface 'iface' e salva na estrutura apontada por 'ifa'.
# Retorna 'true' para sucesso, caso contrário 'false'.
#
function net.getifstats()
{
	getopt.parse 2 "iface:str:+:$1" "ifa:ifacestat_t:+:$2" "${@:3}"

	local stats
	
	net.__check_iface $1 || return $?
		
	stats=$__SYS_NET/$1/statistics
	
	$2.tx_packets = "$(< $stats/tx_packets)"
	$2.rx_packets = "$(< $stats/rx_packets)"
	$2.tx_bytes = "$(< $stats/tx_bytes)"
	$2.rx_bytes = "$(< $stats/rx_bytes)"
	$2.tx_dropped = "$(< $stats/tx_dropped)"
	$2.rx_dropped = "$(< $stats/rx_dropped)"
	$2.tx_errors = "$(< $stats/tx_errors)"
	$2.rx_errors = "$(< $stats/rx_errors)"
	
	return $?
}

# func net.getifaddr <[str]iface> <[inet_t]ifa> => [bool]
#
# Obtem o endereço ipv4 da interface 'iface' e salva na estrtura apontada por 'ifa'.
#
function net.getifaddr()
{
	getopt.parse 2 "iface:str:+:$1" "ifa:inet_t:+:$2" "${@:3}"
	
	net.__check_iface $1 || return $?

	local inet
	
	IFS='|' read -a inet <<< $(net.__get_ifa_addr 4 $1)

	$2.addr = ${inet[0]}
	$2.mask = ${inet[1]}
	$2.vlan = ${inet[2]}
	
	return $?
}

# func net.getifaddr6 <[str]iface> <[inet6_t]ifa> => [bool]
#
# Obtem o endereço ipv6 da interface 'iface' e salva na estrtura apontada por 'ifa'.
#
function net.getifaddr6()
{
	getopt.parse 2 "iface:str:+:$1" "ifa:inet6_t:+:$2" "${@:3}"
	
	net.__check_iface $1 || return $?

	local inet
	
	IFS='|' read -a inet <<< $(net.__get_ifa_addr 6 $1)

	$2.addr = ${inet[0]}
	$2.mask = ${inet[1]}
	$2.vlan = ${inet[2]}
	
	return $?
}

function net.__get_ifa_addr()
{
	local ip mask vlan bsize bs bu bits

	bsize=$(($1 == 4 ? 32 : $(($1 == 6 ? 128 : 0))))
	
	((bsize == 0)) && return 1

	inet='inet6?\s+([^/]+)/([0-9]+)'

	[[ $(ip -$1 -o addr show dev $2) =~ $inet ]] || return 1

	ip=${BASH_REMATCH[1]}
	vlan=${BASH_REMATCH[2]}

	printf -v bs '%*s' $vlan
	printf -v bu '%*s' $((bsize-vlan))

	bits=${bs// /1}${bu// /0}

	case $1 in
		4)
			printf -v mask '%d.%d.%d.%d'	$((2#${bits:0:8}))	\
											$((2#${bits:8:8})) 	\
											$((2#${bits:16:8}))	\
											$((2#${bits:24:8}))
			;;
		6)
			printf -v mask '%x:%x:%x:%x:%x:%x:%x:%x'	$((2#${bits:0:16}))		\
														$((2#${bits:16:16})) 	\
														$((2#${bits:32:16})) 	\
														$((2#${bits:48:16})) 	\
														$((2#${bits:64:16})) 	\
														$((2#${bits:80:16})) 	\
														$((2#${bits:96:16})) 	\
														$((2#${bits:112:16}))
			;;
	esac

	printf '%s|%s|%d\n' $ip $mask $vlan

	return 0
}

function net.__check_iface()
{
	[[ -L $__SYS_NET/$1 ]] || error.trace def 'iface' 'str' "$1" "interface de rede não encontrada"
	return $?
}

source.__INIT__
# /* __NET_SH */
