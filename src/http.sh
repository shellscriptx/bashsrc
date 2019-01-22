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

[ -v __HTTP_SH__ ] && return 0

readonly __HTTP_SH__=1

source builtin.sh
source struct.sh
source setup.sh

# Dependência.
setup.package 'curl (>= 7.0)'

readonly -A __HTTP__=(
[methods]='@(GET|POST|HEAD|PUT|DELETE|CONNECT|OPTIONS|TRACE)'
)

# .FUNCTION http.get <url[str]> <response[map]> -> [bool]
#
# Envia uma requisição ao servidor e salva a resposta no
# mapa apontado por 'response'.
#
# == EXEMPLO ==
#
# #!/bin/bash
#
# source http.sh
#
# # mapa
# declare -A resp=()
#
# http.get 'ipecho.net/plain' resp
# echo 'IP externo:' ${resp[body]}
#
# == SAÍDA ==
#
# IP externo: 179.72.180.201
#
function http.get()
{
	getopt.parse 2 "url:str:$1" "response:map:$2" "${@:3}"

	local __resp__ __header__ __value__ __bodyfile__
	local -n __ref__=$2

	__ref__=() || return 1

	# Arquivo temporário que irá armazenar o contéudo da página.
	__bodyfile__=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX)
	trap "rm -f $__bodyfile__ 2>/dev/null" SIGINT SIGTERM SIGKILL SIGTSTP RETURN 

	while IFS=$'\n' read -r __resp__; do
		# Lê os headers de resposta e mapeia as chaves
		# com a nomenclatura de cada header processado,
		# atribuindo os respectivos valores.
		if [ "${__resp__:0:1}" == '<' ]; then
			IFS=' ' read -r _ __header__ __value__ <<< "$__resp__"
			# Se estiver vazio lê o próximo 'header'.
			[[ ! $__value__ ]] && continue
			__header__=${__header__%:}
			__header__=${__header__,,}
			case $__header__ in
				http/1.@(0|1))	__ref__[proto]=$__header__
								__ref__[status]=${__value__%% *};;
				*)				__ref__[$__header__]=$__value__;;
			esac
		fi
	done < <(curl -qsvX GET "$1" --output $__bodyfile__ 2>&1)

	# Conteúdo.
	__ref__[body]=$(< $__bodyfile__)

	return $?
}

