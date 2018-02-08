#!/bin/bash

#----------------------------------------------#
# Source:           time.sh
# Data:             23 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__TIME_SH ]] && return 0

readonly __TIME_SH=1

source builtin.sh
source struct.sh

# arquivos
readonly __TIME_TZFILE=/usr/share/zoneinfo/zone.tab
readonly __TIME_CTZFILE=/etc/timezone

# erros
readonly __ERR_TIME_TZNAME='nome do fuso horário inválido'
readonly __ERR_TIME_TZFILE="não foi possível localizar o arquivo"
readonly __ERR_TIME_DATETIME='data/hora inválida'

# meses
readonly JANUARY=1 
readonly FEBRUARY=2 
readonly MARCH=3 
readonly APRIL=4 
readonly MAY=5 
readonly JUNE=6
readonly JULY=7
readonly AUGUST=8
readonly SEPTEMBER=9
readonly OCTOBER=10
readonly NOVEMBER=11
readonly DECEMBER=12

# dias da semana
readonly SUNDAY=0 
readonly MONDAY=1
readonly TUESDAY=2
readonly WEDNESDAY=3
readonly THURSDAY=4
readonly FRIDAY=5
readonly SATURDAY=6

# tempo
readonly NANOSECOND=1
readonly MICROSECOND=$((1000 * NANOSECOND))
readonly MILLISECOND=$((1000 * MICROSECOND))
readonly SECOND=$((1000 * MILLISECOND))
readonly MINUTE=$((60 * SECOND))
readonly HOUR=$((60 * MINUTE))

readonly -a __months=(
[1]='January'
'February'
'March'
'April'
'May'
'June'
'July'
'August'
'September'
'October'
'November'
'December'
)

readonly -a __weekdays=(
'Sunday'
'Monday'
'Tuesday'
'Wednesday'
'Thursday'
'Friday'
'Saturday'
)

var time_t struct_t

time_t.__add__ \
		tm_mon 		uint \
		tm_mday 	uint \
		tm_hour 	uint \
		tm_min 		uint \
		tm_sec 		uint \
		tm_year 	uint \
		tm_yday 	uint \
		tm_wday 	uint \
		tm_isdst 	zone


# func time.today => [str]
#
# Retorna uma representação da data e hora atual.
#
function time.today()
{
	getopt.parse 0 "${@:1}"
	printf "%(%a %b %d %H:%M:%S %Y %z)T\n"
	return 0	
}

# func time.gmtime <[time_t]struct> <[uint]seconds>
#
# Salva em 'struct' a estrutura data e hora convertidos
# a partir do tempo em segundos especificado em 'seconds'.
#
function time.gmtime()
{
	getopt.parse 2 "struct:time_t:+:$1" "seconds:uint:+:$2" "${@:3}"
	
	info_t=($(printf "%(%_m %_d %_H %_M %_S %_Y %_j %_w %z)T" $2))
	
	$1.tm_mon = ${info_t[0]}
	$1.tm_mday = ${info_t[1]}
	$1.tm_hour = ${info_t[2]}
	$1.tm_min = ${info_t[3]}
	$1.tm_sec = ${info_t[4]}
	$1.tm_year = ${info_t[5]}
	$1.tm_yday = ${info_t[6]}
	$1.tm_wday = ${info_t[7]}
	$1.tm_isdst = ${info_t[8]}

	return 0
}

# func time.mtime <[time_t]struct>
#
# Converte a hora atual para um estrutura 'time_t'.
#
function time.mtime()
{
	getopt.parse 1 "struct:time_t:+:$1" "${@:2}"
	
	local info_t

	info_t=($(printf "%(%_m %_d %_H %_M %_S %_Y %_j %_w %z)T"))

	$1.tm_mon = ${info_t[0]}
	$1.tm_mday = ${info_t[1]}
	$1.tm_hour = ${info_t[2]}
	$1.tm_min = ${info_t[3]}
	$1.tm_sec = ${info_t[4]}
	$1.tm_year = ${info_t[5]}
	$1.tm_yday = ${info_t[6]}
	$1.tm_wday = ${info_t[7]}
	$1.tm_isdst = ${info_t[8]}

	return 0
}

# func time.localtime <[time_t]struct> <[uint]seconds> 
# 
# Converte o tempo em segundos para uma estrutura datetime.
#
function time.localtime()
{
	getopt.parse 2 "struct:time_t:+:$1" "seconds:uint:+:$2" ${@:3}
	
	info_t=($(printf "%(%_m %_d %_H %_M %_S %_Y %_j %_w %z)T" $2))

	$1.tm_mon = ${info_t[0]}
	$1.tm_mday = ${info_t[1]}
	$1.tm_hour = ${info_t[2]}
	$1.tm_min = ${info_t[3]}
	$1.tm_sec = ${info_t[4]}
	$1.tm_year = ${info_t[5]}
	$1.tm_yday = ${info_t[6]}
	$1.tm_wday = ${info_t[7]}
	$1.tm_isdst = ${info_t[8]}
			
	return 0
}

