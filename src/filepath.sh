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

[[ $__FILEPATH_SH ]] && return 0

readonly __FILEPATH_SH=1

source builtin.sh

__TYPE__[path_t]='
filepath.ext
filepath.basename
filepath.dirname
filepath.relpath
filepath.split
filepath.splitlist
filepath.slash
filepath.ismatch
filepath.match
filepath.exists
filepath.listdir
filepath.scandir
filepath.fnscandir
filepath.fnlistdir
filepath.copy
'

__TYPE__[fileinfo_t]='
filepath.fileinfo.name
filepath.fileinfo.size
filepath.fileinfo.mode
filepath.fileinfo.modtime
filepath.fileinfo.modstime
filepath.fileinfo.isdir
filepath.fileinfo.perm
filepath.fileinfo.ext
filepath.fileinfo.type
filepath.fileinfo.inode
filepath.fileinfo.path
filepath.fileinfo.gid
filepath.fileinfo.group
filepath.fileinfo.uid
filepath.fileinfo.user
'

# Erros
readonly __ERR_FILEPATH_READ_DIR='acesso negado: não foi possível ler o diretório'
readonly __ERR_FILEPATH_COPY_PATH='não foi possível copiar o arquivo ou diretório'
readonly __ERR_FILEPATH_WRITE_DENIED='acesso negado: não foi possível criar o arquivo'
readonly __ERR_FILEPATH_READ_DENIED='acesso negado: não foi possível ler o arquivo'

# func filepath.ext <[str]path> => [str]
#
# Retorna a extensão do arquivo contido em 'path'.
#
function filepath.ext()
{
    getopt.parse 1 "path:str:+:$1" ${@:2}
    [[ $1 =~ \.[a-zA-Z0-9_-]+$ ]]
    echo "${BASH_REMATCH[0]}"
    return 0
}

# func filepath.basename <[str]path> => [str]
#
# Retorna o nome do arquivo removendo os componentes de diretório.
#
function filepath.basename()
{
    getopt.parse 1 "path:str:+:$1" ${@:2}
    echo "${1##*/}"
    return 0
}

# func filepath.dirname <[str]path> => [str]
#
# Retorna o componente de diretório de um nome de caminho.
#
function filepath.dirname()
{
    getopt.parse 1 "path:str:+:$1" ${@:2}
    echo "${1%/*}"
    return 0
}