# .FUNCTION http.request <method[str]> <url[str]> <fields[map]> <headers[http_header_st]> <response[map]> -> [bool]
#
# Envia uma requisição ao servidor com o método HTTP a ser executado no recurso
# com os campos e cabeçalhos especificados na estrutura 'headers' e salva a
# resposta no mapa apontado por 'response'.
#
# HTTP (métodos): OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, CONNECT
#
# == EXEMPLO ==
#
# O exemplo a seguir utiliza um modelo simples para envio de mensagens
# via API Telegram.
#
# #!/bin/bash
#
# source http.sh
#
# # API
# url_api='https://api.telegram.org/bot<BOT_TOKEN>/sendMessage'
# 
# # Inicializa os arrays associativos.
# declare -A fields=()
# declare -A resp=()
#
# # Cabeçalho (estrutura)
# var header http_header_st
#
# # Definindo configurações.
# header.accept = 'application/json'
#
# # Campos para requisição do método da api.
# fields[chat_id]=181885983
# fields[text]='Enviando mensagem de teste'
#
# # Envia requisição para o servidor.
# http.request 'POST' "$url_api" fields header resp
#
# # Retorno
# echo "${resp[body]}"
#
# == SAÍDA ==
#
# {"ok":true,"result":{"message_id":44471,"from":{"id":371714654,"is_bot":true,"first_name":"BASHBot","username":"bashxxx_bot"},"chat":{"id":181885983,"first_name":"SHAMAN","username":"x_SHAMAN_x","type":"private"},"date":1547900652,"text":"Enviando mensagem de teste"}}
#
function http.request()
{
	getopt.parse 5 "method:str:$1" "url:str:$2" "fields:map:$3" "headers:http_header_st:$4" "response:map:$5" "${@:6}"

	local __field__ __opt__ __bodyfile__ __resp__
	local __value__ __header__ __headers__ __re__
	local -n __fields__=$3 __ref__=$5

	__ref__=() || return 1
	
	if [[ $1 != ${__HTTP__[methods]} ]]; then
		error.error "'$1' HTTP método inválido"
		return 1
	fi
	
	# Arquivo temporário que irá armazenar o contéudo da página.
	__bodyfile__=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX)
	trap "rm -f $__bodyfile__ 2>/dev/null" SIGINT SIGTERM SIGKILL SIGTSTP RETURN 

	# Verifica se formato do contéudo a ser transmitido é um formulário 
	# multipart para upload de arquivos e define a opção adequada.
	# -d (padrão)
	__re__='\bmultipart/form-data\b'
	[[ $($4.accept) =~ $__re__ ]] && __opt__='-F'

	# Cabeçalhos.
	__headers__=(
		[1]=$($4.aim)								# a-im
		[2]=$($4.accept)							# Accept
		[3]=$($4.accept_charset)					# Accept-Charset
		[4]=$($4.accept_encoding)					# Accept-Encoding
		[5]=$($4.accept_language)					# Accept-Language
		[6]=$($4.accept_datetime)					# Accept-Datetime
		[7]=$($4.accept_control_request_method)		# Access-Control-Request-Method
		[8]=$($4.accept_control_request_headers)	# Access-Control-Request-Headers
		[9]=$($4.authorization)						# Authorization
		[10]=$($4.cache_control)					# Cache-Control
		[11]=$($4.connection)						# Connection
		[12]=$($4.content_length)					# Content-Length
		[13]=$($4.content_md5)						# Content-MD5
		[14]=$($4.content_type)						# Content-Type
		[15]=$($4.cookie)							# Cookie
		[16]=$($4.date)								# Date
		[17]=$($4.expect)							# Expect
		[18]=$($4.forwarded)						# Forwarded
		[19]=$($4.from)								# From
		[20]=$($4.host)								# Host
		[21]=$($4.http2_settings)					# HTTP2-Settings
		[22]=$($4.if_match)							# If-Match
		[23]=$($4.if_modified_since)				# If-Modified-Since
		[24]=$($4.if_none_match)					# If-None-Match
		[25]=$($4.if_range)							# If-Range
		[26]=$($4.if_unmodified_since)				# If-Unmodified-Since
		[27]=$($4.max_forwards)						# Max-Forwards
		[28]=$($4.origin)							# Origin
		[29]=$($4.pragma)							# Pragma
		[30]=$($4.proxy_authorization)				# Proxy-Authorization
		[31]=$($4.range)							# Range
		[32]=$($4.referer)							# Referer
		[33]=$($4.te)								# TE
		[34]=$($4.user_agent)						# User-Agent
		[35]=$($4.upgrade)							# Upgrade
		[36]=$($4.via)								# Via
		[37]=$($4.warning)							# Warning
	)

	while IFS=$'\n' read -r __resp__; do
		# Lê os headers de resposta e mapeia as chaves
		# com a nomenclatura de cada header processado
		# atribuindo os respectivos valores.
		if [ "${__resp__:0:1}" == '<' ]; then
			IFS=' ' read -r _ __header__ __value__ <<< "$__resp__"
			# Se estiver vazio lê o próximo 'header'.
			[[ ! $__value__ ]] && continue
			__header__=${__header__%:}
			__header__=${__header__,,}
			case $__header__ in
				http/1.@(0|1))	__ref__[proto]=$__header__
								__ref__[status]=${__value__%% *};;
				*)				__ref__[$__header__]=$__value__;;
			esac
		fi
	done < <(
		# Converte o mapa contendo os campos em parâmetros de linha de comando
		# e envia ao comando 'curl' para processamento com os cabeçalhos definidos.
		for __field__ in "${!__fields__[@]}"; do
			echo "${__opt__:--d} $__field__='${__fields__[$__field__]}' "
		done | xargs -e curl 	-qsvX $1 "$2"																\
								${__headers__[1]:+-H "A-IM: ${__headers__[1]}"}								\
								${__headers__[2]:+-H "Accept: ${__headers__[2]}"}							\
								${__headers__[3]:+-H "Accept-Charset: ${__headers__[3]}"}					\
								${__headers__[4]:+-H "Accept-Encoding: ${__headers__[4]}"}					\
								${__headers__[5]:+-H "Accept-Language: ${__headers__[5]}"}					\
								${__headers__[6]:+-H "Accept-Datetime: ${__headers__[6]}"}					\
								${__headers__[7]:+-H "Access-Control-Request-Method: ${__headers__[7]}"}	\
								${__headers__[8]:+-H "Access-Control-Request-Headers: ${__headers__[8]}"}	\
								${__headers__[9]:+-H "Authorization: ${__headers__[9]}"}					\
								${__headers__[10]:+-H "Cache-Control: ${__headers__[10]}"}					\
								${__headers__[11]:+-H "Connection: ${__headers__[11]}"}						\
								${__headers__[12]:+-H "Content-Length: ${__headers__[12]}"}					\
								${__headers__[13]:+-H "Content-MD5: ${__headers__[13]}"}					\
								${__headers__[14]:+-H "Content-Type: ${__headers__[14]}"}					\
								${__headers__[15]:+-H "Cookie: ${__headers__[15]}"}							\
								${__headers__[16]:+-H "Date: ${__headers__[16]}"}							\
								${__headers__[17]:+-H "Expect: ${__headers__[17]}"}							\
								${__headers__[18]:+-H "Forwarded: ${__headers__[18]}"}						\
								${__headers__[19]:+-H "From: ${__headers__[19]}"}							\
								${__headers__[20]:+-H "Host: ${__headers__[20]}"}							\
								${__headers__[21]:+-H "HTTP2-Settings: ${__headers__[21]}"}					\
								${__headers__[22]:+-H "If-Match: ${__headers__[22]}"}						\
								${__headers__[23]:+-H "If-Modified-Since: ${__headers__[23]}"}				\
								${__headers__[24]:+-H "If-None-Match: ${__headers__[24]}"}					\
								${__headers__[25]:+-H "If-Range: ${__headers__[25]}"}						\
								${__headers__[26]:+-H "If-Unmodified-Since: ${__headers__[26]}"}			\
								${__headers__[27]:+-H "Max-Forwards: ${__headers__[27]}"}					\
								${__headers__[28]:+-H "Origin: ${__headers__[28]}"}							\
								${__headers__[29]:+-H "Pragma: ${__headers__[29]}"}							\
								${__headers__[30]:+-H "Proxy-Authorization: ${__headers__[30]}"}			\
								${__headers__[31]:+-H "Range: ${__headers__[31]}"}							\
								${__headers__[32]:+-H "Referer: ${__headers__[32]}"}						\
								${__headers__[33]:+-H "TE: ${__headers__[33]}"}								\
								${__headers__[34]:+-H "User-Agent: ${__headers__[34]}"}						\
								${__headers__[35]:+-H "Upgrade: ${__headers__[35]}"}						\
								${__headers__[36]:+-H "Via: ${__headers__[36]}"}							\
								${__headers__[37]:+-H "Warning: ${__headers__[37]}"}						\
								--output $__bodyfile__														2>&1
	)

	# Conteúdo
	__ref__[body]=$(< $__bodyfile__)

	return $?
}

