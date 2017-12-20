#!/bin/bash

#----------------------------------------------#
# Source:           getopt.sh
# Data:             12 de novembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]
# E-mail:           shellscriptx@gmail.com
#----------------------------------------------#

[[ $__GETOPT_SH ]] && return 0

readonly __GETOPT_SH=1

source builtin.sh

readonly __GETOPT_ERR_PARAM_NAME='nome do parâmetro inválido'
readonly __GETOPT_ERR_TYPE_ARG='o argumento esperado é do tipo'
readonly __GETOPT_ERR_TYPE_PARAM='o tipo do parâmetro não é suportado'
readonly __GETOPT_ERR_ARG_REQUIRED='o argumento é requerido'
readonly __GETOPT_ERR_FLAG='flag não suportada'
readonly __GETOPT_ERR_NAME_CONFLICT='conflito de nomes de parâmetros'
readonly __GETOPT_ERR_NOT_ARG='função não requer argumento'
readonly __GETOPT_ERR_VARNAME='nome da variável inválida'
readonly __GETOPT_ERR_DIR_NOT_FOUND='diretório não encontrado'
readonly __GETOPT_ERR_FILE_NOT_FOUND='arquivo não encontrado'
readonly __GETOPT_ERR_PATH_NOT_FOUND='arquivo ou diretório não encontrado'
readonly __GETOPT_ERR_FD_NOT_EXISTS='o descritor do arquivo não existe'
readonly __GETOPT_ERR_VAR_TYPE='tipo da variável inválida'

