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
	inet		inet_t \
	inet6		inet6_t \
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

	local iface dev ipv4 ipv6 inet vlan4 vlan6 stats bs bu bits mask4 mask6

	net.__check_iface $1 || return $?
		
	iface=$__SYS_NET/$1
	stats=$__SYS_NET/$1/statistics

	inet='inet6?\s+([^/]+)/([0-9]+)'
	
	[[ $(< $iface/uevent) =~ DEVTYPE=([a-zA-Z0-9_]+) ]]
	dev=${BASH_REMATCH[1]}
	
	[[ $(ip -4 -o addr show dev $1) =~ $inet ]]
	ipv4=${BASH_REMATCH[1]}
	vlan4=${BASH_REMATCH[2]}

	[[ $(ip -6 -o addr show dev $1) =~ $inet ]]
	ipv6=${BASH_REMATCH[1]}
	vlan6=${BASH_REMATCH[2]}

	vlan4=${vlan4:-0}
	vlan6=${vlan6:-0}

	printf -v bs '%*s' $vlan4
	printf -v bu '%*s' $((32-vlan4))

	bits=${bs// /1}${bu// /0}
	printf -v mask4 '%d.%d.%d.%d' 	$((2#${bits:0:8}))	\
									$((2#${bits:8:8})) 	\
									$((2#${bits:16:8}))	\
									$((2#${bits:24:8}))

	printf -v bs '%*s' $vlan6
	printf -v bu '%*s' $((128-vlan6))
	
	bits=${bs// /1}${bu// /0}
	printf -v mask6 '%x:%x:%x:%x:%x:%x:%x:%x'	$((2#${bits:0:16}))		\
												$((2#${bits:16:16})) 	\
												$((2#${bits:32:16})) 	\
												$((2#${bits:48:16})) 	\
												$((2#${bits:64:16})) 	\
												$((2#${bits:80:16})) 	\
												$((2#${bits:96:16})) 	\
												$((2#${bits:112:16}))

	$2.name = "$1"
	$2.dev = "$dev"
	$2.hwaddr = "$(< $iface/address)"
	$2.broadcast = "$(< $iface/broadcast)"
	$2.mtu = "$(< $iface/mtu)"
	$2.state = "$(< $iface/operstate)"
	$2.inet.vlan = "$vlan4"
	$2.inet6.vlan = "$vlan6"
	$2.inet.addr = "$ipv4"
	$2.inet6.addr = "$ipv6"
	$2.inet.mask = "$mask4"
	$2.inet6.mask = "$mask6"
	
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

# func net.getaddr <[str]iface> <[flag]family> => [str]
#
# Retorna o endereço ip da interface 'iface' no protocolo especificado em 'family'.
#
# Flag family:
#
# AF_INET
# AF_INET6
#
function net.getaddr()
{
	getopt.parse 2 "iface:str:+:$1" "family:flag:+:$2" "${@:3}"

	local af inet

	net.__check_iface $1 || return $?
	
	case $2 in
		AF_INET) af=4;;
		AF_INET6) af=6;;
		*) error.trace def 'family' 'flag' "$2" 'flag de protocolo inválida'; return $?;;
	esac
	
	inet='inet6?\s+([^/]+)/([0-9]+)'
	
	[[ $(ip -$af -o addr show dev $1) =~ $inet ]]
	echo "${BASH_REMATCH[1]}"
	
	return $?
}

function net.__check_iface()
{
	[[ -L $__SYS_NET/$1 ]] || error.trace def 'iface' 'str' "$1" "interface de rede não encontrada"
	return $?
}

source.__INIT__
# /* __NET_SH */