# .FUNCTION http.request_data <method[str]> <url[str]> <data[str]> <headers[http_header_st]> <response[map]> -> [bool]
#
# Como 'http.request', porém envia uma string contendo uma estrutura de dados.
#
function http.request_data()
{
	getopt.parse 5 "method:str:$1" "url:str:$2" "data:str:$3" "headers:http_header_st:$4" "response:map:$5" "${@:6}"

	local __field__ __opt__ __bodyfile__ __resp__
	local __value__ __header__ __headers__ __re__
	local -n __ref__=$5

	__ref__=() || return 1
	
	if [[ $1 != ${__HTTP__[methods]} ]]; then
		error.error "'$1' HTTP método inválido"
		return 1
	fi
	
	# Arquivo temporário que irá armazenar o contéudo da página.
	__bodyfile__=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX)
	trap "rm -f $__bodyfile__ 2>/dev/null" SIGINT SIGTERM SIGKILL SIGTSTP RETURN 

	# Cabeçalhos.
	__headers__=(
		[1]=$($4.aim)								# a-im
		[2]=$($4.accept)							# Accept
		[3]=$($4.accept_charset)					# Accept-Charset
		[4]=$($4.accept_encoding)					# Accept-Encoding
		[5]=$($4.accept_language)					# Accept-Language
		[6]=$($4.accept_datetime)					# Accept-Datetime
		[7]=$($4.accept_control_request_method)		# Access-Control-Request-Method
		[8]=$($4.accept_control_request_headers)	# Access-Control-Request-Headers
		[9]=$($4.authorization)						# Authorization
		[10]=$($4.cache_control)					# Cache-Control
		[11]=$($4.connection)						# Connection
		[12]=$($4.content_length)					# Content-Length
		[13]=$($4.content_md5)						# Content-MD5
		[14]=$($4.content_type)						# Content-Type
		[15]=$($4.cookie)							# Cookie
		[16]=$($4.date)								# Date
		[17]=$($4.expect)							# Expect
		[18]=$($4.forwarded)						# Forwarded
		[19]=$($4.from)								# From
		[20]=$($4.host)								# Host
		[21]=$($4.http2_settings)					# HTTP2-Settings
		[22]=$($4.if_match)							# If-Match
		[23]=$($4.if_modified_since)				# If-Modified-Since
		[24]=$($4.if_none_match)					# If-None-Match
		[25]=$($4.if_range)							# If-Range
		[26]=$($4.if_unmodified_since)				# If-Unmodified-Since
		[27]=$($4.max_forwards)						# Max-Forwards
		[28]=$($4.origin)							# Origin
		[29]=$($4.pragma)							# Pragma
		[30]=$($4.proxy_authorization)				# Proxy-Authorization
		[31]=$($4.range)							# Range
		[32]=$($4.referer)							# Referer
		[33]=$($4.te)								# TE
		[34]=$($4.user_agent)						# User-Agent
		[35]=$($4.upgrade)							# Upgrade
		[36]=$($4.via)								# Via
		[37]=$($4.warning)							# Warning
	)

	while IFS=$'\n' read -r __resp__; do
		# Lê os headers de resposta e mapeia as chaves
		# com a nomenclatura de cada header processado
		# atribuindo os respectivos valores.
		if [ "${__resp__:0:1}" == '<' ]; then
			IFS=' ' read -r _ __header__ __value__ <<< "$__resp__"
			# Se estiver vazio lê o próximo 'header'.
			[[ ! $__value__ ]] && continue
			__header__=${__header__%:}
			__header__=${__header__,,}
			case $__header__ in
				http/1.@(0|1))	__ref__[proto]=$__header__
								__ref__[status]=${__value__%% *};;
				*)				__ref__[$__header__]=$__value__;;
			esac
		fi
	done < <(curl 	-qsvX $1 "$2" -d "$3"														\
					${__headers__[1]:+-H "A-IM: ${__headers__[1]}"}								\
					${__headers__[2]:+-H "Accept: ${__headers__[2]}"}							\
					${__headers__[3]:+-H "Accept-Charset: ${__headers__[3]}"}					\
					${__headers__[4]:+-H "Accept-Encoding: ${__headers__[4]}"}					\
					${__headers__[5]:+-H "Accept-Language: ${__headers__[5]}"}					\
					${__headers__[6]:+-H "Accept-Datetime: ${__headers__[6]}"}					\
					${__headers__[7]:+-H "Access-Control-Request-Method: ${__headers__[7]}"}	\
					${__headers__[8]:+-H "Access-Control-Request-Headers: ${__headers__[8]}"}	\
					${__headers__[9]:+-H "Authorization: ${__headers__[9]}"}					\
					${__headers__[10]:+-H "Cache-Control: ${__headers__[10]}"}					\
					${__headers__[11]:+-H "Connection: ${__headers__[11]}"}						\
					${__headers__[12]:+-H "Content-Length: ${__headers__[12]}"}					\
					${__headers__[13]:+-H "Content-MD5: ${__headers__[13]}"}					\
					${__headers__[14]:+-H "Content-Type: ${__headers__[14]}"}					\
					${__headers__[15]:+-H "Cookie: ${__headers__[15]}"}							\
					${__headers__[16]:+-H "Date: ${__headers__[16]}"}							\
					${__headers__[17]:+-H "Expect: ${__headers__[17]}"}							\
					${__headers__[18]:+-H "Forwarded: ${__headers__[18]}"}						\
					${__headers__[19]:+-H "From: ${__headers__[19]}"}							\
					${__headers__[20]:+-H "Host: ${__headers__[20]}"}							\
					${__headers__[21]:+-H "HTTP2-Settings: ${__headers__[21]}"}					\
					${__headers__[22]:+-H "If-Match: ${__headers__[22]}"}						\
					${__headers__[23]:+-H "If-Modified-Since: ${__headers__[23]}"}				\
					${__headers__[24]:+-H "If-None-Match: ${__headers__[24]}"}					\
					${__headers__[25]:+-H "If-Range: ${__headers__[25]}"}						\
					${__headers__[26]:+-H "If-Unmodified-Since: ${__headers__[26]}"}			\
					${__headers__[27]:+-H "Max-Forwards: ${__headers__[27]}"}					\
					${__headers__[28]:+-H "Origin: ${__headers__[28]}"}							\
					${__headers__[29]:+-H "Pragma: ${__headers__[29]}"}							\
					${__headers__[30]:+-H "Proxy-Authorization: ${__headers__[30]}"}			\
					${__headers__[31]:+-H "Range: ${__headers__[31]}"}							\
					${__headers__[32]:+-H "Referer: ${__headers__[32]}"}						\
					${__headers__[33]:+-H "TE: ${__headers__[33]}"}								\
					${__headers__[34]:+-H "User-Agent: ${__headers__[34]}"}						\
					${__headers__[35]:+-H "Upgrade: ${__headers__[35]}"}						\
					${__headers__[36]:+-H "Via: ${__headers__[36]}"}							\
					${__headers__[37]:+-H "Warning: ${__headers__[37]}"}						\
					--output $__bodyfile__														2>&1
	)

	# Conteúdo
	__ref__[body]=$(< $__bodyfile__)

	return $?
}

