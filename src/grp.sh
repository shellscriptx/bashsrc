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

[ -v __GRP_SH__ ] && return 0

readonly __GRP_SH__=1

source builtin.sh

# .FUNCTION grp.getgroups -> [uint]|[bool]
#
# Retorna os IDs de grupo suplementares da chamada do processo.
#
function grp.getgroups()
{
	getopt.parse 0 "$@"

	printf '%s\n' ${GROUPS[@]}
	return $?
}

# .FUNCTION grp.getgrall -> [str]|[bool]
#
# Retorna uma lista com todos os grupos do sistema.
#
function grp.getgrall()
{
	getopt.parse 0 "$@"
	
	local grp
	
	while IFS=':' read grp _; do
		echo $grp
	done < /etc/group

	return $?
}

# .FUNCTION grp.getgrnam <name[str]> <grp[map]> -> [bool]
#
# Obtém no banco de dados as informações do grupo especificado.
#
function grp.getgrnam()
{
	getopt.parse 2 "name:str:$1" "grp:map:$2" "${@:3}"
	
	local __name__ __pass__ __gid__ __mem__
	local -n __ref__=$2

	__ref__=() || return 1

	while IFS=':' read	__name__	\
						__pass__	\
						__gid__		\
						__mem__; do
		[[ $1 == $__name__ ]] && break
	done < /etc/group

	(($?)) && { error.error "'$1' grupo não encontrado"; return $?; }
	
	__ref__[gr_name]=$__name__
	__ref__[gr_passwd]=$__pass__
	__ref__[gr_gid]=$__gid__
	__ref__[gr_mem]=$__mem__
		
	return $?
}

# .FUNCTION grp.getgrgid <gid[uint]> <grp[map]> -> [bool]
#
# Obtém no banco de dados as informações do id do grupo especificado.
#
function grp.getgrgid()
{
	getopt.parse 2 "gid:uint:$1" "grp:map:$2" "${@:3}"
	
	local __name__ __pass__ __gid__ __mem__
	local -n __ref__=$2

	__ref__=() || return 1

	while IFS=':' read	__name__	\
						__pass__	\
						__gid__		\
						__mem__; do
		[[ $1 == $__gid__ ]] && break
	done < /etc/group

	(($?)) && { error.error "'$1' gid não encontrado"; return $?; }
	
	__ref__[gr_name]=$__name__
	__ref__[gr_passwd]=$__pass__
	__ref__[gr_gid]=$__gid__
	__ref__[gr_mem]=$__mem__
		
	return $?
}

# .MAP grp
#
# Chaves:
#
# gr_name      /* Nome do grupo */
# gr_passwd    /* Senha criptgrafada do grupo ou vazio. */
# gr_gid       /* Identificador númerico do grupo */
# gr_mem       /* Lista de usuários ou membros do grupos separados por vírgula (,). */
#

# Funções (somente leitura)
readonly -f	grp.getgroups	\
			grp.getgrall	\
			grp.getgrnam	\
			grp.getgrgid

# /* __GRP_SH__ */

