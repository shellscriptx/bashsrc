#!/bin/bash

#----------------------------------------------#
# Source:           time.sh
# Data:             23 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__TIME_SRC ]] && return 0

readonly __TIME_SRC=1

source builtin.sh
source map.sh

# arquivos
readonly __TIME_TZFILE=/usr/share/zoneinfo/zone.tab
readonly __TIME_CTZFILE=/etc/timezone

# erros
readonly __TIME_ERR_TZNAME='nome do fuso horário inválido'
readonly __TIME_ERR_TZFILE="não foi possível localizar o arquivo"
readonly __TIME_ERR_DATETIME='data/hora inválida'

# meses
readonly time_january=1 
readonly time_february=2 
readonly time_march=3 
readonly time_april=4 
readonly time_may=5 
readonly time_june=6
readonly time_july=7
readonly time_august=8
readonly time_september=9
readonly time_october=10
readonly time_november=11
readonly time_december=12

# dias das semana
readonly time_sunday=0 
readonly time_monday=1
readonly time_tuesday=2
readonly time_wednesday=3
readonly time_thursday=4
readonly time_friday=5
readonly time_saturday=6

# tempo
readonly time_nanosecond=1
readonly time_microsecond=$((1000 * time_nanosecond))
readonly time_millisecond=$((1000 * time_microsecond))
readonly time_second=$((1000 * time_millisecond))
readonly time_minute=$((60 * time_second))
readonly time_hour=$((60 * time_minute))
			
readonly -a __months=(
[1]='janeiro'
'fevereiro'
'março'
'abril'
'maio'
'junho'
'julho'
'agosto'
'setembro'
'outubro'
'novembro'
'dezembro'
)

readonly -a __weekdays=(
'domingo'
'segunda'
'terça'
'quarta'
'quinta'
'sexta'
'sábado'
)


# func time.today => [str]
#
# Retorna uma representação da data e hora atual.
#
function time.today()
{
	getopt.parse "-:null:-:$*"
	printf "%(%a %b %d %H:%M:%S %Y %z)T\n"
	return 0	
}

# func time.gmtime <[map]datetime> <[uint]seconds>
#
# Salva em 'datetime' a estrutura data e hora convertidos
# a partir do tempo em segundos especificado em 'seconds'.
#
# map[chave] 
#
# chaves:
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
# # script: datetime.sh
#
# source time.sh
#
# # Declara variável do tipo map.
# declare -A dt
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
	getopt.parse "name:map:+:$1" "seconds:uint:+:$2"
	
	declare -n  __map_ref=$1
	local __info

	__info=($(printf "%(%_m %_d %_H %_M %_S %Y %_j %w %z)T" $2))
		
	__map_ref[tm_mon]=${__info[0]}
	__map_ref[tm_mday]=${__info[1]}
	__map_ref[tm_hour]=${__info[2]}
	__map_ref[tm_min]=${__info[3]}
	__map_ref[tm_sec]=${__info[4]}
	__map_ref[tm_year]=${__info[5]}
	__map_ref[tm_yday]=${__info[6]}
	__map_ref[tm_wday]=${__info[7]}
	__map_ref[tm_isdst]=${__info[8]}

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
# source map.sh
#
# # Declarando o tipo map.
# declare -A dt
#
# # Convertendo os segundos para a estrutura [map]datetime.
# seg=$(time.time)
# echo 'Segundos:' $seg
# echo -n 'Map: '
# time.localtime $seg
#
# # Atribuindo a estrutura a variável 'dt'.
# # Obs: é necessário utilizar o comando 'eval' para realizar
# # a expansão e atribuição da estrutura. Caso contrário um
# # erro será retornado.
# eval dt=($(time.localtime $seg))
# echo 'Listando estrutura:'
# map.list dt
#
# # FIM
#
# $ ./datetime.sh
# Segundos: 1511404409
# Map: [tm_mon]=11 [tm_mday]=23 [tm_hour]=0 [tm_min]=33 [tm_sec]=29 [tm_year]=2017 [tm_yday]=327 [tm_wday]=4 [tm_isdst]=-0200
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
	getopt.parse "seconds:uint:+:$1"	
	
	local info=($(printf "%(%_m %_d %_H %_M %_S %Y %_j %w %z)T" $2))
	
	printf '[tm_mon]=%d ' 		${info[0]}
	printf '[tm_mday]=%d ' 		${info[1]}
	printf '[tm_hour]=%d ' 		${info[2]}
	printf '[tm_min]=%d '		${info[3]}
	printf '[tm_sec]=%d '		${info[4]}
	printf '[tm_year]=%d '		${info[5]}
	printf '[tm_yday]=%d '		${info[6]}
	printf '[tm_wday]=%d '		${info[7]}
	printf '[tm_isdst]=%s\n'	${info[8]}
			
	return 0
}

