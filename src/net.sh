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

[ -v __NET_SH__ ] && return 0

readonly __NET_SH__=1

source builtin.sh

readonly -A __NET__=(
[ipv4]='^(([0-9]|[1-9][0-9]|1[0-9]{,2}|2[0-4][0-9]|25[0-5])[.]){3}([0-9]|[1-9][0-9]|1[0-9]{,2}|2[0-4][0-9]|25[0-5])$'
[ipv6]='^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$'
)

# .FUNCTION net.getifaces -> [str]
#
# Retorna as interfaces de rede
#
function net.getifaces()
{
	getopt.parse 0 "$@"

	local if; printf '%s\n' /sys/class/net/* |
	while IFS=$'\n' read if; do echo ${if##*/}; done
	return $?
}

# .FUNCTION net.getifaddrs <iface[str]> <ifa[map]> -> [bool]
#
# Lẽ as informações da interface.
#
# == EXEMPLO ==
# 
# source net.sh
#
# # Mapa
# declare -A inet=()
#
# # Lê as informações da interface.
# net.getifaddrs 'wlx001a3f8329f2' inet
#
# # Informações.
# echo "Indice:" ${inet[index]}
# echo "Nome:" ${inet[name]}
# echo "Status:" ${inet[state]}
# echo "Dispositivo:" ${inet[dev]}
# echo "IPv4:" ${inet[addr4]}
#
# == SAÍDA ==
#
# Indice: 3
# Nome: wlx001a3f8329f2
# Status: up
# Dispositivo: wlan
# IPv4: 192.168.25.4
#
function net.getifaddrs()
{
	getopt.parse 2 "iface:str:$1" "ifa:map:$2" "${@:3}"

	local __iface__ __ifname__ __ifindex__ __stats__
	local __dev__ __inet4__ __inet6__ __flag__ __val__
	local -n __ref__=$2

	net.__check_iface__ "$1"	&&
	__ref__=()					|| return $?
		
	
	__iface__=/sys/class/net/$1
	__stats__=$__iface__/statistics

	while IFS='=' read __flag__ __val__; do
		case ${__flag__,,} in
			devtype)	__dev__=$__val__;;
			interface)	__ifname__=$__val__;;
			ifindex)	__ifindex__=$__val__;
		esac
	done < $__iface__/uevent

	if [ ! -v __ifname__ ]; then
		error.error "'$1' não foi possível obter informações da interface"
		return $?
	fi
	
	IFS='|' read -a __inet4__ <<< $(net.__get_ifaddr__ 4 $1)
	IFS='|' read -a __inet6__ <<< $(net.__get_ifaddr__ 6 $1)

	__ref__[index]=$__ifindex__
	__ref__[name]=$__ifname__
	__ref__[dev]=$__dev__
	__ref__[hwaddr]=$(< $__iface__/address)
	__ref__[broadcast]=$(< $__iface__/broadcast)
	__ref__[mtu]=$(< $__iface__/mtu)
	__ref__[state]=$(< $__iface__/operstate)
	
	__ref__[addr]=${__inet4__[0]}
    __ref__[mask]=${__inet4__[1]}
    __ref__[vlan]=${__inet4__[2]}

    __ref__[addr6]=${__inet6__[0]}
    __ref__[mask6]=${__inet6__[1]}
    __ref__[vlan6]=${__inet6__[2]}

    __ref__[tx_packets]=$(< $__stats__/tx_packets)
    __ref__[rx_packets]=$(< $__stats__/rx_packets)
    __ref__[tx_bytes]=$(< $__stats__/tx_bytes)
    __ref__[rx_bytes]=$(< $__stats__/rx_bytes)
    __ref__[tx_dropped]=$(< $__stats__/tx_dropped)
    __ref__[rx_dropped]=$(< $__stats__/rx_dropped)
    __ref__[tx_errors]=$(< $__stats__/tx_errors)
    __ref__[rx_errors]=$(< $__stats__/rx_errors)

    return $?
}

