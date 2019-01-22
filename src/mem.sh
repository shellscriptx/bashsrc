#!/bin/bash
#
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

[ -v __MEM_SH__ ] && return 0

readonly __MEM_SH__=1

source builtin.sh

# .FUNCTION mem.stats <stats[map]> -> [bool]
#
# Obtém estatisticas de uso da memória do sistema.
#
function mem.stats()
{
	getopt.parse 1 "stats:map:$1" "${@:2}"
	
	local __flag__ __size__
	local -n __ref__=$1

	# Inicializa.
	__ref__=() || return 1

	while IFS=':' read __flag__ __size__; do
		IFS=' ' read __size__ _ <<< $__size__
		__ref__[${__flag__,,}]=$__size__
	done < /proc/meminfo

	return $?
}

# .FUNCTION mem.physical <mem[map]> -> [bool]
#
# Obtém informações da memória física.
#
function mem.physical()
{
	getopt.parse 1 "mem:map:$1" "${@:2}"
	
	local __flag__ __size__
	local -n __ref__=$1

	__ref__=() || return 1

	while IFS=':' read __flag__ __size__; do
		IFS=' ' read __size__ _ <<< $__size__
		__flag__=${__flag__,,}
		[[ $__flag__ == @(memtotal|memfree|memavailable|cached) ]] &&
		__ref__[$__flag__]=$__size__
	done < /proc/meminfo

	return $?
}

# .FUNCTION mem.swap <swap[map]> -> [bool]
#
# Obtém informações da memória virtual.
#
function mem.swap()
{
	getopt.parse 1 "swap:map:$1" "${@:2}"
	
	local __flag__ __size__
	local -n __ref__=$1

	__ref__=() || return 1

	while IFS=':' read __flag__ __size__; do
		IFS=' ' read __size__ _ <<< $__size__
		__flag__=${__flag__,,}
		[[ $__flag__ == @(swaptotal|swapcached|swapfree) ]] &&
		__ref__[$__flag__]=$__size__
	done < /proc/meminfo

	return $?
}

# .MAP stats
#
# Chaves:
#
# directmap4k
# hugepages_total
# vmalloctotal
# anonhugepages
# shmemhugepages
# bounce
# active(file)
# buffers
# inactive(file)
# active
# sunreclaim
# inactive(anon)
# mapped
# swaptotal
# swapcached
# hardwarecorrupted
# commitlimit
# memfree
# slab
# writeback
# nfs_unstable
# inactive
# cached
# hugepagesize
# shmem
# dirty
# hugepages_free
# memavailable
# cmatotal
# kernelstack
# cmafree
# sreclaimable
# unevictable
# shmempmdmapped
# writebacktmp
# memtotal
# hugepages_rsvd
# vmallocused
# directmap2m
# swapfree
# active(anon)
# vmallocchunk
# committed_as
# anonpages
# mlocked
# hugepages_surp
# pagetables
#

# .MAP meminfo
#
# Chaves:
#
# memfree
# cached
# memavailable
# memtotal
#

# .MAP swap
#
# Chaves:
#
# swaptotal
# swapcached
# swapfree
#

# Funções
readonly -f	mem.stats		\
			mem.physical	\
			mem.swap

# /* __MEM_SH__ */
