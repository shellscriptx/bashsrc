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

[[ $__USER_SH ]] && return 0

readonly __USER_SH=1

source builtin.sh

var user_t struct_t

user_t.__add__ \
	username	str \
	uid			uint \
	gid			uint \
	home		str \
	shell		str \
	gecos		str \
	pass		str

# func user.getuid => [uint]
#
# Retorna o id do usuário atual.
#
function user.getuid(){ getopt.parse 0 $@; echo "$UID"; return $?;  }

# func user.geteuid => [uint]
#
# Retorna o id efetivo do usuário atual.
#
function user.geteuid(){ getopt.parse 0 $@; echo "$EUID"; return $?;  }

# func user.getgid => [uint]
#
# Retorna o id do grupo do usuário atual.
#
function user.getgid(){ getopt.parse 0 $@; echo "${GROUPS[0]}"; return $?;  }

# func user.getgids => [uint]
#
# Retorna o id dos grupos do usuário atual.
#
function user.getgids(){ getopt.parse 0 $@; echo "${GROUPS[@]}"; return $?;  }

# func user.getlogin <[user_t]struct> <[str]username> => [bool]
#
# Salva em 'struct' as informações do usuário especificado.
# Retorna 'true' para sucesso, caso contrário 'false'.
#
function user.getlogin(){ user.__get_stuser "$1" "$2" ${@:3}; return $?; }

# func user.getuser <[user_t]struct>
#
# Salva em 'struct' as informações do usuário atual.
#
function user.getuser(){  user.__get_stuser "$1" "$USER" ${@:3}; return $?; }

function user.__get_stuser() 
{
	getopt.parse 2 "struct:user_t:+:$1" "username:str:+:$2" ${@:3}
	
	while IFS=':' read user pass uid gid gecos home shell; do
		if [[ $2 == $user ]]; then
			$1.username  = "$user"
			$1.uid = "$uid"
			$1.gid = "$gid"
			$1.home = "$home"
			$1.shell = "$shell"
			$1.gecos = "$gecos"
			$1.pass = "$pass"
			return 0
		fi
	done < /etc/passwd || error.def

	return 1
}

source.__INIT__
# /* __USER_SH */
