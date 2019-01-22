#!/bin/bash

[[ $__HTTP_SH ]] && return 0

readonly __HTTP_SH=1

readonly HTTP_MOVE=301
readonly HTTP_OK=302
readonly HTTP_OTHER=303
readonly HTTP_TEMP_REDIRECT=307
readonly HTTP_PERM_REDIRECT=308

__TYPE__[url_t]='
http.get
'

var http_resp_t struct_t

http_resp_t.__add__ \
	status			str \
	code			int \
	proto			str \
	location		str \
	content_type	str \
	date			str \
	server			str \
	content_length	uint \
	header			str

function http.get()
{
	getopt.parse 2 "url:str:+:$1" "response:http_resp_t:+:$2" "${@:3}"

	local fd

	while :; do	[[ -t $((++fd)) ]] || break; done
	
	if ! eval "exec $fd<>/dev/tcp/$1/80"; then
		error.trace 'url' 'str' "$1" 'endereço não encontrado'
		return $?
	fi

	echo -e "GET / \n" >&$fd
	
	while IFS=':' read -r opt value <&$fd; do
		IFS=$'\r' read value _ <<< "$value"
		value=${value# }
		case ${opt,,} in
			@(http)*) 
				IFS=' ' read proto code status <<< "$opt"
				$2.status = "$code $status"
				$2.code = "$code"
				$2.proto = "$proto";;
			location)
				$2.location = "$value";;
			content-type)
				$2.content_type = "$value";;
			content-length)
				$2.content_length = "$value";;
			date)
				$2.date = "$value";;
			server)
				$2.server = "$value";;
			@(<html><head>)*)
				header=1;;
		esac
		[[ $header ]] && data+="$opt"
	done
	
	$2.header = "$data"
	
	return 0
}

source.__INIT__
# /* __HTTP_SH */