# func time.tznames => [timezones]
#
# Retorna uma lista iterável contendo nomes de fuso horários
# suportados pelo sistema.
#
function time.tznames()
{
	getopt.parse "-:null:-:$*"
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
	getopt.parse "tzname:str:+:$1"
	
	local tzname=$1

	if [[ ${__timezones[$tzname]} ]]; then
		export TZ=$tzname
		utc=$(printf "%(%z)T")
		utc=${utc:0:3}:${utc:3}
		echo "${tzname}|${__timezones[$tzname]}|${utc}"
		unset TZ
	else	
		error.__exit "tzname" "str" "$tzname" "$__TIME_ERR_TZNAME"
	fi

	return 0
}

# func time.tzname => [tzname]
#
# Retorna o nome do fuso horário atual do sistema.
#
function time.tzname()
{
	getopt.parse "-:null:-:$*"
	
	[[ $TZ ]] && tzname=$TZ || tzname=$(< $__TIME_CTZFILE)
	echo "$tzname"
	return 0
}

# func time.tzgmtime <[map]name> <[str]tzname>
#
# O mesmo que 'time.gmtime', porém salva a estrutura de hora e data
# do fuso horário especificado em 'tzname'.
#
function time.tzgmtime()
{
	getopt.parse "name:map:+:$1"

	time.tzinfo $2 1>/dev/null
	export TZ=$2
	time.gmtime "$1"
	unset TZ
	return 0
}

# func time.tztoday <[str]tzname> => [str]
#
# Retorna a hora e data atual do fuso horário especificado.
#
function time.tztoday()
{
	getopt.parse "tzname:str:+:$1"
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
	getopt.parse "-:null:-:$*"
	printf "%(%H:%M:%S)T\n"
	return 0
}

# func time.date => [str]
#
# Retorna a data atual no formato dd/mm/yyyy
#
function time.date()
{
	getopt.parse "-:null:-:$*"
	printf "%(%d/%m/%Y)T\n"
	return 0
}

# func time.hour => [uint]
#
# Retorna um inteiro positivo representando a hora.
#
function time.hour()
{
	getopt.parse "-:null:-:$*"
	printf "%(%_H)T\n"
	return 0
}

# func time.minute => [uint]
#
# Retorna um inteiro positivo representando os minutos.
#
function time.minute()
{
	getopt.parse "-:null:-:$*"
	printf "%(%_M)T\n"
	return 0
}

# func time.second => [uint]
#
# Retorna um inteiro positivo representando os segundos.
#
function time.second()
{
	getopt.parse "-:null:-:$*"
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
	getopt.parse "-:null:-:$*"
	printf "%(%_m)T\n"
	return 0
}

# func time.month.str => [str]
#
# Retorna a nomenclatura que representa o mês atual.
#
function time.month.str
{
	getopt.parse "-:null:-:$*"
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
	getopt.parse "-:null:-:$*"
	printf "%(%w)T\n"
	return 0
}

# func time.weekday.str => [str]
#
# Retorna a nomenclatura que representa dia da semana atual.
#
function time.weekday.str()
{
	getopt.parse "-:null:-:$*"
	echo "${__weekdays[$(time.weekday)]}"
	return 0
}

# func time.year => [uint]
#
# Retorna um inteiro positivo que indica o ano atual.
#
function time.year()
{
	getopt.parse "-:null:-:$*"
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
	getopt.parse "-:null:-:$*"
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
	getopt.parse "-:null:-:$*"
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
	getopt.parse "-:null:-:$*"
	printf '%(%s)T\n'
	return 0
}

# func time.ctime => [str]
#
# Converte o tempo em segundos para uma string data e hora local.
#
function time.ctime()
{
	getopt.parse "seconds:int:+:$1"
	printf "%(%a %b %d %H:%M:%S %Y %z)T\n" $1
	return 0
}

# func time.tzset <[str]tzname>
#
# Define o fuso horário especificado em 'tzname'.
#
function time.tzset()
{
	getopt.parse "tzname:str:+:$1"
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
	getopt.parse "-:null:-:$*"
	unset TZ
	return 0
}

# func time.asctime <[map]datetime> => [str]
#
# Converte a estrutura 'datetime' para string.
#
function time.asctime()
{
	getopt.parse "datetime:map:+:$1"

	declare -n __asctime_map=$1
	
	if ! (time.__check_time ${__asctime_map[tm_hour]} \
							${__asctime_map[tm_min]} \
							${__asctime_map[tm_sec]} &&
		  time.__check_date ${__asctime_map[tm_wday]} \
							${__asctime_map[tm_mday]} \
							${__asctime_map[tm_mon]} \
							${__asctime_map[tm_year]} \
							${__asctime_map[tm_yday]}); then
		
		error.__exit 'datetime' 'map' "\n$(map.list $1)" "$__TIME_ERR_DATETIME"
	fi
	
	printf "%s %s %d %02d:%02d:%02d %d %s\n" \
		${__weekdays[${__asctime_map[tm_wday]}]:0:3} \
		${__months[${__asctime_map[tm_mon]}]:0:3} \
		${__asctime_map[tm_mday]} \
		${__asctime_map[tm_hour]} \
		${__asctime_map[tm_min]} \
		${__asctime_map[tm_sec]} \
		${__asctime_map[tm_year]} \
		${__asctime_map[tm_isdst]}
		
	return 0	
}

