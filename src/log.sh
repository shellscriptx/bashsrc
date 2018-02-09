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
var logwarn_t struct_t

log_t.__add__ \
	code 	uint \
	msg 	str \
	flag 	uint

logfile_t.__add__ \
	log 	log_t \
    file 	str

logwarn_t.__add__ \
	msg		str \
	flag	uint

# func log.format <[flag]flag> <[str]msg> => [str]
#
# Exibe 'fmt' na saída padrão precedida por 'flag'.
#
# flag - Palavra chave personalizada que especifica a flag de log e que
#        deve conter os seguintes caracteres: [a-zA-Z_].
#        Se 'flag' for igual 'warn' ou 'WARN', aplica a paleta de cor vermelha.
# msg  - Mensagem a ser exibida. São suportados códigos de formato.
#
# Código de formato:
#
# %%   um % literal
# %a   nome abreviado do dia de semana da localidade (por exemplo, Sáb)
# %A   nome completo do dia de semana na localidade (por exemplo, Sábado)
# %b   nome abreviado do mês na localidade (por exemplo, Jan)
# %B   nome completo do mês na localidade (por exemplo, Janeiro)
# %c   data e hora na localidade (por exemplo, Sáb 08 Mar 2008 18:34:17 BRT)
# %C   século; como %Y, mas omite os dois últimos dígitos (por exemplo, 21)
# %d   dia do mês (por exemplo, 01)
# %D   data no formato estado-unidense; o mesmo que %d/%m/%y
# %e   dia do mês, preenchido com espaço; o mesmo que %_d
# %F   data completa; o mesmo que %Y-%m-%d
# %g   os últimos dois dígitos do ano do número ISO da semana (veja %G)
# %G   ano do número ISO da semana ISO (veja %V); normalmente útil só com %V
# %h   o mesmo que %b
# %H   hora (00..23)
# %I   hora (01..12)
# %j   dia do ano (001..366)
# %k   hora, com preenchimento de espaço ( 0..23); o mesmo que %_H
# %l   hora, com preenchimento de espaço ( 1..12); o mesmo que %_I
# %m   mês (01..12)
# %M   minuto (00..59)
# %n   um caractere de nova-linha
# %N   nanosegundos (000000000..999999999)
# %p   o equivalente na localidade para AM ou PM; em branco se desconhecido
# %P   como %p, mas em minúsculas
# %r   a hora no relógio de 12 horas na localidade (por exemplo, 11:11:04 PM)
# %R   hora e minuto no estilo 24 horas; o mesmo que %H:%M
# %s   segundos desde 1970-01-01 00:00:00 UTC
# %S   segundo (00..60)
# %t   uma tabulação
# %T   as horas; o mesmo que %H:%M:%S
# %u   dia da semana (1..7); 1 é segunda-feira
# %U   número da semana no ano, sendo domingo o início da semana (00..53)
# %V   número ISO da semana, sendo segunda-feira o início da semana (01..53)
# %w   dia da semana (0..6); 0 é domingo
# %W   número da semana no ano, sendo segunda-feira o início da semana (00..53)
# %x   representação da data na localidade (por exemplo, 31/12/99)
# %X   representação da hora na localidade (por exemplo, 23:13:48)
# %y   os últimos dois dígitos do ano (00..99)
# %Y   ano
# %z   fuso horário numérico +hhmm (por exemplo, -0400)
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
# Finaliza o script com 'code' status exibindo o log com os atributos
# de 'log_t', substituindo os caracteres de formato por 'exp' (opcional).
#
function log.fatalf()
{
	getopt.parse -1 "struct:log_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 FATAL true "${@:2}"
	exit $($1.code)
}

# func log.fatal <[log_t]struct> => [str]
#
# Finaliza o script com 'code' status exibindo o log com os atributos
# da estrutura 'log_t'.
#
function log.fatal()
{
	getopt.parse 1 "struct:log_t:+:$1" ${@:2}
	log.__format $1 FATAL false
	exit $($1.code)
}

