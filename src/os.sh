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

__TYPE__[file_t]='
os.file.name
os.file.stat
os.file.fd
os.file.readlines
os.file.readline
os.file.read
os.file.writeline
os.file.write
os.file.close
os.file.tell
os.file.mode
os.file.seek
os.file.size
os.file.isatty
os.file.writable
os.file.readable
os.file.rewind
'

declare -a __OS_FD_OPEN

# Limite máximo de arquivos abertos
readonly __FD_MAX=1024

# errors
readonly __ERR_OS_MODE_PERM='modo de permissão inválido'
readonly __ERR_OS_FILE_NOT_FOUND='arquivo não encontrado'
readonly __ERR_OS_FD_OPEN_MAX='limite máximo de arquivos abertos alcançado'
readonly __ERR_OS_FD_READ='erro de leitura no descritor'
readonly __ERR_OS_FD_WRITE='erro de escrita no descritor'
readonly __ERR_OS_FD_CREATE='erro ao criar o descritor'
readonly __ERR_OS_OPEN_FLAG='open flag de acesso inválida'
readonly __ERR_OS_SEEK_FLAG='seek flag de fluxo inválida'
readonly __ERR_OS_FILE_NOT_WRITE='não é permitido gravar no arquivo'
readonly __ERR_OS_FILE_NOT_READ='não é permitido ler o arquivo'
readonly __ERR_OS_FILE_NOT_RW='não é permitido ler/gravar no arquivo'
readonly __ERR_OS_FILE_CLOSE='erro ao fechar o descritor do arquivo'

# constantes
readonly STDIN=/dev/stdin
readonly STDOUT=/dev/stdout
readonly STDERR=/dev/stderr

# open [flags]
readonly O_RDONLY=0
readonly O_WRONLY=1
readonly O_RDWR=2

# seek - posição de fluxo [flags]
readonly SEEK_SET=0
readonly SEEK_CUR=1
readonly SEEK_END=2

# func os.chdir <[str]dir> => [bool]
#
# Altera o diretório atual para 'dir'. Retorna 'true' para sucesso,
# caso contrário 'false'.
#
function os.chdir()
{
	getopt.parse 1 "dir:dir:+:$1" ${@:2}
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
	getopt.parse 2 "path:path:+:$1" "mode:uint:+:$2" ${@:3}
	
	if ! [[ $2 =~ ^[0-7]{3,4}$ ]]; then
		error.trace def 'mode' 'uint' "$2" "$__ERR_OS_MODE_PERM"; return $?
	fi
	chmod "$2" "$1" &>/dev/null
	return $?
}

# func os.stackdir <[var]stack> <[str]dir>
#
# Anexa em 'stack' o diretório especificado
#
function os.stackdir()
{
	getopt.parse 1 "stack:array:+:$1" "dir:str:+:$1" ${@:2}

	declare -n __stack_dir=$1
	local __dir=$2
	
	if [ ! -d "$__dir" ]; then
		error.trace def 'dir' 'str' "$__dir" "$__ERR_OS_DIR_NOT_FOUND"
		return $?
	fi
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
	getopt.parse 1 "filepath:str:+:$1" ${@:2}
	[[ -e "$1" ]]
	return $?
}

# func os.environ => [str]
#
# Retorna uma lista iterável de variáveis de ambiente.
#
function os.environ()
{
	getopt.parse 0 ${@:1}

	while IFS=' ' read _ _ env; do
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
	getopt.parse 1 "varname:var:+:$1" ${@:2}
			
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
	getopt.parse 2 "varname:var:+:$1" "value:str:-:$2" ${@:3}
	
	export $1="$2"		
	return 0
}

# func os.geteuid => [uint]
#
# Retorna o id efetivo do usuário atual.
#
function os.geteuid()
{
	getopt.parse 0 ${@:1}
	echo $UID
	return 0
}

