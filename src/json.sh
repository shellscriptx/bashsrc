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

[ -v __JSON_SH__ ] && return 0

readonly __JSON_SH__=1

source builtin.sh
source setup.sh

# Dependência.
setup.package 'jq (>= 1.5)'

# .FUNCTION json.load <file[str]> <obj[map]> -> [bool]
#
# Converte o arquivo contendo um documento JSON em uma estrutura 
# de dados mapeada e salva no objeto apontado por 'obj'.
#
function json.load()
{
	getopt.parse 2 "file:str:$1" "obj:map:$2" "${@:3}"

	if [ ! -f "$1" ]; then
		error.error "'$1' não é um arquivo regular"
		return $?
	elif [ ! -r "$1" ]; then
		error.error "'$1' não foi possível ler o arquivo"
		return $?
	fi

	json.__setmap__ file "$1" $2

	return $?
}

# .FUNCTION json.loads <expr[str]> <obj[map]> -> [bool]
#
# Converte a expressão JSON em uma estrutura de dados mapeada
# e salva no objeto apontado por 'obj'.
#
# == EXEMPLO ==
#
# #!/bin/bash
#
# source json.sh
# source map.sh
#
# # Inicializa o map.
# declare -A dados=()
#
# # Implementa o tipo map.
# var dados map_t
#
# # Processando/convertendo JSON
# json.loads '{"autor":{"nome":"Juliano","sobrenome":"santos","idade":35,"pseudonimo":"SHAMAN"}}' dados
#
# Listando as chaves do mapa.
# dados.keys
#
# echo ---
#
# # Acessando valores.
# dados.get autor.nome
# dados.get autor.pseudonimo
# dados.get autor.idade
#
# == SAÍDA ==
#
# autor.nome
# autor.pseudonimo
# autor.sobrenome
# autor.idade
# ---
# Juliano
# SHAMAN
# 35
#
function json.loads()
{
	getopt.parse 2 "expr:str:$1" "obj:map:$2" "${@:3}"
	json.__setmap__ expr "$1" $2
	return $?
}

# json.__setmap____ <tipo> <json> <map>
#
# A função interna processa e converte os dados de um arquivo ou
# expressão JSON para um array associativo especificado (map).
#
function json.__setmap__()
{
	local __cjson__ __key__ __val__
	local -n __ref__=$3

	# Converte os objetos json em uma lista mapeada de dados.
	__cjson__='path(..|
			   select(type == "string" or type == "number" or type == "boolean"))|
		       map(if type == "number" then .|tostring|"["+.+"]" else . end)|
		      join(".")'

	# Lê a chave atual.
	while IFS=$'\n' read __key__; do
		__key__=${__key__//.\[/\[}
		# Lê os dados.
		case $1 in
			expr) __val__=$(jq ".$__key__" <<< "$2");;
			file) __val__=$(jq ".$__key__" "$2");;
		esac 2>/dev/null
		__val__=${__val__#\"}
		__val__=${__val__%\"}
		# Salva no objeto os dados da respectiva chave.
		__ref__[$__key__]=$__val__
	done < <(
		# Processa a linha de comando para o tipo especificado.
		case $1 in
			expr) jq -r "$__cjson__" <<< "$2";;
			file) jq -r "$__cjson__" "$2";;
		esac 2>/dev/null
	)
	
	# Se o objeto não contém elementos processados.
	[ ${#__ref__[@]} -eq 0 ] && error.error 'erro ao processar os dados json'

	return $?
}

# Tipos/Implementações
typedef json_t json.loads

# .TYPE json_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.loads
#

# Funções (somente-leitura)
readonly -f	json.load		\
			json.loads		\
			json.__setmap__

# /* __JSON_SH__ */
