#!/bin/bash

[[ $__GRP_SH ]] && return 0

readonly __GRP_SH=1

source builtin.sh

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
        error.__exit '' '' '' "'$filedb' $__USER_ERR_READ_BASE_FILE"
		err=1
    fi

    return ${err:-0}
}

function grp.name()
{
	getopt.parse "gid:str:+:$1"
	grp.__get_gid_info grp $1
	return $?
}

function grp.passwd()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_gid_info pass $1
	return $?
}

function grp.members()
{
	getopt.parse "grpname:str:+:$1"
	printf '%s\n' $(grp.__get_gid_info mem $1)
	return $?
}

function grp.gid()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_gid_info gid $1
	return $?
}

function grp.info()
{
	getopt.parse "grpname:str:+:$1"
	grp.__get_gid_info all $1
	return $?
}

function grp.__get_gid_info()
{
	local grp pass gid mem
	local filedb=/etc/group
	local err=1
	local IFSbkp=$IFS
	local flag=$1
	local name=$2

	if [ -r "$filedb" ]; then	
		IFS=':'; while read grp pass gid mem; do
			if [[ "$flag" == "grp" && "$name" == "$gid" ]]; then
				err=0; info=$grp; break
			elif [[ "$name" == "$grp" ]]; then
				case $flag in
					pass)	info=$pass; break;;
					gid)	info=$gid; break;;
					mem)	info=${mem//,/ }; break;;
					all)	info="$grp|$pass|$gid|$mem"; break;;
					*) return 1; break;;
				esac
				err=0
			fi
		done < $filedb
	else
        error.__exit '' '' '' "'$filedb' $__USER_ERR_READ_BASE_FILE"
	fi

	IFS=$IFSbkp
	
	echo "$info"

	return $err
}
