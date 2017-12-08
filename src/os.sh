#!/bin/bash

#----------------------------------------------#
# Source:           os.sh
# Data:             29 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__OS_SH ]] && return 0

readonly __OS_SH=1

source builtin.sh
source time.sh

# errors
readonly __OS_ERR_MODE_PERM='modo de permissão inválido'

# constantes
readonly STDIN=/dev/stdin
readonly STDOUT=/dev/stdout
readonly STDERR=/dev/stderr

# func os.chdir <[str]dir> => [bool]
#
# Altera o diretório atual para 'dir'. Retorna 'true' para sucesso,
# caso contrário 'false'.
#
function os.chdir()
{
	getopt.parse "dir:dir:+:$1"
	cd "$dir" &>/dev/null
	return $?
}

# func os.chmod <[path]pathname> <[uint]mode> => [bool]
#
# Define a permissão 'mode' para o arquivo ou diretório especificado
# em 'pathname'.
#
function os.chmod()
{
	getopt.parse "path:path:+:$1" "mode:uint:+:$2"
	
	[[ $2 =~ ^[0-7]{3,4}$ ]] || error.__exit 'mode' 'uint' "$2" "$__OS_ERR_MODE_PERM"
	chmod "$2" "$1" &>/dev/null
	return $?
}

# func os.stackdir <[var]stack> <[str]dir>
#
# Anexa em 'stack' o diretório especificado
#
function os.stackdir()
{
	getopt.parse "stack:array:+:$1" "dir:str:+:$1"

	declare -n __stack_dir=$1
	local __dir=$2
	
	[ ! -d "$__dir" ] && error.__exit 'dir' 'str' "$__dir" "$__OS_ERR_DIR_NOT_FOUND"
	__stack_dir+=("$__dir")
	
	return 0
}

# func os.exists <[str]filepath> => [bool]
#
# Verifica se o arquivo ou diretório em 'filepath' existe. Retorna 'true'
# se existe, caso contrário 'false'
#
function os.exists()
{
	getopt.parse "filepath:str:+:$1"
	[[ -e "$1" ]]
	return $?
}

# func os.environ => [str]
#
# Retorna uma lista iterável de variáveis de ambiente.
#
function os.environ()
{
	getopt.parse "-:null:-:$*"

	while read _ _ env; do
		echo "${env%%=*}"
	done < <(declare -xp)
	
	return 0
}

# func os.getenv <[var]varname> => [str]
#
# Retorna uma string que representa o valor armazenado em 'varname'.
#
function os.getenv()
{
	getopt.parse "varname:var:+:$1"
			
	declare -n __env_var=$1
	echo "$__env_var"
	return 0
}

# func os.setenv <[var]varname> <[str]value>
#
# Define o valor da variável de ambiente com 'varname' e 'value'
# especificado.
#
function os.setenv()
{
	getopt.parse "varname:var:+:$1" "value:str:-:$2"
	
	export $1="$2"		
	return 0
}

# func os.geteuid => [uint]
#
# Retorna o id efetivo do usuário atual.
#
function os.geteuid()
{
	getopt.parse "-:null:-:$*"
	id --user
	return 0
}

# func os.argv => [str]
#
# Retorna os argumentos de linha de comando iniciando com 
# o nome do programa principal.
#
function os.argv()
{
	getopt.parse "-:null:-:$*"
	echo "${0##*/} ${BASH_ARGV[@]}"
	return 0
}

# func os.argc => [uint]
#
# Retorna o total de argumentos de linha de comando. O programa
# principal é considerado como um argumento.
#
function os.argc()
{
	getopt.parse "-:null:-:$*"
	echo $(($BASH_ARGC+1))
	return 0
}

# func os.getgid => [uint]
#
# Retorna o id do grupo principal do usuário atual.
#
function os.getgid()
{
	getopt.parse "-:null:-:$*"
	id --group
	return 0
}

# func os.getgroups => [uint]
#
# Retorna os ids dos grupos do usuário atual.
#
function os.getgroups()
{
	getopt.parse "-:null:-:$*"
	id --groups
	return 0
}

# func os.getpid => [uint]
#
# Retorna o pid do processo principal
#
function os.getpid()
{
	getopt.parse "-:null:-:$*"
	echo $BASHPID
	return 0
}

# func os.getppid => [uint]
#
# Retorna o pid do processo pai.
#
function os.getppid()
{
	getopt.parse "-:null:-:$*"
	echo $PPID
	return 0
}