# func time.tznames => [timezones]
#
# Retorna uma lista iterável contendo nomes de fuso horários
# suportados pelo sistema.
#
function time.tznames()
{
	getopt.parse 0 ${@:1}
	printf "%s\n" ${!__timezones[@]}
	return 0
}

# func time.tzinfo <[str]tzname> => [tzname|cc|coord|utc]
#
# Retorna informações sobre 'tzname' no formato:
# Nome do fuso horário, código do país, coordenadas e fuso horário.
#
# Exemplo:
#
# $ source time.sh
# $ time.tzinfo 'Asia/Jerusalem'
# Asia/Jerusalem|IL|+314650+0351326|+02:00
#
function time.tzinfo()
{
	getopt.parse 1 "tzname:str:+:$1" ${@:2}
	
	local tzname=$1

	if [[ ${__timezones[$tzname]} ]]; then
		export TZ=$tzname
		utc=$(printf "%(%z)T")
		utc=${utc:0:3}:${utc:3}
		echo "${tzname}|${__timezones[$tzname]}|${utc}"
		unset TZ
	else	
		error.__trace def "tzname" "str" "$tzname" "$__ERR_TIME_TZNAME"; return $?
	fi

	return 0
}

# func time.tzname => [tzname]
#
# Retorna o nome do fuso horário atual do sistema.
#
function time.tzname()
{
	getopt.parse 0 ${@:1}
	
	[[ $TZ ]] && tzname=$TZ || tzname=$(< $__TIME_CTZFILE)
	echo "$tzname"
	return 0
}

# func time.tzgmtime <[struct]name> <[str]tzname>
#
# O mesmo que 'time.gmtime', porém salva a estrutura de hora e data
# do fuso horário especificado em 'tzname'.
#
function time.tzgmtime()
{
	getopt.parse 2 "name:time_t:+:$1" "tzname:str:+:$2" ${@:3}

	time.tzinfo $2 1>/dev/null
	export TZ=$2
	time.gmtime "$1" $(printf '%(%s)T')
	unset TZ
	return 0
}

# func time.tztoday <[str]tzname> => [str]
#
# Retorna a hora e data atual do fuso horário especificado.
#
function time.tztoday()
{
	getopt.parse 1 "tzname:str:+:$1" ${@:2}
	time.tzinfo "$1" 1>/dev/null
	export TZ=$1
	time.today
	unset TZ
	return 0
}

# func time.now => [str]
#
# Retorna a hora atual no formato HH:MM:SS
#
function time.now()
{
	getopt.parse 0 ${@:1}
	printf "%(%H:%M:%S)T\n"
	return 0
}

# func time.date => [str]
#
# Retorna a data atual no formato dd/mm/yyyy
#
function time.date()
{
	getopt.parse 0 ${@:1}
	printf "%(%d/%m/%Y)T\n"
	return 0
}

# func time.hour => [uint]
#
# Retorna um inteiro positivo representando a hora.
#
function time.hour()
{
	getopt.parse 0 ${@:1}
	printf "%(%H)T\n"
	return 0
}

# func time.minute => [uint]
#
# Retorna um inteiro positivo representando os minutos.
#
function time.minute()
{
	getopt.parse 0 ${@:1}
	printf "%(%M)T\n"
	return 0
}

# func time.second => [uint]
#
# Retorna um inteiro positivo representando os segundos.
#
function time.second()
{
	getopt.parse 0 ${@:1}
	printf "%(%S)T\n"
	return 0
}

# func time.month => [uint]
#
# Retorna um inteiro positivo que indica o mês atual,
# representado pelo intervalo: janeiro=1 ... dezembro=12
#
function time.month()
{
	getopt.parse 0 ${@:1}
	printf "%(%m)T\n"
	return 0
}

# func time.month.str => [str]
#
# Retorna a nomenclatura que representa o mês atual.
#
function time.month.str
{
	getopt.parse 0 ${@:1}
	echo "${__months[$(printf "%(%m)T")]}"
	return 0
}

# func time.weekday => [uint]
#
# Retorna um inteiro positivo que indica o dia da semana
# atual, representado pelo intervalo domingo=0 ... sábado=6.
#
function time.weekday()
{
	getopt.parse 0 ${@:1}
	printf "%(%w)T\n"
	return 0
}

# func time.weekday.str => [str]
#
# Retorna a nomenclatura que representa dia da semana atual.
#
function time.weekday.str()
{
	getopt.parse 0 ${@:1}
	echo "${__weekdays[$(time.weekday)]}"
	return 0
}