# func os.argv => [str]
#
# Retorna os argumentos de linha de comando iniciando com 
# o nome do programa principal.
#
function os.argv()
{
	getopt.parse 0 ${@:1}
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
	getopt.parse 0 ${@:1}
	echo $(($BASH_ARGC+1))
	return 0
}

# func os.getgid => [uint]
#
# Retorna o id do grupo principal do usuário atual.
#
function os.getgid()
{
	getopt.parse 0 ${@:1}
	echo ${GROUPS[0]}
	return 0
}

# func os.getgroups => [uint]
#
# Retorna os ids dos grupos do usuário atual.
#
function os.getgroups()
{
	getopt.parse 0 ${@:1}
	echo ${GROUPS[@]}
	return 0
}

# func os.getpid => [uint]
#
# Retorna o pid do processo principal
#
function os.getpid()
{
	getopt.parse 0 ${@:1}
	echo $BASHPID
	return 0
}

# func os.getppid => [uint]
#
# Retorna o pid do processo pai.
#
function os.getppid()
{
	getopt.parse 0 ${@:1}
	echo $PPID
	return 0
}

# func os.getwd => [str]
#
# Retorna o nome do caminho que corresponde ao diretório atual.
#
function os.getwd()
{
	getopt.parse 0 ${@:1}
	echo "$PWD"; return 0
}

# func os.hostname => [str]
#
# Retorna o nome da máquina.
#
function os.hostname()
{
	getopt.parse 0 ${@:1}
	[[ -e /etc/hostname ]] && echo $(< /etc/hostname) || return 1
	return 0
}

# func os.chatime <[st_time]struct> <[path]pathname> => [bool]
#
# Altera o tempo de acesso do arquivo ou diretório especificado
# em 'pathname' pelo tempo na estrutura 'time'. Se o valor de um membro
# da estrutura for omitido, assume como padrão a data do sistema.
#
function os.chatime(){ os.__chtime "$1" "$2" '-a'; return $?; }

# func os.chmtime <[st_time]struct> <[path]pathname> => [bool]
#
# Altera o tempo de modificação do arquivo ou diretório especificado
# em 'pathname' pelo tempo na estrutura 'time'. Se o valor de um membro
# da estrutura for omitido, assume como padrão a data do sistema.
#
function os.chmtime(){ os.__chtime "$1" "$2" '-m'; return $?; }

# func os.chtime <[st_time]struct> <[path]pathname> => [bool]
#
# Altera o tempo de modificação e acesso do arquivo ou diretório especificado
# em 'pathname' pelo tempo na estrutura 'time'. Se o valor de um membro
# da estrutura for omitido, assume como padrão a data do sistema.
#
function os.chtime(){ os.__chtime "$1" "$2" ''; return $?; }

function os.__chtime()
{
	getopt.parse 3 "struct:st_time:+:$1" "pathname:path:+:$2" "flag:str:-:$3"

	if  ! (time.__check_time $($1.tm_hour) \
								$($1.tm_min) \
								$($1.tm_sec) &&
			time.__check_date   $($1.tm_wday) \
								$($1.tm_mday) \
								$($1.tm_mon) \
								$($1.tm_year) \
								$($1.tm_yday)) 2>/dev/null; then
        error.trace def 'st_time' 'struct_t' "$1" "$__ERR_TIME_DATETIME"
        return $?
    fi

	touch $3 \
			--no-create \
			--date "${__weekdays[$($1.tm_wday)]}
					$($1.tm_mday) 
					${__months[$($1.tm_mon)]} 
					$($1.tm_year) 
					$($1.tm_hour):$($1.tm_min):$($1.tm_sec)" \
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
	getopt.parse 2 "dir:str:+:$1" "mode:uint:+:$2" ${@:3}
	
	if ! [[ $2 =~ ^[0-7]{3,4}$ ]]; then
		error.trace def 'mode' 'uint' "$2" "$__ERR_OS_MODE_PERM"; return $?
	fi
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
	getopt.parse 1 "path:path:+:$1" ${@:2}
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
	getopt.parse 2 "path:path:+:$1" "newname:str:+:$2" ${@:3}
	mv -f "$1" "$2" &>/dev/null
	return $?
}

