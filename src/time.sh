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

[ -v __TIME_SH__ ] && return 0

source builtin.sh

# .FUNCTION time.time -> [uint]
#
# Retorna o tempo em segundos decorridos desde 1970-01-01 00:00:00 UTC
#
function time.time()
{
	getopt.parse 0 "$@"
	printf '%(%s)T\n'
	return $?
}

# .FUNCTION time.now -> [str]
#
# Retorna uma representação da data e hora atual.
#
function time.now()
{
	getopt.parse 0 "$@"
	printf "%(%a %b %d %H:%M:%S %Y %z)T\n"
}

# .FUNCTION time.localtime <time[map]> -> [bool]
#
# Converte a hora atual em um mapa time.
#
function time.localtime()
{
	getopt.parse 1 "time:map:$1" "${@:2}"
	
	local -n __ref__=$1
	local __tm__
	
	IFS=' ' read -a __tm__ <<< $(printf "%(%_m %_d %_H %_M %_S %_Y %_j %_w %z)T")
	
	__ref__[tm_mon]=${__tm__[0]}
	__ref__[tm_mday]=${__tm__[1]}
	__ref__[tm_hour]=${__tm__[2]}
	__ref__[tm_min]=${__tm__[3]}
	__ref__[tm_sec]=${__tm__[4]}
	__ref__[tm_year]=${__tm__[5]}
	__ref__[tm_yday]=${__tm__[6]}
	__ref__[tm_wday]=${__tm__[7]}
	__ref__[tm_zone]=${__tm__[8]}
	__ref__[tm_isdst]=$(time.__getdst__)
	
	return $?
}

# .FUNCTION time.gmtime <seconds[uint]> <time[map]> -> [bool]
#
# Converte o tempo em segundos em um mapa de tempo.
#
function time.gmtime()
{
	getopt.parse 2 "seconds:uint:$1" "time:map:$2" "${@:3}"
	
	local -n __ref__=$2
	local __tm__
	
	IFS=' ' read -a __tm__ <<< $(printf "%(%_m %_d %_H %_M %_S %_Y %_j %_w %z)T" $1)
	
	__ref__[tm_mon]=${__tm__[0]}
	__ref__[tm_mday]=${__tm__[1]}
	__ref__[tm_hour]=${__tm__[2]}
	__ref__[tm_min]=${__tm__[3]}
	__ref__[tm_sec]=${__tm__[4]}
	__ref__[tm_year]=${__tm__[5]}
	__ref__[tm_yday]=${__tm__[6]}
	__ref__[tm_wday]=${__tm__[7]}
	__ref__[tm_zone]=${__tm__[8]}
	__ref__[tm_isdst]=$(time.__getdst__)

	return $?
}

# .FUNCTION time.ctime <seconds[uint]> -> [str]|[bool]
#
# Converte o tempo em segundos para uma string de hora local.
#
function time.ctime()
{
	getopt.parse 1 "seconds:uint:$1" "${@:2}"
	
	printf "%(%a %b %d %H:%M:%S %Y %z)T\n" $1
	return $?
}

# .FUNCTION time.timezone -> [str]|[bool]
#
# Retorna o fuso horário do sistema.
#
function time.timezone()
{
	getopt.parse 0 "$@"
	echo "$(< /etc/timezone)"
	return $?
}

# .FUNCTION time.asctime <time[map]> -> [str]|[bool]
#
# Converte o mapa 'time' em uma string de representação de data e hora.
#
function time.asctime()
{
	getopt.parse 1 "time:map:$1" "${@:2}"
	
	local -n __ref__=$1
	local __strm__=([1]=Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
	local __strw__=(Sun Mon Tue Wed Thu Fri Sat)

	if ! (time.__chktime__	${__ref__[tm_hour]}	\
							${__ref__[tm_min]}	\
							${__ref__[tm_sec]}	&&
		 time.__chkdate__	${__ref__[tm_wday]}	\
							${__ref__[tm_mday]}	\
							${__ref__[tm_mon]}	\
							${__ref__[tm_year]}	\
							${__ref__[tm_yday]}); then
		error.error "'$1' mapa time inválido"
		return 1
	fi

	printf "%s %s %d %02d:%02d:%02d %d %(%z)T\n" 	\
			${__strw__[${__ref__[tm_wday]}]}		\
			${__strm__[${__ref__[tm_mon]}]}			\
			${__ref__[tm_mday]}						\
			${__ref__[tm_hour]}						\
			${__ref__[tm_min]}						\
			${__ref__[tm_sec]}						\
			${__ref__[tm_year]}

	return $?
}

function time.__getdst__()
{
	local tzinfo

	while read tzinfo; do
		[[ $tzinfo =~ isdst=(0|1) ]] && break
	done < <(zdump -v $(< /etc/timezone))

	echo "${BASH_REMATCH[1]}"

	return $?
}

function time.__chktime__()
{
	# hour=$1, min=$2, sec=$3
	[[ $1 -ge 0 && $1 -le 23 ]] &&
	[[ $2 -ge 0 && $2 -le 59 ]] &&
	[[ $3 -ge 0 && $3 -le 59 ]]

	return $?
}

function time.__chkdate__()
{
    local week=$1 day=$2 month=$3 year=$4 yearday=$5 d=$2 m=$3 y=$4 w tyd
    local days=('0 31 28 31 30 31 30 31 31 30 31 30 31'
                '0 31 29 31 30 31 30 31 31 30 31 30 31')

    leap_year=$(((year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 1 : 0))
    tyd=$((leap_year == 0 ? 365 : 366))
    w=$(($((d+=m<3 ? y--: y-2,23*m/9+d+4+y/4-y/100+y/400))%7))

    days=(${days[$leap_year]})

	[[ $month -ge 1 && $month -le 12 			]]	&&
	[[ $day -ge 1 && $day -le ${days[$month]} 	]]	&&
	[[ $year -ge 1900 							]] 	&&
	[[ $w == $week 								]]	&&
	[[ $yearday -ge 1 && $yearday -le $tyd 		]]

	return $?
}

# .MAP time
#
# Chaves:
#
# tm_mon    /* mês (1..12) */
# tm_mday   /* dia do mês (1..31) */
# tm_hour   /* hora (0..23) */
# tm_min    /* minuto (0..59) */
# tm_sec    /* segundo (0..60) */
# tm_year   /* ano */
# tm_yday   /* dia do ano (1..366) */
# tm_wday   /* dia da semana (0..6); 0 é domingo */
# tm_zone   /* Fuso horário */
# tm_isdst  /* Horário de verão */
#

# Funções (somente-leitura)
readonly -f time.time			\
			time.now			\
			time.localtime		\
			time.gmtime			\
			time.ctime			\
			time.timezone		\
			time.asctime		\
			time.__getdst__		\
			time.__chktime__	\
			time.__chkdate__

# /* __TIME_SH__ */
