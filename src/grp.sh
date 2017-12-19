#!/bin/bash

[[ $__GRP_SH ]] && return 0

readonly __GRP_SH=1

source builtin.sh

# type group
#
# Implementa 'S' com os métodos:
#
# S.passwd => [str]
# S.members => [str]
# S.gid => [uint]
# S.info => [str]
#

# func grp.getgrall => [str]
#
# Retorna uma lista iterável com o nome de todos os grupos do sistema.
#
function grp.getgrall()
{
    getopt.parse "-:null:-:$*"

    local grp IFSbkp
	local filedb=/etc/group
	
    if [ -r "$filedb" ]; then
        IFSbkp=$IFS
        IFS=':'; while read grp _ _ _; do
            echo "$grp"
        done < $filedb
        IFS=$IFSbkp
    else
        error.__exit '' '' '' "'$filedb' não foi possível ler o arquivo base"
		err=1
    fi

    return ${err:-0}
}

# func grp.name <[uint]gid> => [str]
#
# Retorna o nome do grupo associado ao 'gid'.
#
function grp.name()
{
	getopt.parse "gid:uint:+:$1"
	grp.__get_grp_info grp "$1"
	return $?
}

# func grp.passwd <[str]grpname> => [str]
#
# Retorna a flag de senha.
#
function grp.passwd()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_grp_info pass "$1"
	return $?
}

# func grp.members <[str]grpname> => [str]
#
# Retorna uma lista iterável com os membros de 'grpname'.
#
function grp.members()
{
	getopt.parse "grpname:str:+:$1"
	printf '%s\n' $(grp.__get_grp_info mem "$1")
	return $?
}

# func grp.gid <[str]grpname> => [uint]
#
# Retorna o 'gid' de 'grpname' associado.
#
function grp.gid()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_grp_info gid "$1"
	return $?
}

# func grp.info <[str]grpname> => [str]
#
# Retorna todas as informações de 'grpname'.
#
function grp.info()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_grp_info all "$1"
	return $?
}

function grp.__get_grp_info()
{
	local grp pass gid mem err
	local filedb=/etc/group
	local IFSbkp=$IFS
	local flag=$1
	local field=$2

	if [ -r "$filedb" ]; then	
		IFS=':'; while read grp pass gid mem; do
			if [[ "$field" == "$grp" || "$field" == "$gid" ]]; then
				err=0
				case $flag in
					grp)	info=$grp; break;;
					pass)	info=$pass; break;;
					gid)	info=$gid; break;;
					mem)	info=${mem//,/ }; break;;
					all)	info="$grp|$pass|$gid|$mem"; break;;
					*) return 1;;
				esac
			fi
		done < $filedb
	else
        error.__exit '' '' '' "'$filedb' não foi possível ler o arquivo base"
	fi

	IFS=$IFSbkp
	
	echo "$info"

	return ${err:-1}
}