# func os.tempfile <[str]prefix> => [str]
#
# Gera nomenclatura de um arquivo temporário contendo o prefixo especificado.
#
function os.tempfile()
{
	getopt.parse 1 "prefix:str:+:$1" ${@:2}

	local chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	local seed=$(printf '%(%s)T')
	local hash
	
	for _ in {1..10}; do 
		hash+=${chars:$((RANDOM^$seed))%${#chars}:1}
	done

	echo "/tmp/$1.$hash"

	return 0
}

# func os.create <[str]filename> => [bool]
#
# Cria arquivo 'filename' com permissão 0664. Sobrescreve arquivo caso
# ele já exista. Em caso de sucesso retorna 'true', caso contraŕio 'false'.
#

function os.create()
{
	getopt.parse 1 "filename:str:+:$1" ${@:2}
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
	getopt.parse 1 "path:path:+:$1" "${@:2}"
	
	[[ -d "$1" ]]
	stat --format="%A|%a|%G|%U|%g|%u|%s|%y|%Y|$?" "$1"
	return $?	
}

# func os.open <[file_t]var> <[str]filename> <[uint]flag> => [bool]
#
# Abre o arquivo especificado em 'filename' associando um descritor 
# válido para modo de acesso determinado em 'flag'. Se o arquivo for
# aberto com sucesso retorna true e salva em 'fd' o descritor, caso 
# contrário uma mensagem de erro é retornada. O descritor é utilizado
# em chamadas de leitura e escrita no fluxo. 
# A chamada 'os.open' cria 'filename' caso ele não exista. Se a flag
# 'O_WRONLY' for utilizada, anexa os dados ao final do arquivo.
#
# Flags:
#
# O_RDONLY - 0 Somente leitura
# O_WRONLY - 1 Somente gravação
# O_RDWR   - 2 Leitura e gravação
#	
# Obs: Se a flag 'O_WRONLY' for utilizada não será possível posicionar
# o fluxo de gravação com 'os.file.seek', fazendo com que os dados sejam
# anexados somente no final do arquivo.
#
# Exemplo:
#
# source o.sh
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
	getopt.parse 3 "var:file_t:+:$1" "filename:str:+:$2" "flag:uint:+:$3" ${@:4}
	
	local __file=$2
	local __mode=$3
	local __av=0
	local __fd __parse

	declare -n __fdref=$1

	if [ ! -d /dev/fd ]; then
		error.trace def '' '' '' "'/dev/fd' diretório FIFOs para método I/O não encontrado"; return $?
	elif [ -d "$__file" ]; then
		error.trace def 'filename' 'str' "$__file" 'é um diretório'; return $?
	fi

	for ((__fd=3; __fd <= __FD_MAX; __fd++)); do
		if [ ! -e /dev/fd/$__fd ]; then __av=1; break; fi
	done

	if [ $__av -eq 0 ]; then
		error.trace def 'file' 'fd' "$__file" "$__ERR_OS_FD_OPEN_MAX"; return $?
	fi
	
	case $__mode in
		0)
			if [[ ! -e "$__file" ]]; then
				error.trace def 'file' 'str' "$__file" "$__ERR_OS_FILE_NOT_FOUND"; return $?
			elif [[ ! -r "$__file" ]]; then
				error.trace def 'file' 'str' "$__file" "$__ERR_OS_FILE_NOT_READ"; return $?
			fi
			__parse="$__fd<'$__file'"
			;;

		1)
			if [[ -e "$__file" && ! -w "$__file" ]]; then
				error.trace def 'file' 'str' "$__file" "$__ERR_OS_FILE_NOT_WRITE"; return $?
			fi
			__parse="$__fd>>'$__file'"
			;;

		2) 
			if [[ -e "$__file" ]] && [[ ! -w "$__file" || ! -r "$__file" ]]; then
				error.trace def 'file' 'str' "$__file" "$__ERR_OS_FILE_NOT_RW"; return $?
			fi
			__parse="$__fd<>'$__file'"
			;;
		*) error.trace def 'flag' 'uint' "$__mode" "$__ERR_OS_OPEN_FLAG"; return $?;;
	esac

	if ! eval exec "$__parse" 2>/dev/null; then
		error.trace def 'descriptor' "fd" '-' "$__ERR_OS_FD_CREATE '$__fd'"
		return $?
	fi

	__OS_FD_OPEN[$__fd]="$1|$__file|$__mode|$__fd|0"
	__fdref=$__fd

	return 0
}

