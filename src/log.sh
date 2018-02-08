#!/bin/bash

[[ $__LOG_SH ]] && return 0

readonly __LOG_SH=1

source builtin.sh
source struct.sh

readonly __ERR_STRUCT_VAL_MEMBER='valor do membro da estrutura requerido'
readonly __ERR_STRUCT_FLAG='flag de log inválida'
readonly __ERR_STRUCT_WFILE='erro ao gravar no arquivo de log'
readonly __ERR_STRUCT_NOFILE='nẽo é um arquivo comum'
readonly __ERR_STRUCT_NOWFILE='acesso negado: não é possível gravar no arquivo'

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

# func log.format <[flag]flag> <[str]msg> => [str]
#
# Exibe 'fmt' na saída padrão precedida por 'flag'.
#
# flag - Palavra chave personalizada que informa a flag da mensagem
#        de log e deve conter os seguintes caracteres: [a-zA-Z_].
#        Se 'flag' for igual 'warn' ou 'WARN', aplica a paleta de cor vermelha.
# msg  - Mensagem a ser exibida. São suportados códigos de formato 'datetime'.
#        %d, %m, %Y e etc.
#
# Exemplo:
#
# #!/bin/bash
#
# source log.sh
#
# log.format registro_msg "mensagem registrada às %H:%M:%S"
#
# Saída:
#
# script.sh: registro_msg: mensagem registrada às 13:59:19
#
function log.format()
{
	getopt.parse 2 "flag:flag:+:$1" "fmt:str:+:$2" "${@:3}"

	[[ $1 == @(warn|WARN) ]] && printf '\033[0;31m'
	printf "%s: %s: %($2)T \033[0;m\n" "${0##*/}" "$1"

	return 0
}

# func log.fatalf <[log_t]struct> <[str]exp> ... => [str]
#
# Exibe a mensagem com os atributos especificados na estrutura 'log_t'
# substituindo os caracteres de formato por 'exp' (opcional).
#
# O script é finalizado com o código de status da estrutura.
#
function log.fatalf()
{
	getopt.parse -1 "struct:log_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 FATAL true "${@:2}"
	exit $($1.code)
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
	log.__format $1 LOG false
}

function log.filef()
{
	getopt.parse -1 "struct:logfile_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 LOG true "${@:2}"
}

function log.__format()
{
	local msg flag code type fmt date logfile wfile
	
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
			logfile=$($1.file)
			wfile=true
			;;
		*)
			error.__trace def
			return $?
			;;
	esac

	[[ $msg ]] || error.__trace st "$1" 'msg' 'str' "$__ERR_STRUCT_VAL_MEMBER"
	[[ $code ]] || error.__trace st "$1" 'code' 'uint' "$__ERR_STRUCT_VAL_MEMBER"
	[[ $flag ]] || error.__trace st "$1" 'flag' 'uint' "$__ERR_STRUCT_VAL_MEMBER"

	case $flag in
		1) fmt='%(%A, %d de %B de %Y %T)T';;
		2) fmt='%(%d/%m/%Y %T)T';;
		3) fmt='%(%T)T';;
		4) fmt='%(%d/%m/%Y)T';;
		5) fmt='%(%d%m%Y%H%M%S)T';;
		6) fmt='%(%s)T';;
		*) error.__trace def "$1" 'flag' "$flag" "$__ERR_STRUCT_FLAG"; return $?;;
	esac

	[[ $2 == WARN ]] && printf '\033[0;31m'	
	[[ $3 == true ]] && printf -v msg "$msg" "${@:4}"

	if [[ $wfile ]]; then
		if [[ -e "$logfile" && ! -f "$logfile" ]]; then
			error.__trace def 'struct' 'file' "$logfile" "$__ERR_STRUCT_NOFILE"
			return $?
		elif [[ -e "$logfile" && ! -w "$logfile" ]]; then
			error.__trace def 'struct' 'file' "$logfile" "$__ERR_STRUCT_NOWFILE"
			return $?
		fi
	fi

	printf -v date "$fmt"
	printf '%s: %s: %s: %s: %s\n'  "${0##*/}" \
									"$2" \
                                    "$date" \
                                    "${code:--}" \
                                    "${msg:--}" >> "${logfile:-/dev/stdout}"

	printf '\033[0;m'

	return 0
}

source.__INIT__
# /* __LOG_SH * /