# .FUNCTION http.connection() <conn[http_request_t]> <method[str]> <url[str]> <fields[map]> <headers[http_header_st]> <response[map]> -> [bool]
#
# Define as configurações de conexão para o objeto apontado por 'conn'.
#
function http.connection()
{
	getopt.parse 6 "conn:http_request_t:$1" "method:str:$2" "url:str:$3" "fields:map:$4" "headers:http_header_st:$5" "response:map:$6" "${@:7}"
	
	printf -v $1 '%s|%s|%s|%s|%s' "$2" "$3" "$4" "$5" "$6"
	return $?
}

# .FUNCTION http.conn_request <conn[http_request_t]> -> [bool]
#
# Executa a conexão de requisição do objeto.
#
function http.conn_request()
{
	getopt.parse 1 "conn:http_request_t:$1" "${@:2}"

	local __opts__

	IFS='|' read -a __opts__ <<< "${!1}"	
	http.request "${__opts__[@]}"

	return $?
}

# .FUNCTION http.connection_data <conn[http_requests_t]> <method[str]> <url[str]> <data[str]> <headers[http_header_st]> <response[map]> -> [bool]
#
# Como 'http.connection', porém para estrutura de dados.
#
function http.connection_data()
{
	getopt.parse 6 "conn:http_requests_t:$1" "method:str:$2" "url:str:$3" "data:str:$4" "headers:http_header_st:$5" "response:map:$6" "${@:7}"
	
	printf -v $1 '%s|%s|%s|%s|%s' "$2" "$3" "$5" "$6" "$4"
	return $?
}