# func os.file.isatty <[uint]fd> => [bool]
#
# Retorna 'true' se há um arquivo aberto associado ao descritor 'fd'.
# Caso contrário retorna 'false'.
#
function os.file.isatty()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	[ -t /dev/fd/$1 ]
	return $?
}

# func os.file.writable <[uint]fd> => [bool]
#
# Retorna 'true' se é um descritor de escrita. Caso contrário 'false'.
#
function os.file.writable()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	[ -w /dev/fd/$1 ]
	return $?
}

# func os.file.readable <[uint]fd> => [bool]
#
# Retorna 'true' se é um descritor de leitura. Caso contrário 'false'.
#
function os.file.readable()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	[ -r /dev/fd/$1 ]
	return $?
}

# func os.file.size <[uint]fd> => [uint]
#
# Retorna o comprimento em bytes do arquivo associado ao descritor 'fd'.
#
function os.file.size()
{
	getopt.parse 1 "descriptor:fd:+:$1" "${@:2}"

	local filename
	IFS='|' read _ filename _ _ _ <<< "${__OS_FD_OPEN[$1]}"
	stat -c "%s" "$filename"
	return $?
}

# func os.file.name <[uint]fd> => [str]
#
# Retorna o nome completo do arquivo associado ao descritor 'fd'.
#
function os.file.name()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}

	local filename
	IFS='|' read _ filename _ _ _ <<< "${__OS_FD_OPEN[$1]}"
	echo "$filename"
	return $?
}

# func os.file.mode <[uint]fd> => [uint]
#
# Retorna um inteiro positivo indicando o modo de acesso.
#
# 0 - somente leitura
# 1 - somente gravação
# 2 - gravação e leitura
#
function os.file.mode()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	
	local mode
	IFS='|' read _ _ mode _ _ <<< "${__OS_FD_OPEN[$1]}"
	echo "$mode"
	return $?
}

# func os.file.stat <[uint]fd> => [str]
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
function os.file.stat()
{
	getopt.parse 1 "descriptor:fd:+:$1" "${@:2}"
	
	local filename
	IFS='|' read _ filename _ _ _ <<< "${__OS_FD_OPEN[$1]}"

	[[ -d "$filename" ]]
	stat --format="%A|%a|%G|%U|%g|%u|%s|%y|%Y|$?" "$filename"
	return $?
}

# func os.file.fd <[uint]fd> => [uint]
#
# Retorna um inteiro sem sinal indicando o número do descritor associado.
#
function os.file.fd()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	
	local fd
	IFS='|' read _ _ _ fd _ <<< "${__OS_FD_OPEN[$1]}"
	echo "$fd"

	return 0
}

