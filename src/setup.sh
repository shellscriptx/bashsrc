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

[ -v __SETUP_SH__ ] && return 0

readonly __SETUP_SH__=1

source builtin.sh

# .FUNCTION setup.package <expr[str]> ... [bool]
#
# Verifica dependências e critérios de versionamento de pacotes e binários
# em um arquivo fonte. Retorna 'true' de todos os critérios forem satisfeitos,
# caso contrário retorna 'false' e finaliza o script com status '1'.
# 
# A expressão deve respeitar a seguinte sintaxe:
#
# 'package (operator version, ...)'
#
# ---
# package  - Nome interno do pacote.
# operator - Operador de comparação. São suportados: (>, <, >=, <=, !=, =).
# version  - Inteiros sem sinal delimitados por '.'
# ---
# > Pode ser especiifcado mais de um pacote.
# > Pode ser especificada mais de uma operação de versionamento e deve 
#   ser delimitada por uma ',' vírgula.
#
# == EXEMPLO ==
#
# source setup.sh
#
# # No pacote 'curl' as versões entre '4.0' (inclusive) e '7.5' são compatíveis. (exceto: 4.3)
# setup.package 'curl (>= 4.0, < 7.5, != 4.3)' \
#           '	jq (>= 1.5)'
#
function setup.package()
{
    getopt.parse -1 "package:str:$1" ... "${@:2}"

    local pkg cond op ver iver ret pkgname expr pkgtool reg_syn reg_ver

    # Sintaxe de versionamento.
    reg_syn='^([a-zA-Z0-9_-]+)\s+\((\s*(>|<|>=|<=|!=|==)\s*[0-9]+(.[0-9]+)*\s*(,\s*(>|<|>=|<=|!=|==)\s*[0-9]+(.[0-9]+)*\s*)*)\)$'
    reg_ver='[0-9]+(.[0-9]+)+'

    # Obtem o gerenciador de pacotes.
    for pkgtool in apt-get dnf yum pacman zypper slackpkg :; do
        which $pkgtool && break
    done 1>/dev/null

    # Trata as versões dos pacotes.
    for pkg in "$@"; do
        [[ $pkg =~ $reg_syn ]] || error.fatalf "'$pkg' erro de sintaxe\nSource: ${BASH_SOURCE[-2]}\n"
        pkgname=${BASH_REMATCH[1]}  # Nome do pacote.
        expr=${BASH_REMATCH[2]}     # Condicional de versionamento.
	
		type -f $pkgname &>/dev/null || error.fatal "'$pkgname' o pacote ou binário requerido está ausente"
        
		# Obtêm versionamento via gerenciador de pacotes.
        case $pkgtool in
            apt-get) iver=$(dpkg-query -W -f '${Version}' $pkgname);;
            pacman)  iver=$(pacman -Qi $pkgname | awk -F: '/^Version/ {print $2}');;
            slackpkg) iver=$(slackpkg info $pkgname | awk -F: '/^PACKAGE NAME/ {print $2}');;
            dnf|yum|zypper) iver=$($pkgtool info $pkgname | awk -F: '/^Version/ {print $2}');;
		esac 2>/dev/null
	
		# Força obter a versão via linha de comando para binários compilados.
		iver=${iver:-$($pkgname --version)}

        [[ $iver =~ $reg_ver ]] || error.fatal "'$pkgname' não foi possível obter a versão do pacote ou binário"
        iver=$BASH_REMATCH  # Versão do pacote instalado.

        # Lê a expressão condicional referente e obtém os
        # operadores de comparação e versionamento.
        while IFS=$'\n' read cond; do
            IFS=' ' read op ver <<< "$cond"
            # Testa o versionamento.
            awk "BEGIN { exit $iver $op $ver }"
            ret+=($?)   # Anexa status de retorno.
        done <<< "${expr//,/$'\n'}"

        ret=${ret[@]}
        ((${ret// /&})) || error.fatalf "'$pkgname' a versão instalada é incompatível.\nSource: ${BASH_SOURCE[-2]}\nRequer: ${pkg//+( )/ }\n"
    done

    return $?
}

# /* __SETUP_SH__ */