# func os.getwd => [str]
#
# Retorna o nome do caminho que corresponde ao diretório atual.
#
function os.getwd()
{
	getopt.parse "-:null:-:$*"
	pwd; return 0
}

# func os.hostname => [str]
#
# Retorna o nome da máquina.
#
function os.hostname()
{
	getopt.parse "-:null:-:$*"
	[[ -e /etc/hostname ]] && echo $(< /etc/hostname) || return 1
	return 0
}

# func os.chatime <[path]pathname> <[map]time> => [bool]
#
# Altera o tempo de acesso do arquivo ou diretório especificado
# em 'pathname' pelo tempo na estrutura 'time'. Se o valor de um membro
# da estrutura for omitido, assume como padrão a data do sistema.
#
function os.chatime(){ os.__chtime -a "$1" "$2"; return $?; }

# func os.chmtime <[path]pathname> <[map]time> => [bool]
#
# Altera o tempo de modificação do arquivo ou diretório especificado
# em 'pathname' pelo tempo na estrutura 'time'. Se o valor de um membro
# da estrutura for omitido, assume como padrão a data do sistema.
#
function os.chmtime(){ os.__chtime -m "$1" "$2"; return $?; }

# func os.chtime <[path]pathname> <[map]time> => [bool]
#
# Altera o tempo de modificação e acesso do arquivo ou diretório especificado
# em 'pathname' pelo tempo na estrutura 'time'. Se o valor de um membro
# da estrutura for omitido, assume como padrão a data do sistema.
#
function os.chtime(){ os.__chtime '' "$1" "$2"; return $?; }

function os.__chtime()
{
	getopt.parse "pathname:path:+:$2" "time:map:+:$3"

	declare -n __map_ref=$3
	local __flag=$1
	local __tm=($(printf "%(%_w %_d %_m %Y %_H %_M %_S %_j)T"))

	__map_ref[tm_wday]=${__map_ref[tm_wday]:-${__tm[0]}}
	__map_ref[tm_mday]=${__map_ref[tm_mday]:-${__tm[1]}}
	__map_ref[tm_mon]=${__map_ref[tm_mon]:-${__tm[2]}}
	__map_ref[tm_year]=${__map_ref[tm_year]:-${__tm[3]}}
	__map_ref[tm_hour]=${__map_ref[tm_hour]:-${__tm[4]}}
	__map_ref[tm_min]=${__map_ref[tm_min]:-${__tm[5]}}
	__map_ref[tm_sec]=${__map_ref[tm_sec]:-${__tm[6]}}
	__map_ref[tm_yday]=${__map_ref[tm_yday]:-${__tm[7]}}
	
	if ! (time.__check_time ${__map_ref[tm_hour]} \
                            ${__map_ref[tm_min]} \
                            ${__map_ref[tm_sec]} &&
          time.__check_date ${__map_ref[tm_wday]} \
                            ${__map_ref[tm_mday]} \
                            ${__map_ref[tm_mon]} \
                            ${__map_ref[tm_year]} \
                            ${__map_ref[tm_yday]}); then
        
        error.__exit 'time' 'map' "\n$(map.list $3)" "$__TIME_ERR_DATETIME"
    fi

	touch $__flag \
			--no-create \
			--date "${__weekdays[${__map_ref[tm_wday]}]}
					${__map_ref[tm_mday]}
					${__months[${__map_ref[tm_mon]}]}
					${__map_ref[tm_year]}
					${__map_ref[tm_hour]}:${__map_ref[tm_min]}:${__map_ref[tm_sec]}" \
					"$2" &>/dev/null
				
	return $?
}

# func os.mkdir <[str]dirname> <[uint]mode> => [bool]
#
# Cria diretório 'dirname' com permissões especificadas em 'mode'. É possível
# criar subdiretórios não existes informando o caminho completo.
# Retorna 'true' em caso de sucesso, caso contrário 'false.'
#
function os.mkdir()
{
	getopt.parse "dir:str:+:$1" "mode:uint:+:$2"
	
	[[ $2 =~ ^[0-7]{3,4}$ ]] || error.__exit 'mode' 'uint' "$2" "$__OS_ERR_MODE_PERM"
	mkdir --parents --mode=$2 "$1" &>/dev/null
	return $?
}

function os.__init()
{
	local depends=(id pwd touch mkdir)
	local dep deps

	for dep in ${depends[@]}; do
		if ! command -v $dep &>/dev/null; then
			deps+=($dep)
		fi
	done

	[[ $deps ]] && error.__depends $FUNCNAME ${BASH_SOURCE##*/} "${deps[*]}"

	return 0
}



os.__init