# func time.year => [uint]
#
# Retorna um inteiro positivo que indica o ano atual.
#
function time.year()
{
	getopt.parse 0 ${@:1}
	printf "%(%Y)T\n"
	return 0
}

# func time.yearday => [uint]
#
# Retorna um inteiro positivo que indica o dia do ano,
# representado pelo intervalo 0..365
#
function time.yearday()
{
	getopt.parse 0 ${@:1}
	printf "%(%j)T\n"
	return 0
}

# func time.day => [uint]
#
# Retorna um inteiro positivo que indica o dia do mês,
# representado pelo intervalo 1..31
#
function time.day()
{
	getopt.parse 0 ${@:1}
	printf "%(%d)T\n"
	return 0
}

# func time.time => [uint]
#
# Retorna um inteiro positivo representando os segundos desde:
# 00:00:00 de 1 de janeiro de 1970 (Hora Universal Sincronizada - UTC)
#
function time.time()
{
	getopt.parse 0 ${@:1}
	printf '%(%s)T\n'
	return 0
}

# func time.ctime <[uint]seconds> => [str]
#
# Converte o tempo em segundos para uma string data e hora local.
#
function time.ctime()
{
	getopt.parse 1 "seconds:uint:+:$1" ${@:2}
	printf "%(%a %b %d %H:%M:%S %Y %z)T\n" $1
	return 0
}

# func time.tzset <[str]tzname>
#
# Define o fuso horário especificado em 'tzname'.
#
function time.tzset()
{
	getopt.parse 1 "tzname:str:+:$1" ${@:2}
	time.tzinfo "$1" 1>/dev/null
	export TZ=$1
	return 0
}

# func time.tzreset
#
# Restaura o fuso horário padrão do sistema.
#
function time.tzreset()
{
	getopt.parse 0 ${@:1}
	unset TZ
	return 0
}

# func time.asctime <[time_t]struct> => [str]
#
# Converte a estrutura 'time_t' para string.
#
function time.asctime()
{
	getopt.parse 1 "struct:time_t:+:$1" ${@:2}

	if	! (time.__check_time $($1.tm_hour) \
								$($1.tm_min) \
								$($1.tm_sec) &&
			time.__check_date 	$($1.tm_wday) \
								$($1.tm_mday) \
								$($1.tm_mon) \
								$($1.tm_year) \
								$($1.tm_yday)) 2>/dev/null; then
		error.__trace def 'time_t' 'struct_t' "$1" "$__ERR_TIME_DATETIME"
		return $?
	fi

	printf "%s %s %d %02d:%02d:%02d %d %s\n" \
		${__weekdays[$($1.tm_wday)]:0:3} \
		${__months[$($1.tm_mon)]:0:3} \
		$($1.tm_mday) \
		$($1.tm_hour) \
		$($1.tm_min) \
		$($1.tm_sec) \
		$($1.tm_year) \
		$($1.tm_isdst)

	return 0
}

# func time.isvalid <[time_t]struct> => [bool]
#
# Retorna 'true' se a data e hora contida na estrutura 'time_t' é valida, caso
# contrário retorna 'false'.
#
function time.isvalid()
{
	getopt.parse 1 "struct:time_t:+:$1" ${@:2}

	time.__check_time 	$($1.tm_hour) \
						$($1.tm_min) \
						$($1.tm_sec) &&
	time.__check_date 	$($1.tm_wday) \
						$($1.tm_mday) \
						$($1.tm_mon) \
						$($1.tm_year) \
						$($1.tm_yday)

	return $?
}

