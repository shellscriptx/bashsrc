#!/bin/bash

source builtin.sh

SRC_TYPE_IMPLEMENTS[f]='
teste.plus
'

builtin.__TYPES__


teste.plus()
{
	getopt.parse "num:var:+:$1"
	
	declare -n __ref=$1
	((__ref++))
	return 0
}