# func os.file.readlines <[uint]fd> => [str]
#
# Lê todas as linhas contidas no arquivo apontado por 'fd'. 
#
function os.file.readlines()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	
	local line
	local bytes=0

	if ! while read line; do
		bytes=$((bytes+${#line}))
		echo "$line"
	done <&$1 2>/dev/null; then
		error.trace def 'descriptor' "fd" '-' "$__ERR_OS_FD_READ '$1'"
		return $?
	fi
	
	__OS_FD_OPEN[$1]="${__OS_FD_OPEN[$1]%|*}|$((${__OS_FD_OPEN[$1]##*|}+$bytes))"

	return 0
}

# func os.file.readline <[uint]fd> => [str]
#
# Lê uma única linha do arquivo e seta o fluxo no inicio da próxima linha.
#
# Exemplo:
#
# $ source o.sh
#
# $ os.open arq '/etc/group' $O_RDONLY
#
# # Lendo uma linha por vez
# $ arq.readline
# root:x:0:
# $ arq.readline
# root:x:0:
#
# # Fechando arquivo
# $ arq.close
#
function os.file.readline()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	
	local line

	if ! read line <&$1 2>/dev/null; then
		error.trace def 'descriptor' "fd" '-' "$__ERR_OS_FD_READ '$1'"
		return $?
	fi

	__OS_FD_OPEN[$1]="${__OS_FD_OPEN[$1]%|*}|$((${__OS_FD_OPEN[$1]##*|}+${#line}))"

	echo "$line"

	return 0
}

# func os.file.read <[uint]fd> <[uint]bytes> => [str]
#
# Lê N'bytes' a partir da posição atual do fluxo.
#
# Exemplo:
#
# $ source o.sh
#
# $ os.open arq '/etc/group' $O_RDONLY
#
# # Lendo os primeiros 4 bytes.
# $ arq.read 4
# root
#
# # fechando arquivo
# arq.close
# 
function os.file.read()
{
	getopt.parse 2 "descriptor:fd:+:$1" "bytes:uint:+:$2" ${@:3}
	
	local ch	
	local bytes=0

	(($2 == 0)) && return 0	

	if ! while read -N1 ch; do
		echo -n "${ch:- }"
		(($((++bytes)) == $2)) && break
	done <&$1 2>/dev/null; then
		error.trace def 'descriptor' "fd" '-' "$__ERR_OS_FD_READ '$1'"
		return $?
	fi

	echo
	
	__OS_FD_OPEN[$1]="${__OS_FD_OPEN[$1]%|*}|$((${__OS_FD_OPEN[$1]##*|}+$bytes))"

	return 0
}

# func os.file.writeline <[uint]fd> <[str]exp> => [bool]
#
# Grava em 'fd' o conteúdo de 'exp'. Retorna 'true' se for gravado
# com sucesso, caso contrário uma mensagem de erro é retornada.
#
function os.file.writeline()
{
	getopt.parse 2 "descriptor:fd:+:$1" "exp:str:-:$2" ${@:3}
	
	if ! echo "$2" >&$1 2>/dev/null; then
		error.trace def 'descriptor' "fd" '-' "$__ERR_OS_FD_WRITE '$1'"
		return $?
	fi
	
	return 0
}

# func os.file.write <[uint]fd> <[str]exp> <[uint]bytes> => [bool]
#
# Grava no arquivo os primeiros N'bytes' de 'exp'. Retorna 'true' para êxito,
# caso contrário uma mensagem de erro é retornada.
#
# Exemplo:
#
# $ source os.sh
# $ var arq os.file
#
# # Abrindo arquivo para escrita.
# $ os.open arq 'test.txt' $O_WRONLY
#
# $ texto='Seja Livre !! Use Linux'
#
# # Gravando os primeiros 13 bytes.
# $ arq.write "$texto" 13
#
# $ cat test.txt
# Seja Livre !!
#
function os.file.write()
{
	getopt.parse 3 "descriptor:fd:+:$1" "exp:str:-:$2" "bytes:uint:+:$3" ${@:4}
	
	(($3 == 0)) && return 0

	if ! echo "${2:0:$3}" >&$1 2>/dev/null; then
		error.trace def 'descriptor' "fd" '-' "$__ERR_OS_FD_WRITE '$1'"
		return $?
	fi
	
	return 0
}

# func os.file.close <[uint]fd> => [bool]
#
# Fecha a conexão com o descritor 'fd'.
#
function os.file.close()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	
	local var

	if ! eval exec "$1<&-"; then
		error.trace def 'descriptor' 'fd' "$1" "$__ERR_OS_FILE_CLOSE"
		return $?
	fi
	
	IFS='|' read var _ _ _ _ <<< "${__OS_FD_OPEN[$1]}"
	
	unset -f ${__INIT_OBJ_METHOD[$var]}

	unset 	__OS_FD_OPEN[$1] \
			__INIT_OBJ_METHOD[$var] \
			__INIT_OBJ_TYPE[$var]
	
	return 0
}

