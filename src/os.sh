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
source str.sh

# Limite máximo de arquivos abertos
readonly __FD_MAX=1024

# errors
readonly __OS_ERR_MODE_PERM='modo de permissão inválido'
readonly __OS_ERR_FILE_NOT_FOUND='arquivo não encontrado'
readonly __OS_ERR_FD_OPEN_MAX='limite máximo de arquivos abertos alcançado'
readonly __OS_ERR_FD_READ='erro de leitura no descritor'
readonly __OS_ERR_FD_WRITE='erro de escrita no descritor'
readonly __OS_ERR_FD_CREATE='erro ao criar o descritor'
readonly __OS_ERR_OPEN_FLAG='open flag de acesso inválida'
readonly __OS_ERR_SEEK_FLAG='seek flag de fluxo inválida'

# constantes
readonly STDIN=/dev/stdin
readonly STDOUT=/dev/stdout
readonly STDERR=/dev/stderr

# open [flags]
readonly O_RDONLY=0		# Somente leitura
readonly O_WRONLY=1		# Somente gravação
readonly O_RDWR=2		# Leitura e gravação

# seek - posição de fluxo [flags]
readonly SEEK_SET=0
readonly SEEK_CUR=1
readonly SEEK_END=2

# func os.file <[var]name> ...
#
# Cria variável do tipo 'os.file'
#
function os.file(){ __init_obj_type "$FUNCNAME" "$@"; return $?; }

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

# func os.remove <[path]pathname> => [bool]
#
# Remove arquivo ou diretório especificado em 'pathname'.
# Retorna 'true' para sucesso, caso contrário 'false'.
#
function os.remove()
{
	getopt.parse "path:path:+:$1"
	rm -rf "$1" &>/dev/null
	return $?
}

# func os.rename <[path]pathname> <[str]newname> => [bool]
#
# Renomeia o arquivo ou diretório representado em 'pathname' por 'newname'.
# Retorna 'true' para sucesso, caso contrário 'false'.
#
function os.rename()
{
	getopt.parse "path:path:+:$1" "newname:str:+:$2"
	mv -f "$1" "$2" &>/dev/null
	return $?
}

# func os.tempdir => [str]
#
# Retorna o diretório temporário padrão do sistema.
#
function os.tempdir()
{
	getopt.parse "-:null:-:$*"
	local tmpdir=$(mktemp --dry-run)
	echo "${tmpdir%/*}"
	return 0
}

# func os.create <[str]filename> => [bool]
#
# Cria arquivo 'filename' com permissão 0664. Sobrescreve arquivo caso
# ele já exista. Em caso de sucesso retorna 'true', caso contraŕio 'false'.
#

function os.create()
{
	getopt.parse "filename:str:+:$1"
	> "$1"
	return $?
}

# func os.stat <[path]path> => [str]
#
# Lê as informações de status do arquivo ou diretório.
# As informações retornadas são separadas pelo delimitador '|' PIPE,
# respeitando a ordem estabelecida abaixo:
#
# %A|%a|%G|%U|%g|%u|%s|%y|%Y|$?
#
# %A - Permissões de acesso (leitura humana)
# %a - Permissões de acesso em octal
# %G - Nome do grupo dono
# %U - Nome do usuário dono
# %g - ID do grupo dono
# %u - ID do usuário dono
# %s - Tamanho total em bytes
# %y - Data da última modificação (leitura humana)
# %Y - Data da última modificação em segundos
# $? - Se é um diretório. (0=Sim ou 1=Não)
#
function os.stat()
{
	getopt.parse "path:path:+:$1"
	
	[[ -d "$1" ]]
	stat --format="%A|%a|%G|%U|%g|%u|%s|%y|%Y|$?" "$1"
	return $?	
}

