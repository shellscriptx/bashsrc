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

[[ $__SOCKET_SH ]] && return 0

readonly __SOCKET_SH=1

source builtin.sh

readonly __SOCKET_MAX_CONN=1024					# limite de conexões
readonly __SOCKET_FLAG_PROTOCOL='@(tcp|udp)'

__DEP__=(
[nc]=
)

# Tipo
__TYPE__[socket_t]='
socket.socket
socket.connect
socket.fileno
socket.peername
socket.port
socket.proto
socket.close
socket.send
socket.recv
'

__TYPE__[socket_in_t]='
socket.bind
socket.listen
socket.recvmsg
'

#__TYPE__[socket_conn_t]='
#socket.read
#'

var sockaddr_t		struct_t
var sockaddr_in_t	struct_t

# Estrutura de conexão.
sockaddr_t.__add__      port        uint        \
                        protocol    flag        \
                        address     str

sockaddr_in_t.__add__	protocol	flag	\
			port		uint

# func socket.socket <[socket_t]sock> <[sockaddr_t]address> => [bool]
#
# Cria soquete de conexão com o host apontado na estrutura 'address' e salva
# o descritor em 'sock'.
#
function socket.socket()
{
    getopt.parse 2 "sock:socket_t:+:$1" "address:sockaddr_t:+:$2" "${@:3}"

    local __fileno
    
	# Estrutura de conexão
    local   __port=$($2.port)       \
            __proto=$($2.protocol)  \
            __addr=$($2.address)

	if ! [[ $__port && $__proto && $__addr ]]; then
		error.trace def 'address' 'sockaddr_t' '' 'falha ao definir a estrutura de conexão'
		return $?
	elif [[ $__proto != $__SOCKET_FLAG_PROTOCOL ]]; then
		error.trace def 'address' 'sockaddr_t' "$__proto" 'protocolo invalido'
		return $?
	fi
		
    # Obtem o descritor disponível.
    for ((__fileno=0; i <= __SOCKET_MAX_CONN; __fileno++)); do
        [[ -t $__fileno ]] || break
    done

    if [[ $__fileno -eq $__SOCKET_MAX_CONN ]];  then
        error.strerror 1 'limite máximo de conexões alcançado'
        return $?
    fi
	
	printf -v $1 '%s|%s|%s|%s' \
		"$__fileno"	\
		"$__proto"	\
		"$__addr"	\
		"$__port"

    return $?
}

# func socket.connect <[socket_t]sock> => [bool]
#
# Conecta 'sock' ao host remoto em 'timeout' segundos.
# Obs: finaliza a conexão caso o tempo limite seja excedido.
#
function socket.connect()
{
	getopt.parse 1 "sock:socket_t:+:$1" "${@:2}"
	
	local -n __ref=$1
	local __sock_info __conn __pid __ret

	IFS='|' read -a __sock_info <<< $__ref
	__conn="${__sock_info[0]}<>/dev/${__sock_info[1]}/${__sock_info[2]}/${__sock_info[3]}"

	if ! eval exec "$__conn" &>/dev/null; then
		error.format 1 "não foi possível conectar em '%s:%s'" "${__sock_info[2]}" "${__sock_info[3]}"
		return $?
	fi 
	
	return $?
}

# func socket.fileno <[socket_t]sock> => [uint]
#
# Retorna um inteiro que representa o descritor de arquivo do socket.
#
function socket.fileno()
{
	getopt.parse 1 "sock:socket_t:+:$1" "${@:2}"

	socket.__check_socket $1 || return $?
	
	local -n __ref=$1
	local __sock_info

	IFS='|' read -a __sock_info <<< $__ref
	echo "${__sock_info[0]}"

	return $?	
}

# func socket.peername <[socket_t]sock> => [str]
#
# Retorna o endereço do host remoto vinculado ao soquete.
#
function socket.peername()
{
	getopt.parse 1 "sock:socket_t:+:$1" "${@:2}"

	socket.__check_socket $1 || return $?
	
	local -n __ref=$1
	local __sock_info

	IFS='|' read -a __sock_info <<< $__ref
	echo "${__sock_info[2]}"

	return $?	
}

# func socket.port <[socket_t]sock> => [uint]
#
# Retorna a porta do soquete.
#
function socket.port()
{
	getopt.parse 1 "sock:socket_t:+:$1" "${@:2}"

	socket.__check_socket $1 || return $?
	
	local -n __ref=$1
	local __sock_info

	IFS='|' read -a __sock_info <<< $__ref
	echo "${__sock_info[3]}"

	return $?	
}

# func socket.proto <[socket_t]sock> => [str]
#
# Retorna o protocolo de conexão do soquete.
#
function socket.proto()
{
	getopt.parse 1 "sock:socket_t:+:$1" "${@:2}"

	socket.__check_socket $1 || return $?
	
	local -n __ref=$1
	local __sock_info

	IFS='|' read -a __sock_info <<< $__ref
	echo "${__sock_info[1]}"

	return $?	
}

