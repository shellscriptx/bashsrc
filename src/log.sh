#!/bin/bash

[[ $__LOG_SH ]] && return 0

readonly __LOG_SH=1

source builtin.sh
source struct.sh

readonly LOG_LDATE=1
readonly LOG_SDATE=2
readonly LOG_HOUR=3
readonly LOG_DATE=4
readonly LOG_LONG=5
readonly LOG_SECS=6

var logfile_t struct_t
var log_t struct_t

log_t.__add__ \
	code 	uint \
	msg 	str \
	flag 	uint

logfile_t.__add__ \
	log 	log_t \
    file 	str


function log.format()
{
	getopt.parse 2 "flag:flag:+:$1" "fmt:str:+:$2" "${@:3}"

	[[ $1 == @(warn|WARN) ]] && printf '\033[0;31m'
	printf "%s: %s: %($2)T \033[0;m\n" "${0##*/}" "$1"

	return 0
}

function log.fatalf()
{
	getopt.parse -1 "struct:log_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 FATAL true "${@:2}"
	exit 1
}

function log.fatal()
{
	getopt.parse 1 "struct:log_t:+:$1" ${@:2}
	log.__format $1 FATAL false
	exit 1
}

function log.out()
{
	getopt.parse 1 "struct:log_t:+:$1" ${@:2}
	log.__format $1 LOG false
	return 0
}

function log.outf()
{
	getopt.parse -1 "struct:log_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 LOG true "${@:2}"
	return 0
}

function log.warn()
{
	getopt.parse 1 "struct:log_t:+:$1" ${@:2}
	log.__format $1 WARN false
	return 0
}

function log.warnf()
{
	getopt.parse -1 "struct:log_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 WARN true "${@:2}"
	return 0
}

function log.file()
{
	getopt.parse 1 "struct:logfile_t:+:$1" ${@:2}
	log.__file $1 false
}

function log.filef()
{
	getopt.parse -1 "struct:logfile_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__file $1 true "${@:2}"
}

function log.__file()
{
	[[ $(__type__ $1) != logfile_t ]] && { error.__trace def; return $?; }
	
    local logfile=$($1.file)

    if [[ -d "$logfile" ]]; then
        error.__trace def 'struct' 'file' "$logfile" 'não é um arquivo válido'
        return $?
    elif [[ -e "$logfile" && ! -w "$logfile" ]]; then
        error.__trace def 'struct' 'file' "$logfile" "permissão negada: não é possível gravar no arquivo"
        return $?
    fi
	
	log.__format $1 LOG $2 "${@:3}" >> "$logfile" || {
		error.__trace def 'struct' 'file' "$logfile" 'erro ao gravar no arquivo de log'
		return $?
	}

    return 0
}

function log.__format()
{
	local msg flag code type fmt date
	
	type=$(__type__ $1)

	case $type in
		log_t)
			msg=$($1.msg) 
			flag=$($1.flag) 
			code=$($1.code)
			;;
		logfile_t)
			msg=$($1.log.msg)
			flag=$($1.log.flag)
			code=$($1.log.code)
			;;
		*)
			error.__trace def
			return $?
			;;
	esac

	case $flag in
		1) fmt='%(%A, %d de %B de %Y %T)T';;
		2) fmt='%(%d/%m/%Y %T)T';;
		3) fmt='%(%T)T';;
		4) fmt='%(%d/%m/%Y)T';;
		5) fmt='%(%d%m%Y%H%M%S)T';;
		6) fmt='%(%s)T';;
		*) error.__trace def 'struct' 'flag' "$flag" "flag de log inválida"; return $?;;
	esac

	[[ $2 == WARN ]] && printf '\033[0;31m'	
	[[ $3 == true ]] && printf -v msg "$msg" "${@:4}"
	
	printf -v date "$fmt"
	printf '%s: %s: %s: %s: %s\n'  "${0##*/}" \
									"$2" \
                                    "$date" \
                                    "${code:--}" \
                                    "${msg:--}"

	printf '\033[0;m'

	return 0
}

source.__INIT__
# /* __LOG_SH * /