# func os.open <[var]fd> <[str]filename> <[uint]flag> => [bool]
#
# Abre o arquivo especificado em 'filename' associando um descritor 
# válido para modo de acesso determinado em 'flag'. Se o arquivo for
# aberto com sucesso retorna true e salva em 'fd' o descritor, caso 
# contrário uma mensagem de erro é retornada. O descritor é utilizado
# em chamadas de leitura e escrita no fluxo.
#
# Flags:
#
# O_RDONLY - 0 Somente leitura
# O_WRONLY - 1 Somente gravação
# O_RDWR   - 2 Leitura e gravação
#	
# Exemplo:
#
# source o.sh
#
# # Criando objeto do tipo 'os.file'.
# $ os.file arq
#
# # Abrindo arquivo para leitura
# $ os.open arq '/etc/group' $O_RDONLY
#
# # Lendo uma única linha do arquivo.
# $ arq.readline
# root:x:0:
#
# # O mesmo processo utilizando o descritor.
# $ os.file.readline $arq
# daemon:x:1:
#
# # Fechando arquivo
# $ arq.close
# ou
# $ arq.file.close $arq
#
# # Deletando 'arq'
# del arq
#
function os.open()
{
	getopt.parse "fd:var:+:$1" "filename:str:+:$2" "flag:uint:+:$3"
	
	local __file=$2
	local __mode=$3
	local __av=0
	local __fd __parse

	declare -n __fdref=$1

	if [ ! -d /dev/fd ]; then
		error.__exit '' '' '' "'/dev/fd' diretório FIFOs para método I/O não encontrado"
	elif [ -d "$__file" ]; then
		error.__exit 'filename' 'str' "$__file" 'é um diretório'
	fi

	for ((__fd=3; __fd <= __FD_MAX; __fd++)); do
		if [ ! -e /dev/fd/$__fd ]; then __av=1; break; fi
	done

	if [ $__av -eq 0 ]; then
		error.__exit 'file' 'fd' "$__file" "$__OS_ERR_FD_OPEN_MAX"
	fi
	
	case $__mode in
		0) [[ -e "$__file" ]] || error.__exit 'file' 'str' "$__file" "$__OS_ERR_FILE_NOT_FOUND"
		   __parse="$__fd<$__file";;
		1) __parse="$__fd>>$__file";;
		2) __parse="$__fd<>$__file";;
		*) error.__exit 'flag' 'uint' "$__mode" "$__OS_ERR_OPEN_FLAG";;
	esac

	mkdir -p "$__RUNTIME/$$/fd"
	
	eval exec "$__parse" 2>/dev/null || \
	error.__exit 'descriptor' "fd" '-' "$__OS_ERR_FD_CREATE '$__fd'"

	echo "$__file|$__mode|$__fd|0" > "$__RUNTIME/$$/fd/$__fd"

	__fdref=$__fd

	return 0
}

function os.file.isatty()
{
	getopt.parse "descriptor:fd:+:$1"
	[ -t /dev/fd/$1 ]
	return $?
}

function os.file.writable()
{
	getopt.parse "descriptor:fd:+:$1"
	[ -w /dev/fd/$1 ]
	return $?
}

function os.file.readable()
{
	getopt.parse "descriptor:fd:+:$1"
	[ -r /dev/fd/$1 ]
	return $?
}

function os.file.size()
{
	getopt.parse "descriptor:fd:+:$1"
	str.field "$(os.file.stat $1)" '|' 6
	return $?
}

function os.file.name()
{
	getopt.parse "descriptor:fd:+:$1"
	str.field "$(< "$__RUNTIME/$$/fd/$1")" '|' 0
	return $?
}

function os.file.mode()
{
	getopt.parse "descriptor:fd:+:$1"
	str.field "$(< "$__RUNTIME/$$/fd/$1")" '|' 1
	return $?
}

function os.file.stat()
{
	getopt.parse "descriptor:fd:+:$1"
	os.stat "$(os.file.name $1)"
	return $?
}

function os.file.fd()
{
	getopt.parse "descriptor:fd:+:$1"
	str.field "$(< "$__RUNTIME/$$/fd/$1")" '|' 2
	return 0
}

