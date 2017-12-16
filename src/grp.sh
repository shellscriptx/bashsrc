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

    local grp IFSbkp m
	local filedb=/etc/group

    if [ -r "$filedb" ]; then
        IFSbkp=$IFS
        IFS=':'; while read grp _ _ _; do
            echo "$grp"
        done < $filedb
        IFS=$IFSbkp
    else
        error.__exit '' '' '' "'$filedb' $__USER_ERR_READ_BASE_FILE"
    fi

    return $?
}