# func time.strftime <[time_t]struct> <[str]format> => [str]
#
# Converte a estrutura 'time_t' para o formato especificado em 'format'.
#
# Códigos de formato:
#
# %a - nome do dia da semana abreviado.
# %A - nome do dia da semana completo.
# %b - nome do mês abreviado.
# %B - nome do mês completo.
# %c - data e Hora local.
# %d - dia do mês.
# %m - mês.
# %y - último dois digitos do ano.
# %Y - ano.
# %H - hora (00..23)
# %I - hora (01..12)
# %M - minuto (00..59)
# %S - segundos (00..59)
# %j - dia do ano (001...366)
# %w - dia da semana (1..7)
# %z - fuso horário.
#
function time.strftime()
{
	getopt.parse 2 "struct:time_t:+:$1" "format:str:+:$2" ${@:3}

	local ch fmt week day month year hour min sec i

	fmt=$2

	if	! (time.__check_time $($1.tm_hour) \
								$($1.tm_min) \
								$($1.tm_sec) &&
			time.__check_date 	$($1.tm_wday) \
								$($1.tm_mday) \
								$($1.tm_mon) \
								$($1.tm_year) \
								$($1.tm_yday)) 2>/dev/null; then
		error.__trace def 'time_t' 'struct_t' "$1" "$__ERR_TIME_DATETIME"
		return $?
	fi

	for ((i=0; i < ${#fmt}; i++)); do
		
		ch=${fmt:$i:2}

		case $ch in
			%a) fmt=${fmt//$ch/${__weekdays[$($1.tm_wday)]:0:3}};;
			%A) fmt=${fmt//$ch/${__weekdays[$($1.tm_wday)]}};;
			%b) fmt=${fmt//$ch/${__months[$($1.tm_mon)]:0:3}};;
			%B) fmt=${fmt//$ch/${__months[$($1.tm_mon)]}};;
			%c)	week=${__weekdays[$($1.tm_wday)]:0:3}
				day=$($1.tm_mday)
				month=${__months[$($1.tm_mon)]:0:3}
				year=$($1.tm_year)
				hour=$($1.tm_hour)
				min=$($1.tm_min)
				sec=$($1.tm_sec)
				fmt=${fmt//$ch/$week $day $month $year $hour:$min:$sec};;

			%d) fmt=${fmt//$ch/$($1.tm_mday)};;
			%m) fmt=${fmt//$ch/$($1.tm_mon)};;
			%y) year=$($1.tm_year); fmt=${fmt//$ch/${year: -2}};;
			%Y) fmt=${fmt//$ch/$($1.tm_year)};;
			%H) fmt=${fmt//$ch/$($1.tm_hour)};;
			%I) fmt=${fmt//$ch/$(($($1.tm_hour)%12))};;
			%M) fmt=${fmt//$ch/$($1.tm_min)};;
			%S) fmt=${fmt//$ch/$($1.tm_sec)};;
			%j) fmt=${fmt//$ch/$($1.tm_yday)};;
			%w) fmt=${fmt//$ch/$($1.tm_wday)};;
			%z) fmt=${fmt//$ch/$($1.tm_isdst)};;
		esac
	done
					
	echo "$fmt"
	
	return 0	
}

# func time.format <[str]format> <[uint]seconds> => [str]
#
# Retorna uma string substituindo os códigos de formatação contidos 
# em 'format' pela data e hora padrão convertidos de 'seconds'.
#
# Código de formato:
#
# %a - nome do dia da semana abreviado.
# %A - nome do dia da semana completo.
# %b - nome do mês abreviado.
# %B - nome do mês completo.
# %c - data e Hora local.
# %d - dia do mês.
# %m - mês.
# %y - último dois digitos do ano.
# %Y - ano.
# %H - hora (00..23)
# %I - hora (01..12)
# %M - minuto (00..59)
# %S - segundos (00..59)
# %j - dia do ano (001...366)
# %w - dia da semana (1..7)
# %z - fuso horário.
#
function time.format(){
	getopt.parse 2 "format:str:+:$1" "seconds:uint:+:$2" ${@:3}
	printf "%($1)T\n" $2
	return 0
}

function time.__check_date()
{
	local week=$1 day=$2 month=$3 year=$4 yearday=$5 d=$2 m=$3 y=$4 w tyd 
	local days=('0 31 28 31 30 31 30 31 31 30 31 30 31' 
				'0 31 29 31 30 31 30 31 31 30 31 30 31')

	leap_year=$(((year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 1 : 0))
	tyd=$((leap_year == 0 ? 365 : 366))
	w=$(($((d+=m<3 ? y--: y-2,23*m/9+d+4+y/4-y/100+y/400))%7))

	days=(${days[$leap_year]})

	if	((month > 12 			|| month < 1))	||
		((day > ${days[$month]} || day < 1)) 	||
		((year < 1900)) 		||
		((w != week )) 			||
		((yearday < 1 			|| yearday > tyd)); then
		return 1
	fi
	
	return 0	
}

function time.__check_time()
{
	# time.__check_time <hour> <min> <sec> <fmt [12/24]>
	local hour=$1 min=$2 sec=$3 fmt
	
	fmt=$((${4:-1} == 1 ? 23 : 12))

	if	(( hour > fmt || hour < 1 )) ||
		(( min > 59   || min < 0 )) ||
		(( sec > 59   || sec < 0 )); then
		return 1
	fi
	
	return 0	
}

function time.__init()
{
	if [[ ! -e $__TIME_TZFILE ]]; then
		error.__trace def '' '' '' "$__ERR_TIME_TZFILE '$__TIME_TZFILE'"; return $?
	elif [[ ! -e $__TIME_CTZFILE ]]; then
		error.__trace def '' '' '' "$__ERR_TIME_TZFILE '$__TIME_CTZFILE'"; return $?
	fi

	declare -Ag __timezones

	while read cc coord tzname _; do
		[[ $cc =~ ^\s*# ]] || __timezones[$tzname]="$cc|$coord"
	done < $__TIME_TZFILE
	
	declare -r __timezones
}

time.__init

source.__INIT__
# /* __TIME_SH */