function os.file.readlines()
{
	getopt.parse "descriptor:fd:+:$1"
	
	local attr cur
	local bytes=0

	while read line; do
		bytes=$((bytes+${#line}))
		echo "$line"
	done <&$1 2>/dev/null || \
	error.__exit 'descriptor' "fd" '-' "$__OS_ERR_FD_READ '$1'"
	
	attr=$(< "$__RUNTIME/$$/fd/$1")
	cur=${attr##*|}
	seek=$((cur+bytes))

	echo "${attr%|*}|$seek" > "$__RUNTIME/$$/fd/$1"
	
	return 0
}

function os.file.readline()
{
	getopt.parse "descriptor:fd:+:$1"
	
	local seek len attr line cur

	read line <&$1 2>/dev/null || \
	error.__exit 'descriptor' "fd" '-' "$__OS_ERR_FD_READ '$1'"

	len=${#line}
	attr=$(< "$__RUNTIME/$$/fd/$1")
	cur=${attr##*|}
	seek=$((cur+len))

	echo "${attr%|*}|$seek" > "$__RUNTIME/$$/fd/$1"
	echo "$line"

	return 0
}

function os.file.read()
{
	getopt.parse "descriptor:fd:+:$1" "bytes:uint:+:$2"
		
	local attr cur seek ch
	local bytes=0

	(($2 == 0)) && return 0	

	while read -N1 ch; do
		echo -n "${ch:- }"
		(($((++bytes)) == $2)) && break
	done <&$1 2>/dev/null || \
	error.__exit 'descriptor' "fd" '-' "$__OS_ERR_FD_READ '$1'"
	echo
	
	attr=$(< "$__RUNTIME/$$/fd/$1")
	cur=${attr##*|}
	seek=$((cur+bytes))

	echo "${attr%|*}|$seek" > "$__RUNTIME/$$/fd/$1"
	return 0
}

function os.file.writeline()
{
	getopt.parse "descriptor:fd:+:$1" "string:str:-:$2"
	
	echo "$2" >&$1 2>/dev/null || \
	error.__exit 'descriptor' "fd" '-' "$__OS_ERR_FD_WRITE '$1'"
	
	return $?
}

function os.file.write()
{
	getopt.parse "descriptor:fd:+:$1" "string:str:-:$2" "bytes:uint:+:$3"
	
	(($3 == 0)) && return 0

	echo "${2:0:$3}" >&$1 2>/dev/null || \
	error.__exit 'descriptor' "fd" '-' "$__OS_ERR_FD_WRITE '$1'"
	
	return $?
}

function os.file.close()
{
	getopt.parse "descriptor:fd:+:$1"
	
	local fd=$(os.file.fd $1)
	
	if eval exec "$fd>&-" && eval exec "$fd<&-"; then
		> "$__RUNTIME/$$/fd/$1"
	else
		return 1
	fi
	
	return 0
}

function os.file.tell()
{
	getopt.parse "descriptor:fd:+:$1"
	str.field "$(< "$__RUNTIME/$$/fd/$1")" '|' 3
	return 0
}

function os.file.seek()
{
	getopt.parse "descriptor:fd:+:$1" "offset:uint:+:$2" "whence:uint:+:$3"
	
	local fd=$1
	local offset=$2
	local whence=$3
	local mode file cur end
	
	mode=$(os.file.mode $fd)
	file=$(os.file.name $fd)
	cur=$(os.file.tell $fd)
	end=$(os.file.size $fd)

	case $mode in
		0) 	parse="$fd<$file";;
		1) 	parse="$fd>>$file";;
		2)	parse="$fd<>$file";;
		*) 	error.__exit 'flag' 'uint' "$mode" "$__OS_ERR_OPEN_FLAG";;
	esac
	
	eval exec "$parse" 2>/dev/null || error.__exit 'descriptor' "fd" '-' "$__OS_ERR_FD_READ '$fd'"

	case $whence in
		0)	os.file.read $fd $offset 1>/dev/null;;
		1) 	os.file.read $fd $((cur+offset)) 1>/dev/null;;
		2)	os.file.read $fd $end 1>/dev/null;;
		*) 	error.__exit 'whence' 'uint' "$whence" "$__OS_ERR_SEEK_FLAG";;
	esac

	return $?
}

function os.__init()
{
	local depends=(id pwd touch mkdir stat)
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