# func os.file.tell <[uint]fd> => [uint]
#
# Retorna a posição atual do fluxo apontado por 'fd'.
#
function os.file.tell()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	echo "${__OS_FD_OPEN[$1]##*|}"
	return 0
}

# func os.file.rewind <[uint]fd> => [bool]
#
# Seta a posição do fluxo para o inicio do arquivo apontado por 'fd'.
# Retorna 'true' para sucesso, caso contrário 'false' e uma mensagem de erro
# é retornada.
# 
function os.file.rewind()
{
	getopt.parse 1 "descriptor:fd:+:$1" ${@:2}
	os.file.seek $1 0 $SEEK_SET
	return 0
}

# func os.file.seek <[uint]fd> <[uint]offset> <[uint]whence> => [bool]
#
# Seta a posição do arquivo de fluxo apontado por 'fd'. A nova posição medida
# em bytes é obitida pelo acréscimo de 'offset' bytes à posição especificada 
# por 'whence'.
# Retorna 'true' para sucesso, caso contrário uma mensagem de erro é retornada.
#
# whence:
#
# SEEK_SET - Inicio do arquivo
# SEEK_CUR - Posição atual do fluxo
# SEEK_END - Fim do arquivo
#
# Exemplo:
#
# # Considere o arquivo abaixo com o seguinte conteúdo.
# $ cat frase.txt
# Existem duas maneiras de construir um projeto de software. Uma é fazê-lo tão simples que obviamente não há falhas. A outra é fazê-lo tão complicado que não existem falhas óbvias.
#
# $ source os.sh
#
# # Abrindo arquivo para leitura
# $ os.open arq 'frase.txt' $O_RDONLY
#
# # Definindo o fluxo na posição do byte '59' relativo ao inicio do arquivo.
# $ arq.seek 59 $SEEK_SET
#
# # Lendo todas as linhas a partir da posição atual do fluxo.
# $ arq.readlines
# Uma é fazê-lo tão simples que obviamente não há falhas. A outra é fazê-lo tão complicado que não existem falhas óbvias.
#
function os.file.seek()
{
	getopt.parse 3 "descriptor:fd:+:$1" "offset:uint:+:$2" "whence:uint:+:$3" ${@:4}
	
	local filename mode fd cur var

	IFS='|' read _ filename mode _ cur <<< "${__OS_FD_OPEN[$1]}"
	
	case $mode in
		0)	eval exec "$1<'$filename'";;
		1) 	eval exec "$1>>'$filename'";;
		2)	eval exec "$1<>'$filename'";;
	esac 2>/dev/null || {
		error.trace def 'descriptor' "fd" '-' "$__ERR_OS_FD_READ '$fd'"
		return $?
	}

	__OS_FD_OPEN[$1]="${__OS_FD_OPEN[$1]%|*}|0"

	case $3 in
		0)	os.file.read $1 $2;;
		1) 	os.file.read $1 $(($cur+$2));;
		2)	os.file.read $1 $(os.file.size $1);;
		*) 	error.trace def 'whence' 'uint' "$3" "$__ERR_OS_SEEK_FLAG"; return $?;;
	esac 1>/dev/null

	return 0
}

source.__INIT__
# /* __OS_SH */ #
