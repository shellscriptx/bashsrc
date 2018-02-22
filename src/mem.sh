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

# *
# * Implementa funções para obter informações sobre o uso da memória
# * no sistema.
# *
# * Os valores obtidos são representados em Kilobyte's.
# *

[[ $__MEM_SH ]] && return 0

readonly __MEM_SH=1

source builtin.sh
source struct.sh

var memstat_t struct_t
var mem_t struct_t
var swap_t struct_t

mem_t.__add__ \
	total	uint \
	free	uint \
	avail	uint \
	cached	uint  

swap_t.__add__ \
	total	uint \
	free	uint \
	cached 	uint \

memstat_t.__add__ \
	mem					mem_t \
	swap				swap_t \
	buffers				uint \
	cached				uint \
	active	 			uint \
	inactive			uint \
	active_anon			uint \
	inactive_anon		uint \
	active_file			uint \
	inactive_file		uint \
	unevictable	 		uint \
	mlocked	 			uint \
	dirty	 			uint \
	write_back			uint \
	anon_pages			uint \
	mapped				uint \
	shmem				uint \
	slab				uint \
	sreclaimable		uint \
	sunreclaim	 		uint \
	kernel_stack		uint \
	page_tables			uint \
	nfs_unstable		uint \
	bounce				uint \
	write_back_tmp		uint \
	commit_limit		uint \
	committed_as		uint \
	vm_alloc_total		uint \
	vm_alloc_used		uint \
	vm_alloc_chunk		uint \
	hardware_corrupted	uint \
	anonhuge_pages		uint \
	cma_total			uint \
	cma_free			uint \
	huge_pages_total	uint \
	huge_pages_free		uint \
	huge_pages_rsvd		uint \
	huge_pages_surp		uint \
	huge_page_size		uint \
	direct_map_4k	 	uint \
	direct_map_2m	 	uint

# func mem.stats <[memstat_t]struct> => [bool]
#
# Obtem as estatisticas de uso da memória do sistema e salva na estrutura 'memstat_t'.
# Retorna 'true' para sucesso, caso contrário 'false'.
#
function mem.stats()
{
	getopt.parse 1 "struct:memstat_t:+:$1" "${@:2}"
	mem.__get_mem_info stats $1
	return $?
}

# func mem.physical <[mem_t]struct> => [bool]
#
# Obtem informações da memória física e salva na estrutura 'mem_t'.
# Retorna 'true' para sucesso, caso contrário 'false'.
#
function mem.physical()
{
	getopt.parse 1 "struct:mem_t:+:$1" "${@:2}"
	mem.__get_mem_info mem $1
	return $?
}

# func mem.swap <[swap_t]struct> => [bool]
#
# Obtem informações da memória virtual e salva na estrutura 'swap_t'.
# Retorna 'true' para sucesso, caso contrário 'false'.
#
function mem.swap()
{
	getopt.parse 1 "struct:swap_t:+:$1" "${@:2}"
	mem.__get_mem_info swap $1
	return $?
}

function mem.__get_mem_info()
{
	local flag size
	
	while read flag size _; do
		flag=${flag,,}
		flag=${flag%:}
		case $1 in
			stats)
				case $flag in
					'memtotal') 			$2.mem.total = $size;;
					'memfree')				$2.mem.free = $size;;
					'memavailable')			$2.mem.avail = $size;; 	
					'buffers')				$2.buffers = $size;;
					'cached')				$2.mem.cached = $size;;
					'swapcached')			$2.swap.cached = $size;;
					'active')				$2.active = $size;;
					'inactive')				$2.inactive = $size;;
					'active(anon)')			$2.active_anon = $size;;
					'inactive(anon)')		$2.inactive_anon = $size;;
					'active(file)')			$2.active_file = $size;;
					'inactive(file)')		$2.inactive_file = $size;;
					'unevictable')			$2.unevictable = $size;;
					'mlocked')				$2.mlocked = $size;;
					'swaptotal')			$2.swap.total = $size;;
					'swapfree')				$2.swap.free = $size;;
					'dirty')				$2.dirty = $size;;
					'writeback')			$2.write_back = $size;;
					'anonpages')			$2.anon_pages = $size;;
					'mapped')				$2.mapped = $size;;
					'shmem')				$2.shmem = $size;;
					'slab')					$2.slab = $size;;
					'sreclaimable')			$2.sreclaimable = $size;;
					'sunreclaim')			$2.sunreclaim = $size;;
					'kernelstack')			$2.kernel_stack = $size;;
					'pagetables')			$2.page_tables = $size;;
					'nfs_unstable')			$2.nfs_unstable = $size;;
					'bounce')				$2.bounce = $size;;
					'writebacktmp')			$2.write_back_tmp = $size;;
					'commitlimit')			$2.commit_limit = $size;;
					'committed_as')			$2.committed_as = $size;;
					'vmalloctotal')			$2.vm_alloc_total = $size;;
					'vmallocused')			$2.vm_alloc_used = $size;;
					'vmallocchunk')			$2.vm_alloc_chunk = $size;;
					'hardwarecorrupted')	$2.hardware_corrupted = $size;;
					'anonhugepages')		$2.anonhuge_pages = $size;;
					'cmatotal')				$2.cma_total = $size;;
					'cmafree')				$2.cma_free = $size;;
					'hugepages_total')		$2.huge_pages_total = $size;;
					'hugepages_free')		$2.huge_pages_free = $size;;
					'hugepages_rsvd')		$2.huge_pages_rsvd = $size;;
					'hugepages_surp')		$2.huge_pages_surp = $size;;
					'hugepagesize')			$2.huge_page_size = $size;;
					'directmap4k')			$2.direct_map_4k = $size;;
					'directmap2m')			$2.direct_map_2m = $size;;
				esac
				;;
			mem)
				case $flag in
					'memtotal') 			$2.total = $size;;
					'memfree')				$2.free = $size;;
					'memavailable')			$2.avail = $size;; 	
					'cached')				$2.cached = $size;;
				esac			
				;;
			swap)
				case $flag in
					'swapcached')			$2.cached = $size;;
					'swaptotal')			$2.total = $size;;
					'swapfree')				$2.free = $size;;
				esac
				;;
			*) false;;
		esac 2>/dev/null || {
			error.trace def
			return $?
		}
	done < /proc/meminfo 

	return $?
}

source.__INIT__
# /* __MEM_SH */