# .FUNCTION http.conn_request_data <conn[http_requests_t]> -> [bool]
#
# Executa a conexão de requisição do objeto.
#
function http.conn_request_data()
{
	getopt.parse 1 "conn:http_requests_t:$1" "${@:2}"

	local __opts__

	IFS='|' read -ra __opts__ <<< "${!1}"

	http.request_data	"${__opts__[0]}"	\
						"${__opts__[1]}"	\
						"${__opts__[4]}"	\
						"${__opts__[2]}"	\
						"${__opts__[3]}"
					
	return $?
}

# .FUNCTION http.conn_data <conn[http_requests_t]> <data[str]> -> [bool]
#
# Define a estrutura de dados do objeto.
#
function http.conn_data()
{
	getopt.parse 2 "conn:http_requests_t:$1" "data:str:$2" "${@:3}"

	local __opts__
	
	IFS='|' read -ra __opts__ <<< "${!1}"
	printf -v $1 '%s|%s|%s|%s|%s' "${__opts__[@]:0:4}" "$2"

	return $?
}

# Estruturas
var http_header_st struct_t

# .STRUCT http_header_st
#
# Implementa o objeto 'S' com os membros:
#
# S.aim                               [str]
# S.accept                            [str]
# S.accept_charset                    [str]
# S.accept_encoding                   [str]
# S.accept_language                   [str]
# S.accept_datetime                   [str]
# S.accept_control_request_method     [str]
# S.accept_control_request_headers    [str]
# S.authorization                     [str]
# S.cache_control                     [str]
# S.connection                        [str]
# S.content_length                    [uint]
# S.content_md5                       [str]
# S.content_type                      [str]
# S.cookie                            [str]
# S.date                              [str]
# S.expect                            [str]
# S.forwarded                         [str]
# S.from                              [str]
# S.host                              [str]
# S.http2_settings                    [str]
# S.if_match                          [str]
# S.if_modified_since                 [str]
# S.if_none_match                     [str]
# S.if_range                          [str]
# S.if_unmodified_since               [str]
# S.max_forwards                      [uint]
# S.origin                            [str]
# S.pragma                            [str]
# S.proxy_authorization               [str]
# S.range                             [str]
# S.referer                           [str]
# S.te                                [str]
# S.user_agent                        [str]
# S.upgrade                           [str]
# S.via                               [str]
# S.warning                           [str]
#
http_header_st.__add__		aim									str		\
							accept								str		\
							accept_charset						str		\
							accept_encoding						str		\
							accept_language						str		\
							accept_datetime						str		\
							accept_control_request_method		str		\
							accept_control_request_headers		str		\
							authorization						str		\
							cache_control						str		\
							connection							str		\
							content_length						uint	\
							content_md5							str		\
							content_type						str		\
							cookie								str		\
							date								str		\
							expect								str		\
							forwarded							str		\
							from								str		\
							host								str		\
							http2_settings						str		\
							if_match							str		\
							if_modified_since					str		\
							if_none_match						str		\
							if_range							str		\
							if_unmodified_since					str		\
							max_forwards						uint	\
							origin								str		\
							pragma								str		\
							proxy_authorization					str		\
							range								str		\
							referer								str		\
							te									str		\
							user_agent							str		\
							upgrade								str		\
							via									str		\
							warning								str

