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

var st_time struct_t

st_time.__add__		tm_mon \
					tm_mday \
					tm_hour \
					tm_min \
					tm_sec \
					tm_year \
					tm_yday \
					tm_wday \
					tm_isdst

st_time.__readonly__

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

# func time.gmtime <[st_time]struct> <[uint]seconds>
#
# Salva em 'datetime' a estrutura data e hora convertidos
# a partir do tempo em segundos especificado em 'seconds'.
#
# Membros da estrutura:
#
# tm_sec    - Segundos (0-60)
# tm_min    - Minutos (0-59)
# tm_hour   - Horas	(0-23)
# tm_mday   - Dia do mês (1-31)
# tm_mon    - Mês (1-12)
# tm_year   - Ano (1900)
# tm_wday   - Dia da semana (0-6, domingo = 0)
# tm_yday   - Dia do ano (0-365)
# tm_isdst  - Fuso horário
#
# Exemplo:
#
# #!/bin/bash
# source time.sh
#
# # Salva em 'dt' a hora atual.
# time.gmtime dt
#
# # Exibindo os campos da hora.
# echo 'Horas:' ${dt[tm_hour]}
# echo 'Minutos:' ${dt[tm_min]}
# echo 'Segundos:' ${dt[tm_sec]}
#
# # FIM
#
# $ ./datetime.sh
# Horas: 11
# Minutos: 52
# Segundos: 57
#
function time.gmtime()
{
	getopt.parse 2 "struct:st_time:+:$1" "seconds:uint:+:$2" "${@:3}"
	
	info_t=($(printf "%(%_m %_d %_H %_M %_S %Y %_j %w %z)T" $2))
	
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

# func time.mtime <[st_time]struct>
#
# Converte a hora atual para um estrutura 'st_time'.
#
function time.mtime()
{
	getopt.parse 1 "struct:st_time:+:$1" "${@:2}"
	
	local info_t

	info_t=($(printf "%(%_m %_d %_H %_M %_S %Y %_j %w %z)T"))

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

# func time.localtime <[uint]seconds> => [map]
# 
# Converte o tempo em segundos para uma estrutura datetime.
#
# Exemplo:
#
# #!/bin/bash
# # script: datetime.sh
#
# source time.sh
#
# # Convertendo os segundos para a estrutura [map]datetime.
# seg=$(time.time)
# echo 'Segundos:' $seg
# time.localtime dt $seg
#
# echo 'Listando estrutura:'
# map.list dt
#
# # FIM
#
# $ ./datetime.sh
# Segundos: 1511404409
# Listando estrutura:
#
# tm_wday|4
# tm_mon|11
# tm_sec|29
# tm_hour|0
# tm_isdst|-0200
# tm_min|33
# tm_mday|23
# tm_yday|327
# tm_year|2017
#
function time.localtime()
{
	getopt.parse 2 "struct:st_time:+:$1" "seconds:uint:+:$2" ${@:3}
	
	info_t=($(printf "%(%_m %_d %_H %_M %_S %Y %_j %w %z)T" $2))

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
	getopt.parse 2 "name:st_time:+:$1" "tzname:str:+:$2" ${@:3}

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
	printf "%(%_H)T\n"
	return 0
}

# func time.minute => [uint]
#
# Retorna um inteiro positivo representando os minutos.
#
function time.minute()
{
	getopt.parse 0 ${@:1}
	printf "%(%_M)T\n"
	return 0
}

# func time.second => [uint]
#
# Retorna um inteiro positivo representando os segundos.
#
function time.second()
{
	getopt.parse 0 ${@:1}
	printf "%(%_S)T\n"
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
	printf "%(%_m)T\n"
	return 0
}

# func time.month.str => [str]
#
# Retorna a nomenclatura que representa o mês atual.
#
function time.month.string
{
	getopt.parse 0 ${@:1}
	echo "${__months[$(printf "%(%_m)T")]}"
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
function time.weekday.string()
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
	printf "%(%_j)T\n"
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
	printf "%(%_d)T\n"
	return 0
}

# func time.time => [uint]
#
# Retorna um inteiro positivo representando os segundos desde:
# qua dez 31 21:00:00 1969.
#
function time.time()
{
	getopt.parse 0 ${@:1}
	printf '%(%s)T\n'
	return 0
}

# func time.ctime => [str]
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

# func time.asctime <[st_time]struct> => [str]
#
# Converte a estrutura 'st_time' para string.
#
function time.asctime()
{
	getopt.parse 1 "struct:st_time:+:$1" ${@:2}

	if	! (time.__check_time $($1.tm_hour) \
								$($1.tm_min) \
								$($1.tm_sec) &&
			time.__check_date 	$($1.tm_wday) \
								$($1.tm_mday) \
								$($1.tm_mon) \
								$($1.tm_year) \
								$($1.tm_yday)) 2>/dev/null; then
		error.__trace def 'st_time' 'struct_t' "$1" "$__ERR_TIME_DATETIME"
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

# func time.strftime <[st_time]struct> <[str]format> => [str]
#
# Converte a estrutura 'st_time' para o formato especificado em 'format'.
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
	getopt.parse 2 "struct:st_time:+:$1" "format:str:+:$2" ${@:3}

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
		error.__trace def 'st_time' 'struct_t' "$1" "$__ERR_TIME_DATETIME"
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

function time.__check_date()
{
	# time.__check_date <week> <day> <month> <year> <yearday>
	local week=$1 day=$2 month=$3 year=$4 yearday=$5 d=$2 m=$3 y=$4 w tyd 
	local days=('0 31 28 31 30 31 30 31 31 30 31 30 31' 
				'0 31 29 31 30 31 30 31 31 30 31 30 31')

	leap_year=$(((year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 1 : 0))
	tyd=$((leap_year == 0 ? 365 : 366))
	w=$(($((d+=m<3 ? y--: y-2,23*m/9+d+4+y/4-y/100+y/400))%7))

	echo $w - $week
	days=(${days[$leap_year]})

	if	((month > 12 			|| month < 1))	||
		((day > ${days[$month]} || day < 1)) 	||
		((year < 1900)) 		||
#		((w != week )) 			||
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