# func filepath.relpath <[str]path> => [str]
#
# Retorna o caminho relativo de 'path'.
#
function filepath.relpath()
{
    getopt.parse 1 "path:str:+:$1" ${@:2}

    local IFSbkp cur path relpath slash item i

    IFSbkp=$IFS; IFS='/'
    cur=(${PWD#\/}); path=(${1#\/})
    IFS=$IFSbkp
        
    for ((i=${#cur[@]}-1; i >= 0; i--)); do
        [[ "${cur[$i]}" == "${path[0]}" ]] && break
        slash+='../'
    done
        
    for item in "${path[@]:$((i >= 0 ? 1 : 0))}"; do
        relpath+=$item'/'
    done

    relpath=${slash}${relpath%\/}

    echo "${relpath:-.}"

    return 0
}

# func filepath.split <[str]path> => [str]
#
# Divide os componentes do caminho em 'path' retornando uma string
# delimitada por '|' PIPE no formato: dirname|filename
#
function filepath.split()
{
	getopt.parse 1 "path:str:+:$1" ${@:2}
	echo "$(filepath.dirname "$1")|$(filepath.basename "$1")"
	return 0
}

# func filepath.splitlist <[str]path> => [str]
#
# Retorna uma lista iterável contendo os componentes do caminho no
# formato:
#
# dirname
# filename
#
function filepath.splitlist()
{
	getopt.parse 1 "path:str:+:$1" ${@:2}
	filepath.dirname "$1"
	filepath.basename "$1"
	return 0
}

# func filepath.slash <[str]path> => [str]
#
# Retorna uma lita iterável removendo o separador de diretório '/'.
#
function filepath.slash()
{
	getopt.parse 1 "path:str:+:$1" ${@:2}

	local path
	path=${1##+(/)}
	path=${1%%+(/)}
	echo -e "${path//\//\\n}"

	return 0	
}

# func filepath.join <[str]elem> ... => [str]
#
# Junta N'elem' em um único caminho.
#
function filepath.join()
{
	getopt.parse -1 "elem:str:+:$1" ... "${@:2}"

	local slash path

	for slash in "$@"; do
		slash=${slash##+(/)}
		slash=${slash%%+(/)}
		path+='/'$slash	
	done

	echo "$path"

	return 0
}

# func filepath.ismatch <[path]path> <[str]pattern> => [bool]
# 
# Retorna 'true' se o caminho corresponde com o padrão em 'pattern',
# caso contrário 'false'.
#
# Pattern pode ser uma expressão regular.
# 
# Exemplo:
#
# #!/bin/bash
#
# source filepath.sh
#
# # Declara e implementa 'file' com o tipo 'filepath'.
# var file path_t
#
# # Lendo os arquivos do diretório '/etc'.
# while read file; do
#     # Exibindo somente os arquivos com a extensão '.conf'
#     file.ismatch '.conf$' && file.basename
# done < <(filepath.listdir '/etc')
#
# Saida:
#
# adduser.conf
# apg.conf
# appstream.conf
# brltty.conf
# ca-certificates.conf
# dconf
# debconf.conf
# deluser.conf
# fuse.conf
# fwupd.conf
# ...
#
function filepath.ismatch()
{
	getopt.parse 2 "path:path:+:$1" "pattern:str:+:$2" ${@:3}
	[[ $1 =~ $2 ]]
	return $?
}

# func filepath.match <[path]path> <[str]pattern> => [str]
#
# Retorna o padrão casado em 'path'. A sequência em 'pattern' pode ser uma expressão regular.
#
function filepath.match()
{
	getopt.parse 2 "path:path:+:$1" "pattern:str:+:$2" ${@:3}
	[[ $1 =~ $2 ]] && echo ${BASH_REMATCH[0]}
	return $?
}

# func filepath.exists <[str]path> => [bool]
#
# Retorna 'true' se o caminho em 'path' existe, caso contrário 'false'.
#
function filepath.exists()
{
	getopt.parse 1 "path:str:+:$1" ${@:2}
	[[ -e "$1" ]]
	return $?
}

# func filepath.glob <[str]pattern> => [str]
#
# Retorna uma lista iterável contendo os nomes de todos os arquivos casados
# com 'pattern'.
#
function filepath.glob()
{
	getopt.parse 1 "pattern:str:+:$1" ${@:2}
	
	local file

	if [ -x "${1%/*}" ]; then	
		for file in "${1%/*}/"${1##*/}; do
			[[ "$file" == "${1%/*}/${1##*/}" ]] && break
			echo "$file"
		done
	else
		error.trace def 'path' 'dir' "${1%/*}" "$__ERR_FILEPATH_READ_DIR"; return $?
	fi
	
	return $?
}

# func filepath.listdir <[dir]dir> => [str]
#
# Retorna uma lista iterável com o caminho completo de todos os arquivos em 'path'.
#
function filepath.listdir()
{
	getopt.parse 1 "dir:dir:+:$1" ${@:2}

	local file

	for file in "${1%/}/"* "${1%/}/".*; do 
		[[ ${file##*/} == @(.|..) ]] && continue
		echo "$file"
	done

	return 0
}

# func filepath.scandir <[dir]dir> => [str]
#
# Retorna uma lista iterável com o caminho completo de todos os arquivos em 'path'
# e sub-diretórios (recursivo).
#
function filepath.scandir()
{
	getopt.parse 1 "dir:dir:+:$1" ${@:2}
	
	local file

	for file in "${1%/}/"* "${1%/}/".*; do
		if [[ -d "$file" && ! -L "$file" ]]; then
			[[ ${file##*/} == @(.|..) ]] && continue
			filepath.scandir "$file"
		elif [[ -f "$file" ]]; then
			echo "$file"
		fi
	done

	return 0
}

# func filepath.fnscandir <[dir]dir> <[func]funcname> <[str]args> ...
#
# Chama 'funcname' a cada iteração de arquivo em 'path' e sub-diretórios (recursivo),
# passando como argumento posicional '$1' o caminho completo do arquivo atual com N'args' (opcional).
# Obs: Não lê arquivos ocultos.
#
# Exemplo:
#
# # Usando a função 'filepath.match' para listar somente os arquivos 'mp4', 'mp3' e 'avi'
# # contidos em um diretório (recursivo).
#
# $ source filepath.sh
# 
# $ filepath.fnscandir '/home/usuario/Downloads' filepath.match '^.*\.(mp4|avi|mp3)$'
#
function filepath.fnscandir()
{
	getopt.parse -1 "dir:dir:+:$1" "funcname:func:+:$2" "args:str:-:$3" ... "${@:4}"
	
	local file

	for file in "${1%/}/"* "${1%/}/".*; do
		if [[ -d "$file" && ! -L "$file" ]]; then
			[[ ${file##*/} == "." || ${file##*/} == ".." ]] && continue
			filepath.fnscandir "$file" $2 "${@:3}"
		elif [[ -f "$file" ]]; then
			$2 "$file" "${@:3}"
		fi
	done

	return 0
}

# func filepath.fnlistdir <[dir]dir> <[func]funcname> <[str]args> ...
#
# Chama 'funcname' a cada iteração em 'path' passando como argumento posicional '$1'
# o caminho absoluto do arquivo ou diretório com N'args' (opcional), 
#
# Exemplo 1:
#
# # Utilizando a função builtin 'filepath.fileinfo.perm' na chamada para exibir
# # a permissão de cada arquivo contido no diretório '/etc'.
#
# #!/bin/bash
#
# source filepath.sh
#
# filepath.fnlistdir '/etc' filepath.fileinfo.perm
#
# Saida:
#
# drwxr-xr-x
# -rw-r--r--
# drwxr-xr-x
# -rw-r--r--
# drwxr-xr-x
# -rw-r--r--
# drwxr-xr-x
# drwxr-xr-x
# drwxr-xr-x
# drwxr-xr-x
# ...
#
# Exemplo 2:
#
# # Implementando uma função para exibir nome e tamanho do arquivo.
# 
# #!/bin/bash
#
# source filepath.sh
#
# # Define variável do tipo 'fileinfo'
# var arq fileinfo_t
#
# exibir_tamanho(){
#
#    # Recebe o caminho do arquivo
#    arq=$1
#
#    echo "arquivo: $(arq.name)"
#    echo "tamanho: $(arq.size) bytes"
#    echo ---
# }
#
# filepath.fnlistdir '/etc' exibir_tamanho
#
# Saida:
#
# arquivo: usb_modeswitch.conf
# tamanho: 1018 bytes
# ---
# arquivo: usb_modeswitch.d
# tamanho: 4096 bytes
# ---
# arquivo: vdpau_wrapper.cfg
# tamanho: 51 bytes
# ---
# arquivo: vim
# tamanho: 4096 bytes
# ---
# arquivo: vtrgb
# tamanho: 23 bytes
#
function filepath.fnlistdir()
{
	getopt.parse -1 "dir:dir:+:$1" "walkfunc:func:+:$2" "args:str:-:$3" ... "${@:4}"

	local file
	
	if [[ -x "$1" ]]; then
		for file in "${1%/}/"* "${1%/}/".*; do 
			[[ ${file##*/} == "." || ${file##*/} == ".." ]] && continue
			$2 "$file" "${@:3}"
		done
	else
		error.trace def 'path' 'dir' "$1" "$__ERR_FILEPATH_READ_DIR"; return $?
	fi

	return $?
}

# func filepath.copy <[path]src> <[dir]dest> <[uint]override>
#
# Copia 'src' para 'dest'. Se 'src' for um diretório realiza um cópia recursiva.
#
# override:
#
# 0 - Não sobrepoẽ.
# 1 - Sobrepoẽ todos o(s) arquivo(s) ou diretório(s) já existentes em 'dest'.
#
function filepath.copy()
{
	getopt.parse 3 "src:path:+:$1" "dest:dir:+:$2" "override:uint:+:$3" ${@:4}
	
	local flag err

	if [ -w "$2" ]; then
		case $3 in
			0) return 0;;
			1) ;;
			*) err=1; error.trace def 'override' 'uint' "$3" 'flag inválida'; return $?;;
		esac
		
		if [ ! "$err" ]; then

			[ -d "$1" ] && flag='r'

			cp -${flag}f "$1" "$2" &>/dev/null ||
			error.trace def 'dest' 'dir' "$1" "$__ERR_FILEPATH_COPY_PATH"; return $?
		fi
	else	
		error.trace def 'dest' 'dir' "$2" "$__ERR_FILEPATH_WRITE_DENIED"; return $?
	fi
		
	return $?
}

# func filepath.diff <[file]file1> <[file]file2> => [str]
#
# Compara 'file1' com 'file2' e retorna as linhas diferentes se houver.
# As linhas são retornas no seguinte formato:
#
# num_linha|file1_linha|file2_linha
#
function filepath.diff()
{
	getopt.parse 2 "file1:file:+:$1" "file2:file:+:$2" ${@:3}
	
	local f1 f2 l1 l2 i df
	
	if [[ ! -r "$1" ]]; then
		error.trace def 'file1' 'file' "$1" "$__ERR_FILEPATH_READ_DENIED"; return $?
	elif [[ ! -r "$2" ]]; then
		error.trace def 'file2' 'file' "$2" "$__ERR_FILEPATH_READ_DENIED"; return $?
	else
		mapfile -t f1 < "$1"
		mapfile -t f2 < "$2"
	
		df=0; i=0; l1=${f1[0]}; l2=${f2[0]}

		while [[ $l1 || $l2 ]]; do
			[[ "$l1" != "$l2" ]] && echo "$((i+1))|$l1|$l2" && df=1
			((i++)); l1=${f1[$i]}; l2=${f2[$i]}
		done
	fi

	return ${df:-$?}
}

# func filepath.equal <[file]file1> <[file]file2> => [bool]
#
# Retorna 'true' se 'file1' é igual a 'file2'. Caso contrário 'false'.
#
function filepath.equal()
{
	getopt.parse 2 "file1:file:+:$1" "file2:file:+:$2" ${@:3}
	filepath.diff "$1" "$2" 1>/dev/null
	return $?
}

# func filepath.fileinfo.name <[path]path> => [str]
#
# Retorna o nome do arquivo no componente 'path'.
#
function filepath.fileinfo.name()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	filepath.basename "$1"
	return 0
}

# func filepath.fileinfo.size <[path]path> => [uint]
#
# Retorna o tamanho em bytes de 'path'.
#
function filepath.fileinfo.size()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%s" "$1"
	return 0
}

# func filepath.fileinfo.mode <[path]path> => [oct]
#
# Retorna as permissões de 'path' em base octal. 
#
function filepath.fileinfo.mode()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%a" "$1"
	return $?
}

# func filepath.fileinfo.modtime <[path]>path> => [str]
#
# Retorna a data da última modificação de 'path'.
#
function filepath.fileinfo.modtime()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%z" "$1"
	return $?
}

# func filepath.fileinfo.modstime <[path]path> => [uint]
#
# Retorna a data em segundos da última modificação de 'path'
function filepath.fileinfo.modstime()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%Z" "$1"
	return $?
}

# func filepath.fileinfo.isdir <[path]path> => [bool]
#
# Retorna 'true' se 'path' é um diretório. Caso contrário 'false'.
#
function filepath.fileinfo.isdir()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	[[ -d "$1" ]]
	return $?
}

# func filepath.fileinfo.perm <[path]path> => [bool]
#
# Retorna as permissões de 'path' em leitura humana.
#
function filepath.fileinfo.perm()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%A" "$1"
	return $?
}

# func filepath.fileinfo.ext <[path]path> => [str]
#
# Retorna a extensão do arquivo em 'path'.
#
function filepath.fileinfo.ext()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	filepath.ext "$1"
	return $?
}

# func filepath.fileinfo.type <[path]path> => [str]
#
# Retorna o tipo do arquivo em 'path'.
#
function filepath.fileinfo.type()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%F" "$1"
	return $?
}

# func filepath.fileinfo.inode <[path]path> => [str]
#
# Retorna o identificador único de 'path'.
#
function filepath.fileinfo.inode()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%i" "$1"
	return $?
}

# func filepath.fileinfo.path <[path]path> => [str]
#
# Retorna o diretório no componente 'path'.
#
function filepath.fileinfo.path()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	filepath.dirname "$1"
	return $?
}

# func filepath.fileinfo.gid <[path]path> => [uint]
#
# Retorna o id do grupo dono de 'path'.
#
function filepath.fileinfo.gid()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%g" "$1"
	return $?
}

# func filepath.fileinfo.group <[path]path> => [str]
#
# Retorna o nome do grupo dono de 'path'.
#
function filepath.fileinfo.group()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%G" "$1"
	return $?
}

# func filepath.fileinfo.uid <[path]path> => [uint]
#
# Retorna o id do usuário dono de 'path'.
#
function filepath.fileinfo.uid()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%u" "$1"
	return $?
}

# func filepath.fileinfo.user <[path>path> => [str]
#
# Retorna o nome do usuário dono de 'path'.
#
function filepath.fileinfo.user()
{
	getopt.parse 1 "path:path:+:$1" ${@:2}
	stat --format "%U" "$1"
	return $?
}

source.__INIT__
# /* __FILEPATH_SH */