# .MAP response
#
# Chaves:
#
# access-control-allow-origin
# access-control-allow-credentials
# access-control-expose-headers
# access-control-max-age
# access-control-allow-methods
# access-control-allow-headers 
# accept-patch
# accept-ranges
# age
# allow
# alt-svc
# cache-control
# connection
# content-disposition
# content-encoding
# content-language
# content-length
# content-location
# content-md5
# content-range
# content-type
# date
# delta-base
# etag
# expires
# im
# last-modified
# link
# location
# p3p
# pragma
# proxy-authenticate
# public-key-pins
# retry-after
# server
# set-cookie
# strict-transport-security
# trailer
# transfer-encoding
# tk 
# upgrade
# vary
# via
# warning
# www-authenticate
# x-frame-options
# proto
# status
# body
#

# .TYPE http_request_t
#
# Implementa o objeto 'S' com o método:
#
# S.conn_request
#
typedef http_request_t	http.conn_request

# .TYPE http_requests_t
#
# Implementa o objeto 'S' com o métodos:
#
# S.conn_request_data
# S.conn_data
#
typedef http_requests_t http.conn_request_data	\
						http.conn_data

# Funções (somente-leitura)
readonly -f http.get				\
			http.request			\
			http.request_data		\
			http.connection			\
			http.conn_request		\
			http.connection_data	\
			http.conn_request_data	\
			http.conn_data

# /* __HTTP_SH__ */	