# func time.strftime <[str]format> <[map]datetime> => [str]
function time.strftime()
{
	getopt.parse "format:str:+:$1" "datetime:map:+:$2"

	declare -n __dt_ref=$2
	local __fmt=$1

	if ! (time.__check_time ${__dt_ref[tm_hour]} \
							${__dt_ref[tm_min]} \
							${__dt_ref[tm_sec]} &&
		  time.__check_date ${__dt_ref[tm_wday]} \
							${__dt_ref[tm_mday]} \
							${__dt_ref[tm_mon]} \
							${__dt_ref[tm_year]} \
							${__dt_ref[tm_yday]}); then
		
		error.__exit 'datetime' 'map' "\n$(map.list $2)" "$__TIME_ERR_DATETIME"
	fi
	
	for ((__i=0; __i < ${#__fmt}; __i++)); do
		
		__ch=${__fmt:$__i:2}
		
		case $__ch in
			%a) __fmt=${__fmt//$__ch/${__weekdays[${__dt_ref[tm_wday]}]:0:3}};;
			%A) __fmt=${__fmt//$__ch/${__weekdays[${__dt_ref[tm_wday]}]}};;
			%b) __fmt=${__fmt//$__ch/${__months[${__dt_ref[tm_mon]}]:0:3}};;
			%B) __fmt=${__fmt//$__ch/${__months[${__dt_ref[tm_mon]}]}};;
			%c)	__week=${__weekdays[${__dt_ref[tm_wday]}]:0:3}
				__day=${__dt_ref[tm_mday]}
				__month=${__months[${__dt_ref[tm_mon]}]:0:3}
				__year=${__dt_ref[tm_year]}
				__hour=${__dt_ref[tm_hour]}
				__min=${__dt_ref[tm_min]}
				__sec=${__dt_ref[tm_sec]}
				__fmt=${__fmt//$__ch/${__week} ${__day} ${__month} ${__year} ${__hour}:${__min}:${__sec}};;

			%d) __fmt=${__fmt//$__ch/${__dt_ref[tm_mday]}};;
			%m) __fmt=${__fmt//$__ch/${__dt_ref[tm_mon]}};;
			%y) __fmt=${__fmt//$__ch/${__dt_ref[tm_year]: -2}};;
			%Y) __fmt=${__fmt//$__ch/${__dt_ref[tm_year]}};;
			%H) __fmt=${__fmt//$__ch/${__dt_ref[tm_hour]}};;
			%I) __fmt=${__fmt//$__ch/$((${__dt_ref[tm_hour]}%12))};;
			%M) __fmt=${__fmt//$__ch/${__dt_ref[tm_min]}};;
			%S) __fmt=${__fmt//$__ch/${__dt_ref[tm_sec]}};;
			%j) __fmt=${__fmt//$__ch/${__dt_ref[tm_yday]}};;
			%w) __fmt=${__fmt//$__ch/${__dt_ref[tm_wday]}};;
			%z) __fmt=${__fmt//$__ch/${__dt_ref[tm_isdst]}};;
		esac
	done
					
	echo "$__fmt"
	
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
	[[ -e $__TIME_TZFILE ]] || error.__exit '' '' '' "$__TIME_ERR_TZFILE '$__TIME_TZFILE'"
	[[ -e $__TIME_CTZFILE ]] || error.__exit '' '' '' "$__TIME_ERR_TZFILE '$__TIME_CTZFILE'"	

	declare -Ag __timezones

	while read cc coord tzname _; do
		[[ $cc =~ ^\s*# ]] || __timezones[$tzname]="$cc|$coord"
	done < $__TIME_TZFILE
	
	declare -r __timezones
}

time.__init

readonly -f time.today \
			time.gmtime \
			time.localtime \
			time.tznames \
			time.tzinfo \
			time.tzname \
			time.tzgmtime \
			time.tztoday \
			time.now \
			time.date \
			time.hour \
			time.minute \
			time.second \
			time.month \
			time.month.str \
			time.weekday \
			time.weekday.str \
			time.year \
			time.yearday \
			time.day \
			time.time \
			time.ctime \
			time.tzset \
			time.tzreset \
			time.asctime \
			time.strftime \
			time.__check_date \
			time.__check_time \
			time.__init

# /* __TIME_SRC */
