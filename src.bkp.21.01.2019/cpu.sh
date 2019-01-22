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

[[ $__CPUINFO_SH ]] && return 0

readonly __CPU_SH=1

source builtin.sh

var cpu_t struct_t

cpu_t.__add__ \
	processor		uint \
	vendor_id		str \
	family			str \
	model			uint \
	model_name		str  \
	stepping		uint \
	microcode		hex \
	mhz				float \
	cache_size		size \
	physical_id		uint \
	core_id			uint \
	cores			uint \
	apicid			uint \
	init_apicid		uint \
	flags			str \
	bogomips		float \
	clflush_size	uint \
	address_size	str

# func cpu.getinfo <[cpu_t[]]struct> => [bool]
#
# Obtem as informações do processador e salva no array da estrutura 'cpu_t'.
# Retorna 'true' para sucesso, caso contrário 'false.'
#
# Exemplo:
#
# #!/bin/bash
#
# source cpu.sh
#
# # Implementa um array de 4 elementos.
# var info[4] cpu_t
#
# Obtem as informações.
# cpu.getinfo info
#
# Exibindo as informações.
# info[0].processor
# info[0].model_name
# info[0].mhz
# echo --
# info[1].processor
# info[1].model_name
# info[1].mhz
# echo --
# info[2].processor
# info[2].model_name
# info[2].mhz
# echo --
# info[3].processor
# info[3].model_name
# info[3].mhz
#
# Saída:
#
# 0
# Intel(R) Core(TM) i5-3330 CPU @ 3.00GHz
# 2092.968
# --
# 1
# Intel(R) Core(TM) i5-3330 CPU @ 3.00GHz
# 2599.687
# --
# 2
# Intel(R) Core(TM) i5-3330 CPU @ 3.00GHz
# 2796.328
# --
# 3
# Intel(R) Core(TM) i5-3330 CPU @ 3.00GHz
# 2969.062
#
function cpu.getinfo()
{
	getopt.parse 1 "struct:cpu_t[]:+:$1" ${@:2}

	local flag info i

	i=-1

	while IFS=':' read flag info; do
		printf -v flag '%s' ${flag// /}
		info=${info##+( )}
		case ${flag,,} in
			processor)		$1[$((++i))].processor = "$info";;
			vendor_id)		$1[$i].vendor_id = "$info";;
			cpufamily)		$1[$i].family = "$info";;
			model)			$1[$i].model = "$info";;
			modelname)		$1[$i].model_name = "$info";;
			stepping)		$1[$i].stepping = "$info";;
			microcode)		$1[$i].microcode = "$info";;
			cpumhz)			$1[$i].mhz = "$info";;
			cachesize)		$1[$i].cache_size = "$info";;
			physicalid)		$1[$i].physical_id = "$info";;
			coreid)			$1[$i].core_id = "$info";;
			cpucores)		$1[$i].cores = "$info";;
			apicid)			$1[$i].apicid = "$info";;
			inititalapicid)	$1[$i].init_apicid = "$info";;
			flags)			$1[$i].flags = "$info";;
			bogomips)		$1[$i].bogomips = "$info";;
			clflushsize)	$1[$i].clflush_size = "$info";;
			addresssizes)	$1[$i].address_size = "$info";;
		esac 2>/dev/null || {
			error.trace def 'struct' "cpu_t" '' "'$1[$i]' o índice está fora dos limites do array"
			return $?
		}
	done < /proc/cpuinfo || error.trace def

	return $?
}

source.__INIT__
# /* __CPU_SH */