# func getopt.parse <[str]name:type:flag:value> ... -> [bool]
#
# Trata uma lista de parâmetros em 'str ...' verificando as configurações
# especificadas para cada argumento posicional. Retorna true se todos os
# argumentos satisfazem os critérios determinados, caso contrário retorna
# false e finaliza a execução do script.
#    
# 'name:type:flag:value'
#
# name -> nomenclatura do parâmetro. Caracteres suportados. [a-zA-Z0-9_-]
#
# type -> tipo de dado aceito pelo parâmetro. São eles:
#
# uint, zone, zone, char, str, bool, array, map, null, func, funcname,
# bin, hex, oct, size, 12h, 24h, date, hour, sec, mday, mon, year, yday, wday, 
# url, smtp, email, ipv4, ipv6, mac, slic e keyword
#
# flag -> Atributo que determina o comportamento do parâmetro. Utilize o 
# caractere '-' (hifen) para especificar que o argumento é opcional
# ou '+' para obrigatório.
#            
# value -> Valor a ser verificado pela função com base no tipo definido.
#
# Exemplo:
#
# #!/bin/bash
# # script: soma.sh
#
# source getopt.sh
#
# soma()
# {
#     # verifica os valores passados na função
#     getopt.parse "x:int:+:$1" "y:int:+:$2"
#
#     echo $(($1+$2))
# }
#
# soma 10 20
# soma 10 af
# # FIM
#
# $ ./soma.sh
# 30
# ./teste.sh: erro: linha 14: soma: y: 'af' o argumento esperado é do tipo int
#
function getopt.parse()
{
	local name ctype flag value ref flags names attr obj_types i args param
	
	error.__clear

	for param in "$@"
	do
		for i in {0..2}; do
			args[$i]=${param%%:*}
			param=${param#*:}
		done
		
		args[$i+1]=$param
		
		name=${args[0]}
		ctype=${args[1]}
		flag=${args[2]}
		value=${args[3]}
			
		[[ $name =~ ^(${names%|})$ ]] && error.__exit "$name" '' "$value" "$__GETOPT_ERR_NAME_CONFLICT"
		[[ $name =~ ^[a-zA-Z0-9_-]+$ ]] || error.__exit "$name" '' "$value" "$__GETOPT_ERR_PARAM_NAME"

		case $flag in
			+)	[[ $value ]] || error.__exit "$name" "$ctype" '<null>' "$__GETOPT_ERR_ARG_REQUIRED";;
			-)	[[ $value ]] || continue;;
			*)	error.__exit "$name" '' "${flag:-<null>}" "$__GETOPT_ERR_FLAG";;
		esac

		case $ctype in
			# tipo
           	uint) [[ $value =~ ^(0|[1-9][0-9]*)$ ]];;
			int|zone) [[ $value =~ ^(0|-?[1-9][0-9]*)$ ]];;
   	        char) [[ $value =~ ^.$ ]];;
			str) [[ $value =~ ^.+$ ]];;
			bool) [[ $value =~ ^(true|false)$ ]];;
			# variavel
			var|array) [[ $value =~ ^(_+[a-zA-Z0-9]|[a-zA-Z])[a-zA-Z0-9_]*$ ]];;
			map)
				[[ $value =~ ^(_+[a-zA-Z0-9]|[a-zA-Z])[a-zA-Z0-9_]*$ ]] && {
					read _ attr _ < <(declare -p $value 2>/dev/null)
        			[[ $value ]] || [[ $attr =~ A ]]
				};;
           	func) declare -fp "$value" &>/dev/null;;
			funcname) [[ $value =~ ^[a-zA-Z0-9_.-]+$ ]];;
			# base
   	        bin) [[ $value =~ ^[01]+$ ]];;
   	        hex) [[ $value =~ ^(0x)?[0-9a-fA-F]+$ ]];;
   	        oct) [[ $value =~ ^[0-7]+$ ]];;
			size) [[ $value =~ ^[0-9]+[kKmMgGtTpPeEzZyY]$ ]];;
			# data/time
			12h) [[ $value =~ ^(0[1-9]|1[0-2]):[0-5][0-9]$ ]];;
			24h) [[ $value =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]];;
			date) [[ $value =~ ^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4})$ ]];;
			hour) [[ $value =~ ^([01][0-9]|2[0-3])$ ]];;
			min|sec) [[ $value =~ ^[0-5][0-9]$ ]];;
			mday) [[ $value =~ ^(0[1-9]|[12][0-9]|3[01])$ ]];;
			mon) [[ $value =~ ^(0[1-9]|1[0-2])$ ]];;
			year) [[ $value =~ ^[0-9]{4,}$ ]];;
			yday) [[ $value =~ ^([1-9][0-9]{,1}|[1-2][0-9]{1,2}|3([0-5][0-9]|6[0-6]))$ ]];;
			wday) [[ $value =~ ^[0-6]$ ]];;	
			# web
			url) [[ $value =~ ^(https?|ftp|smtp)://(www\.)?[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+/?$ ]];;
			email) [[ $value =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]];;
			# rede
			ipv4) [[ $value =~ ^(([0-9]|[1-9][0-9]|1[0-9]{,2}|2[0-4][0-9]|
								25[0-5])[.]){3}([0-9]|[1-9][0-9]|
								1[0-9]{,2}|2[0-4][0-9]|25[0-5])$ ]];;
			ipv6) [[ $value =~ ^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|
								([0-9a-fA-F]{1,4}:){1,7}:|
								([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|
								([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|
								([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|
								([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|
								([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|
								[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|
								:((:[0-9a-fA-F]{1,4}){1,7}|:)|
								fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|
								::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|
								1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|
								(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|
								([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|
								(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$ ]];;

			mac) [[ $value =~ ^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$ ]];;
			slice) [[ ${value// /} =~ \[[^]][0-9]*:?(-[0-9]+|[0-9]*)\] ]];;
			keyword) [[ $value == $name ]];;
			null) error.__exit "$name" "$ctype" "$value" "$__GETOPT_ERR_NOT_ARG";;
			dir) [[ -d $value ]] || error.__exit "$name" "$ctype" "$value" "$__GETOPT_ERR_DIR_NOT_FOUND";;
			file) [[ -f $value ]] || error.__exit "$name" "$ctype" "$value" "$__GETOPT_ERR_FILE_NOT_FOUND";;
			path) [[ -e $value ]] || error.__exit "$name" "$ctype" "$value" "$__GETOPT_ERR_PATH_NOT_FOUND";;
			fd) ([[ $value =~ ^(0|[1-9][0-9]*)$ ]]; [[ -e /dev/fd/$value ]]) || \
				error.__exit "$name" "$ctype" "$value" "$__GETOPT_ERR_FD_NOT_EXISTS";;
			type) obj_types="${!__BUILTIN_TYPE_IMPLEMENTS[@]}${__INIT_TYPE_IMPLEMENTS[@]:+ ${!__INIT_TYPE_IMPLEMENTS[@]}}"
				  [[ "$value" =~ ^(${obj_types// /|})$ ]] || error.__exit "$name" "$ctype" "$value" "$__GETOPT_ERR_VAR_TYPE";;

			*) error.__exit "$name" "$ctype" '' "$__GETOPT_ERR_TYPE_PARAM '$ctype'";;
       	esac

		(($?)) && error.__exit "$name" "$ctype" "$value" "$__GETOPT_ERR_TYPE_ARG $ctype"

		names+="$name|"
	done

	return 0
}

readonly -f getopt.parse
# /* __GETOPT_SRC */