# func socket.close <[socket_t]sock> => [str]
#
# Fecha o soquete de conexão.
#
function socket.close()
{
	getopt.parse 1 "sock:socket_t:+:$1" "${@:2}"

	socket.__check_socket $1 || return $?
	
	local -n __ref=$1
	eval exec "${__ref%%|*}<&-"
	del $1
		
	return $?
}

# func socket.send <[socket_t]sock> <[str]msg> => [bool]
#
# Envia mensagem ao soquete.
#
function socket.send()
{
    getopt.parse 2 "sock:socket_t:+:$1" "msg:str:+:$2" "${@:3}"

	socket.__check_socket $1 || return $?

	local -n __ref=$1
	echo -e "$2" >&${__ref%%|*}

	return $?
}

# func socket.recv <[socket_t]sock> <[int]buffsize> => [str]
#
# Recebe até 'buffsize' bytes de 'socket'.
# Se buffsize < 0 lê todos os bytes.
#
function socket.recv()
{
	getopt.parse 2 "sock:socket_t:+:$1" "buffsize:int:+:$2" "${@:3}"
	
	socket.__check_socket $1 || return $?

	local -n __ref=$1
	local __bytes

	if (($2 > 0)); then
		read -N$2 __bytes <&${__ref%%|*}
		echo "$__bytes"
	else
		while read __bytes <&${__ref%%|*}; do
			echo "$__bytes"
		done
	fi

	return $?
}

# func socket.listen <[socket_in_t]sock> <[sockaddr_in_t]address> => [bool]
#
function socket.bind()
{
	getopt.parse 2 "sock:socket_in_t:+:$1" "address:sockaddr_in_t:+:$2" "${@:3}"

	local 	__conn_sock	\
		__port=$($2.port) \
		__proto=$($2.protocol)

	if ! [[ $__port && $__proto ]]; then
        	error.trace def 'address' 'sockaddr_in_t' "$1" 'falha ao definir a estrutura de conexão'
        	return $?
	elif [[ $__proto != $__SOCKET_FLAG_PROTOCOL ]]; then
		error.trace def 'address' 'sockaddr_t' "$__proto" 'protocolo inválido'
		return $?
	fi

	__conn_sock=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.sock)
	__proto=${__proto/#udp/u}
	__proto=${__proto/#tcp/}

	printf -v $1 '%s|%s|%s'		\
			"$__proto"	\
			"$__port"	\
			"$__conn_sock"
	
	return $?
}

function socket.listen()
{
	getopt.parse 1 "sock:socket_in_t:+:$1" "${@:2}"

	local -n __ref=$1
	local __port __proto __conn_sock __conn_pid
	
	IFS='|' read __proto __port __conn_sock __conn_pid <<< $__ref

	kill -SIGINT $__conn_pid &>/dev/null
	rm -f $__conn_sock

	if ! mkfifo $__conn_sock &>/dev/null; then
		error.strerror 1 'falha ao criar soquete de conexão'
		return $?
	elif ! cat $__conn_sock | nc -${__proto}l $__port 2>/dev/null 1>$__conn_sock; then
		trap "rm -f $__conn_sock &>/dev/null" SIGINT SIGTERM
		error.format 1 "'%s:%s': erro ao abrir a porta de conexão" "$__proto" "$__port"
		return $?
	fi &

	printf -v $1 '%s|%s|%s|%s'	\
			"$__proto"	\
			"$__port"	\
			"$__conn_sock"	\
			"$!"

	return $?	
}

function socket.recvmsg()
{
	getopt.parse 1 "sock:socket_in_t:+:$1" "${@:2}"
	
	local -n __ref=$1
	local __conn_sock

	IFS='|' read _ _ __conn_sock _ <<< $__ref

	if ! [[ -e $__conn_sock ]]; then

		error.strerror 1 'não foi possível ler o soquete de conexão'
		return $?
	fi

	cat $__conn_sock &

	return $?
}

function socket.sendmsg()
{
	getopt.parse 2 "sock:socket_in_t:+:$1" "msg:str:+:$2" "${@:3}"
	
	local -n __ref=$1
	local __conn_sock

	IFS='|' read _ _ __conn_sock _ <<< $__ref

	if ! [[ -e $__conn_sock ]]; then

		error.strerror 1 'não foi possível ler o soquete de conexão'
		return $?
	fi

	echo "$2" > $__conn_sock

	return $?
}


function socket.__check_socket()
{
	local -n __ref=$1
	[[ -S /proc/self/fd/${__ref%%|*} ]] || error.trace def 'sock' 'socket_t' "$1" 'soquete de conexão não encontrado'
	return $?	
}

source.__INIT__
# /* __SOCKET_SH */