# .FUNCTION net.getifstats <iface[str]> <ifa[map]> -> [bool]
#
# Lê as estatísticas da interface.
#
function net.getifstats()
{
	getopt.parse 2 "iface:str:$1" "ifa:map:$2" "${@:3}"

	local -n __ref__=$2

	net.__check_iface__ "$1"	&&
	__ref__=()					|| return $?
	
	local __stats__=/sys/class/net/$1/statistics
	
	__ref__[tx_packets]=$(< $__stats__/tx_packets)
	__ref__[rx_packets]=$(< $__stats__/rx_packets)
	__ref__[tx_bytes]=$(< $__stats__/tx_bytes)
	__ref__[rx_bytes]=$(< $__stats__/rx_bytes)
	__ref__[tx_dropped]=$(< $__stats__/tx_dropped)
	__ref__[rx_dropped]=$(< $__stats__/rx_dropped)
	__ref__[tx_errors]=$(< $__stats__/tx_errors)
	__ref__[rx_errors]=$(< $__stats__/rx_errors)

	return $?
}

# .FUNCTION net.getifaddr <iface[str]> <ifa[map]> -> [bool]
#
# Obtém o endereço ipv4 da interface.
#
function net.getifaddr()
{
	getopt.parse 2 "iface:str:$1" "ifa:map:$2" "${@:3}"
	
	local __inet__
	local -n __ref__=$2

	net.__check_iface__ "$1"	&&
	__ref__=()					|| return $?
	
	IFS='|' read -a __inet__ <<< $(net.__get_ifaddr__ 4 $1)
	
	__ref__[addr]=${__inet__[0]}
	__ref__[mask]=${__inet__[1]}
	__ref__[vlan]=${__inet__[2]}
	
	return $?
}

# .FUNCTION net.getifaddr6 <iface[str]> <ifa[map]> -> [bool]
#
# Obtém o endereço ipv6 da interface.
#
function net.getifaddr6()
{
	getopt.parse 2 "iface:str:$1" "ifa:map:$2" "${@:3}"

	local __inet__
	local -n __ref__=$2
	
	net.__check_iface__ "$1"	&&
	__ref__=()					|| return $?
	
	IFS='|' read -a __inet__ <<< $(net.__get_ifaddr__ 6 $1)
	
	__ref__[addr6]=${__inet__[0]}
	__ref__[mask6]=${__inet__[1]}
	__ref__[vlan6]=${__inet__[2]}
	
	return $?
}

# .FUNCTION net.gethostbyname <addr[str]> -> [str]|[bool]
#
# Retorna uma lista de endereços ipv4 e ipv6 (se disponnível) do endereço especificado.
#
net.gethostbyname()
{
	getopt.parse 1 "addr:str:$1" "${@:2}"
	
	local expr
	
	if ! (host -t A $1 && host -t AAAA $1); then
		error.error "'$1' host não encontrado"
		return $?
	fi | while IFS=' ' read -a expr; do
		[[ ${expr[-1]} != 3\(NXDOMAIN\) ]] &&
		echo ${expr[-1]}
	done
 
	return $?
}

# .FUNCTION net.gethostbyaddr <addr[str]> -> [str]|[bool]
#
# Retorna uma lista com os nomes mapeados para o endereço especificado.
#
function net.gethostbyaddr()
{
	getopt.parse 1 "addr:str:$1" "${@:2}"
	
	local expr

	if ! host -t PTR $1; then
		error.error "'$1' host não encontrado"
		return $?
	fi | while IFS=' ' read -a expr; do
		[[ ${expr[-1]} != 3\(NXDOMAIN\) ]] &&
		echo ${expr[-1]}
	done
 
	return $?
}

# .FUNCTION net.nslookup <addr[str]> <dnsreg[map]> -> [bool]
#
# Resolve os registros DNS.
#
function net.nslookup()
{
	getopt.parse 2 "addr:str:$1" "dnsreg:map:$2" "${@:3}"
	
	local __expr__ __ok__ __i__
	local -n __ref__=$2

	__ref__=() || return 1

	while IFS=$'\t' read -a __expr__; do
		if [[ ${__expr__[3]} == @(A|AAAA|NS|CNAME|MX|PTR|TXT|SOA|SPF|SRV) ]]; then
			__ref__[name[${__i__:=0}]]=${__expr__[0]}
			__ref__[ttl[$__i__]]=${__expr__[1]}
			__ref__[class[$__i__]]=${__expr__[2]}
			__ref__[type[$__i__]]=${__expr__[3]}
			__ref__[addr[$__i__]]=${__expr__[4]}
			((__i__++))
			__ok__=true
		fi
	done < <(host -a $1)
	
	[[ $__ok__ ]] || error.error "'$1' endereço não encontrado"

	return $?
}