# func log.out <[log_t]struct> => [str]
#
# Exibe o log com os atributos da estrutura 'log_t'.
#
# Exemplo:
#
# #!/bin/bash
#
# source log.sh
#
# # Implementa 'log_t'
# var meu_log log_t
#
# # Define os atributos.
# meu_log.msg = 'registrando mensagem de log.'
# meu_log.flag = $LOG_SDATE   # data e hora no formato curto.
# meu_log.code = 1            # código do log.
#
# # Exibe o log
# log.out meu_log
#
# Saída:
#
# script.sh: LOG: 08/02/2018 18:49:46: 1: registrando mensagem de log.
#
function log.out()
{
	getopt.parse 1 "struct:log_t:+:$1" ${@:2}
	log.__format $1 LOG false
	return 0
}

# func log.outf <[log_t]struct> <[str]exp> => [str]
#
# Exibe o log com os atributos da estrutura 'log_t', substituindo
# os caracteres de formato por 'exp' (opcional).
#
# Exemplo:
#
# #!/bin/bash
#
# source log.sh
#
# # Implementa 'log_t'
# var info log_t
#
# # Define a mensagem do log, acrescentando os caracteres de formato '%s'.
# info.msg = "usuário '%s' conectou-se ao host '%s' no dia %s."
# info.code = 2
# info.flag = $LOG_HOUR
#
# # Exibe o log substituindo os caracteres de formato contidos
# # na mensagem pelos argumentos passados.
# log.outf info 'josé' 'estacao01' 17
#
# Saída:
#
# script: LOG: 23:37:45: 2: usuário 'josé' conectou-se ao host 'estacao01' no dia 17.
#
function log.outf()
{
	getopt.parse -1 "struct:log_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 LOG true "${@:2}"
	return 0
}

# func log.warn <[logwarn_t]struct> => [str]
#
# Exibe o log com os atributos da estrutura 'logwarn_t', retornando
# o código de status '1'.
#
function log.warn()
{
	getopt.parse 1 "struct:logwarn_t:+:$1" ${@:2}
	log.__format $1 WARN false
	return 1
}

# func log.warnf <[logwarn_t]struct> <[str]exp> ... => [str]
#
# Exibe o log com os atributos da estrutura 'logwarn_t' substituindo
# os caracteres de formato por 'exp' (opcional), retornando 
# o código de status '1'.
#
function log.warnf()
{
	getopt.parse -1 "struct:logwarn_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 WARN true "${@:2}"
	return 1
}

# func log.file <[logfile_t]struct>
#
# Grava a estrutura 'logfile_t' no arquivo especificado em 'file'.
#
# Exemplo:
#
# #!/bin/bash
#
# source log.sh
#
# # Implementa 'logfile_t'
# var info logfile_t
#
# # Define os atributos
# info.log.msg = "gravando arquivo de log"
# info.log.code = 2
# info.log.flag = $LOG_HOUR
#
# # Define o arquivo.
# info.file = '/tmp/evento.log'
#
# # Gravando log
# log.file info
#
# Saida:
#
# $ cat /tmp/evento.log 
# script.sh: LOG: 23:46:48: 2: gravando arquivo de log
#
function log.file()
{
	getopt.parse 1 "struct:logfile_t:+:$1" ${@:2}
	log.__format $1 LOG false
}

# func log.filef <[logfile_t]struct> <[str]exp> ...
#
# Grava a estrutura 'logfile_t' no arquivo especificado em 'file',
# substituindo os caracteres de formato por 'exp' (opcional).
#
function log.filef()
{
	getopt.parse -1 "struct:logfile_t:+:$1" "exp:str:-:$2" ... "${@:3}"
	log.__format $1 LOG true "${@:2}"
}

function log.__format()
{
	local msg flag code type fmt date logfile
	
	type=$(__type__ $1)

	case $type in
		logwarn_t)
			msg=$($1.msg)
			flag=$($1.flag)
			;;
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
			[[ $logfile ]] || { error.__trace st "$1" 'file' 'str' "$__ERR_STRUCT_VAL_MEMBER"; return $?; }
			;;
		*)
			error.__trace def
			return $?
			;;
	esac

	[[ $msg ]] || { error.__trace st "$1" 'msg' 'str' "$__ERR_STRUCT_VAL_MEMBER"; return $?; }
	[[ $flag ]] || { error.__trace st "$1" 'flag' 'uint' "$__ERR_STRUCT_VAL_MEMBER"; return $?; }
	[[ $type == @(log_t|logfile_t) && ! $code ]] && { error.__trace st "$1" 'code' 'uint' "$__ERR_STRUCT_VAL_MEMBER"; return $?; }

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

	if [[ $logfile ]]; then
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
