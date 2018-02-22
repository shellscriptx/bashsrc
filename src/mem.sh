#!/bin/bash

[[ $__MEM_SH ]] && return 0

readonly __MEM_SH=1

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

function mem.getinfo()
{
	getopt.parse 1 "struct:memstat_t:+:$1" "${@:2}"
	
	local flag size
	
	while read flag size _; do
		flag=${flag,,}
		case ${flag%:} in
			'memtotal') 			$1.mem.total = $size;;
			'memfree')				$1.mem.free = $size;;
			'memavailable')			$1.mem.avail = $size;; 	
			'buffers')				$1.buffers = $size;;
			'cached')				$1.mem.cached = $size;;
			'swapcached')			$1.swap.cached = $size;;
			'active')				$1.active = $size;;
			'inactive')				$1.inactive = $size;;
			'active(anon)')			$1.active_anon = $size;;
			'inactive(anon)')		$1.inactive_anon = $size;;
			'active(file)')			$1.active_file = $size;;
			'inactive(file)')		$1.inactive_file = $size;;
			'unevictable')			$1.unevictable = $size;;
			'mlocked')				$1.mlocked = $size;;
			'swaptotal')			$1.swap.total = $size;;
			'swapfree')				$1.swap.free = $size;;
			'dirty')				$1.dirty = $size;;
			'writeback')			$1.write_back = $size;;
			'anonpages')			$1.anon_pages = $size;;
			'mapped')				$1.mapped = $size;;
			'shmem')				$1.shmem = $size;;
			'slab')					$1.slab = $size;;
			'sreclaimable')			$1.sreclaimable = $size;;
			'sunreclaim')			$1.sunreclaim = $size;;
			'kernelstack')			$1.kernel_stack = $size;;
			'pagetables')			$1.page_tables = $size;;
			'nfs_unstable')			$1.nfs_unstable = $size;;
			'bounce')				$1.bounce = $size;;
			'writebacktmp')			$1.write_back_tmp = $size;;
			'commitlimit')			$1.commit_limit = $size;;
			'committed_as')			$1.committed_as = $size;;
			'vmalloctotal')			$1.vm_alloc_total = $size;;
			'vmallocused')			$1.vm_alloc_used = $size;;
			'vmallocchunk')			$1.vm_alloc_chunk = $size;;
			'hardwarecorrupted')	$1.hardware_corrupted = $size;;
			'anonhugepages')		$1.anonhuge_pages = $size;;
			'cmatotal')				$1.cma_total = $size;;
			'cmafree')				$1.cma_free = $size;;
			'hugepages_total')		$1.huge_pages_total = $size;;
			'hugepages_free')		$1.huge_pages_free = $size;;
			'hugepages_rsvd')		$1.huge_pages_rsvd = $size;;
			'hugepages_surp')		$1.huge_pages_surp = $size;;
			'hugepagesize')			$1.huge_page_size = $size;;
			'directmap4k')			$1.direct_map_4k = $size;;
			'directmap2m')			$1.direct_map_2m = $size;;
		esac
	done < /proc/meminfo || {
		error.trace def
		return $?
	}

	return 0
}

source.__INIT__