# .FUNCTION net.ping <addr[str]> <count[uint]> <stats[map]> -> [bool]
#
# Envia ICMP_HOST_REQUEST para o endereço de rede.
#
# == EXEMPLO ==
# 
# source net.sh
#
# # Mapa
# declare -A stat=()
#
# # Envia 4 pacotes.
# net.ping 'google.com' 4 stat
#
# # Imprime as estatísticas.
# for key in ${!stat[@]}; do
#     echo "$key = ${stat[$key]}"
# done
#
# == SAÍDA ==
#
# host = rio01s20-in-f46.1e100.net
# addr = 172.217.29.46
# tx_packets = 4
# rx_packets = 4
# lp_packets = 0
# time = 3005
# ttl = 56
# rtt_min = 4.664
# rtt_max = 39.301
# rtt_avg = 22.536
# rtt_mdev = 16.211
#
function net.ping()
{
	getopt.parse 3 "addr:str:$1" "count:uint:$2" "stats:map:$3" "${@:4}"

	local __expr__ __ipv4__ __ipv6__ __stats__
	local __i__ __ttl__ __addr__ __host__ __cping__
	local -n __ref__=$3

	__ref__=() || return 1

	# Define a versão do comando ping.	
	[[ $1 =~ ${__NET__[ipv6]} ]] && __cping__=ping6 || __cping__=ping
	
	__ipv4__=${__NET__[ipv4]}
	__ipv6__=${__NET__[ipv6]}

	# Remove ancoras
	__ipv4__=${__ipv4__#?}; __ipv4__=${__ipv4__%?}
	__ipv6__=${__ipv6__#?}; __ipv6__=${__ipv6__%?}

	# Extrai as informações da saída padrão.
	# addr, host, ttl, stats e rtt
	while IFS=$'\n' read __expr__; do
		if [[ ! $__addr__ && $__expr__ =~ \(($__ipv4__|$__ipv6__)\) ]]; then 
			__addr__=${BASH_REMATCH[1]}
		elif [[ ! $__host__ && $__expr__ =~ from\ +([^ ]+).+\ +ttl=([0-9]+) ]]; then 
			__host__=${BASH_REMATCH[1]}
			__ttl__=${BASH_REMATCH[2]}
		elif [[ $__expr__ =~ (packets|rtt) ]]; then
			while [[ $__expr__ =~ [0-9]+(\.[0-9]+)?	]]; do
				__stats__[$((__i__++))]=$BASH_REMATCH
				__expr__=${__expr__/$BASH_REMATCH}
			done
		fi
	done < <($__cping__ -c$2 -W5 $1 2>/dev/null)

	# Sem estatíticas.	
	if [ ! -v __stats__ ]; then
		error.error "'$1' host não encontrado"
		return $?
	fi


	# Valores
	__ref__[host]=$__host__
	__ref__[addr]=$__addr__
	__ref__[ttl]=$__ttl__
	__ref__[tx_packets]=${__stats__[0]}
	__ref__[rx_packets]=${__stats__[1]}
	__ref__[lp_packets]=${__stats__[2]}
	__ref__[time]=${__stats__[3]}
	__ref__[rtt_min]=${__stats__[4]}
	__ref__[rtt_avg]=${__stats__[5]}
	__ref__[rtt_max]=${__stats__[6]}
	__ref__[rtt_mdev]=${__stats__[7]}

	return $?	
}

# .FUNCTION net.isaddr <addr[str]> -> [bool]
#
# Retorna 'true' se o endereço é do tipo ipv4.
#
function net.isaddr()
{
	getopt.parse 1 "addr:str:$1" "${@:2}"
	[[ $1 =~ ${__NET__[ipv4]} ]]
	return $?
}

# .FUNCTION net.isaddr6 <addr[str]> -> [bool]
#
# Retorna 'true' se o endereço é do tipo ipv6.
#
function net.isaddr6()
{
	getopt.parse 1 "addr:str:$1" "${@:2}"
	[[ $1 =~ ${__NET__[ipv6]} ]]
	return $?
}

# .FUNCTION net.getexternalip => [str]|[bool]
#
# Obtem o endereço de ip externo.
#
function net.getexternalip()
{
getopt.parse 0 "$@"

	local ok url urls
	
	local urls=('api.ipify.org'
				'ip.42.pl/raw'
				'myexternalip.com/raw'
				'ipecho.net/plain'
				'icanhazip.com')

	for url in ${urls[@]}; do
		wget -T3 -qO- "$url" 2>/dev/null && 
		echo && break
	done

	(($?)) && error.error 'não foi possível obter o endereço externo'

	return $?
}

function net.__get_ifaddr__()
{
	local ip mask vlan bsize bs bu bits inet

	bsize=$(($1 == 4 ? 32 : $(($1 == 6 ? 128 : 0))))

	((bsize == 0)) && return 1

	inet='inet6?\s+([^/]+)/([0-9]+)'

	if [[ $(ip -$1 -o addr show dev $2) =~ $inet ]]; then

		ip=${BASH_REMATCH[1]}
		vlan=${BASH_REMATCH[2]}

		printf -v bs '%*s' $vlan
		printf -v bu '%*s' $((bsize-vlan))

		bits=${bs// /1}${bu// /0}

		case $1 in
			4)
				printf -v mask '%d.%d.%d.%d'    $((2#${bits:0:8}))  \
												$((2#${bits:8:8}))  \
												$((2#${bits:16:8})) \
												$((2#${bits:24:8}))
				;;
			6)
				printf -v mask '%x:%x:%x:%x:%x:%x:%x:%x'    $((2#${bits:0:16}))     \
															$((2#${bits:16:16}))    \
															$((2#${bits:32:16}))    \
															$((2#${bits:48:16}))    \
															$((2#${bits:64:16}))    \
															$((2#${bits:80:16}))    \
															$((2#${bits:96:16}))    \
															$((2#${bits:112:16}))
				;;
		esac
	fi

	echo "${ip:-0.0.0.0}|${mask:-0.0.0.0}|${vlan:-0}"

	return 0
}

function net.__check_iface__()
{
	[ -L /sys/class/net/$1 ] || error.error "'$1' interface não encontrada"
	return $?
}

# .MAP ifa
#
# Chaves:
#
# index
# name
# dev
# hwaddr
# broadcast
# mtu
# state
# addr
# mask
# vlan
# addr6
# mask6
# vlan6
# tx_packets
# rx_packets
# tx_bytes
# rx_bytes
# tx_dropped 
# rx_dropped
# tx_errors
# rx_errors
#

# .MAP dnsreg
#
# Chaves:
#
# name[N]
# ttl[N]
# class[N]
# type[N]
# addr[N]
#
# 'N' é o índice do registro.
#

# .MAP stats
#
# Chaves:
#
# host
# addr
# ttl
# tx_packets
# rx_packets
# lp_packets
# time
# rtt_min
# rtt_avg
# rtt_max
# rtt_mdev
#

# .TYPE iface_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.getifaddrs
# S.getifstats
# S.getifaddr
# S.getifaddr6
#
typedef iface_t net.getifaddrs	\
				net.getifstats	\
				net.getifaddr	\
				net.getifaddr6

# .TYPE addr_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.gethostbyname
# S.gethostbyaddr
# S.nslookup
# S.ping
# S.isaddr
# S.isaddr6
#
typedef addr_t	net.gethostbyname	\
				net.gethostbyaddr	\
				net.nslookup		\
				net.ping			\
				net.isaddr			\
				net.isaddr6

# Funções (somente leitura)
readonly -f	net.getifaces		\
			net.getifaddrs		\
			net.getifstats		\
			net.getifaddr		\
			net.getifaddr6		\
			net.gethostbyaddr	\
			net.nslookup		\
			net.ping			\
			net.isaddr			\
			net.isaddr6			\
			net.getexternalip	\
			net.__get_ifaddr__	\
			net.__check_iface__

# /* __NET_SH__ */

