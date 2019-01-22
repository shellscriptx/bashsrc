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

[ -v __CPU_SH__ ] && return 0

readonly __CPU_SH__=1

source builtin.sh

# .FUNCTION cpu.getinfo <cpuinfo[map]> -> [bool]
#
# Obtem informações do processador,
#
# == EXEMPLO ==
#
# source cpu.sh
#
# # Inicializa o map
# declare -A info=()
#
# # Obtendo informações.
# cpu.getinfo info
#
# # Listando informações.
# echo ${info[processor[0]]}
# echo ${info[model_name[0]]}
# echo ${info[cpu_mhz[0]]}
# echo ---
# echo ${info[processor[1]]}
# echo ${info[model_name[1]]}
# echo ${info[cpu_mhz[1]]}
#
# == SAÍDA ==
#
# 0
# Intel(R) Core(TM) i5-3330 CPU @ 3.00GHz
# 1961.110
# ---
# 1
# Intel(R) Core(TM) i5-3330 CPU @ 3.00GHz
# 1875.432
#
function cpu.getinfo()
{
	getopt.parse 1 "cpuinfo:map:$1" "${@:2}"

	local __flag__ __value__ __info__
	local __i__=-1
	local -n __ref__=$1

	# Inicializar.
	__ref__=() || return 1

	while IFS=':' read __flag__ __value__; do
		__flag__=${__flag__//@($'\t')}
		__flag__=${__flag__// /_}
		__flag__=${__flag__,,}
		__value__=${__value__##+( )}
		case $__flag__ in
			processor) ((++__i__));;
			'') continue;;
		esac
		# Atribui o valor da chave.
		__ref__[$__flag__[$__i__]]=$__value__
	done < /proc/cpuinfo || error.error "'/proc/cpuinfo' não foi possível ler o arquivo"

	return $?
}

# .MAP cpuinfo
#
# Chaves:
#
# address_sizes[N]
# apicid[N]
# bogomips[N]
# bugs[N]
# cache_alignment[N]
# cache_size[N]
# clflush_size[N]
# core_id[N]
# cpu_cores[N]
# cpu_family[N]
# cpuid_level[N]
# cpu_mhz[N]
# flags[N]
# fpu[N]
# fpu_exception[N
# initial_apicid[N]
# microcode[N]
# model[N]
# model_name[N]
# physical_id[N]
# power_management[N]
# processor[N]
# siblings[N]
# stepping[N]
# vendor_id[N]
# wp[N]
#
# > 'N' é o índice do elemento.
#

readonly -f cpu.getinfo

# /* _CPU_SH__ */
