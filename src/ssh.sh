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

[ -v __SSH_SH__ ] && return 0

readonly __SSH_SH__=1

source builtin.sh
source struct.sh

# .FUNCTION ssh.new <session[ssh_t]> <config[ssh_config_st]> -> [bool]
#
# Cria uma nova sessão com as configurações especificadas na estrutura e salva
# no objeto apontado por 'session'.
#
function ssh.new()
{
	getopt.parse 2 "session:ssh_t:$1" "config:ssh_config_st:$2" "${@:3}"

	local	__user__=$($2.user)																		\
			__pass__=$($2.pass) 																	\
			__host__=$($2.host) 																	\
			__port__=$($2.port) 																	\
			__forward_auth__=$($2.forward_auth) 													\
			__bind_address__=$($2.bind_address) 													\
			__log_file__=$($2.log_file) 															\
			__config_file__=$($2.config_file) 														\
			__add_keys_to_agent__=$($2.add_keys_to_agent) 											\
			__address_family__=$($2.address_family) 												\
			__batch_mode__=$($2.batch_mode) 														\
			__canonical_domains__=$($2.canonical_domains) 											\
			__canonicalize_fallback_local__=$($2.canonicalize_fallback_local) 						\
			__canonicalize_hostname__=$($2.canonicalize_hostname) 									\
			__canonicalize_max_dots__=$($2.canonicalize_max_dots) 									\
			__canonicalize_permitted_cnames__=$($2.canonicalize_permitted_cnames) 					\
			__cetificate_file__=$($2.cetificate_file) 												\
			__challenge_response_authentication__=$($2.challenge_response_authentication) 			\
			__check_host_ip__=$($2.check_host_ip) 													\
			__ciphers__=$($2.ciphers) 																\
			__clear_all_forwardings__=$($2.clear_all_forwardings) 									\
			__escape_char__=$($2.escape_char) 														\
			__compression__=$($2.compression) 														\
			__compression_level__=$($2.compression_level) 											\
			__connection_attempts__=$($2.connection_attempts) 										\
			__connect_timeout__=$($2.connect_timeout) 												\
			__control_master__=$($2.control_master) 												\
			__control_path__=$($2.control_path) 													\
			__control_persist__=$($2.control_persist) 												\
			__dynamic_forward__=$($2.dynamic_forward) 												\
			__enable_ssh_keysing__=$($2.enable_ssh_keysing) 										\
			__exit_on_forward_failure__=$($2.exit_on_forward_failure) 								\
			__finger_print_hash__=$($2.finger_print_hash) 											\
			__forward_agent__=$($2.forward_agent) 													\
			__forward_x11__=$($2.forward_x11) 														\
			__forward_x11_timeout__=$($2.forward_x11_timeout) 										\
			__forward_x11_trusted__=$($2.forward_x11_trusted) 										\
			__gateway_ports__=$($2.gateway_ports) 													\
			__global_known_hosts_file__=$($2.global_known_hosts_file) 								\
			__gssapi_authentication__=$($2.gssapi_authentication) 									\
			__gssapi_key_exchange__=$($2.gssapi_key_exchange) 										\
			__gssapi_client_identity__=$($2.gssapi_client_identity) 								\
			__gssapi_server_identity__=$($2.gssapi_server_identity) 								\
			__gssapi_delegate_credentials__=$($2.gssapi_delegate_credentials) 						\
			__gssapi_renewal_forces_rekey__=$($2.gssapi_renewal_forces_rekey) 						\
			__gssapi_trust_dns__=$($2.gssapi_trust_dns) 											\
			__hash_known_hosts__=$($2.hash_known_hosts) 											\
			__host_based_authentication__=$($2.host_based_authentication) 							\
			__host_based_key_types__=$($2.host_based_key_types) 									\
			__host_key_algorithms__=$($2.host_key_algorithms) 										\
			__host_key_alias__=$($2.host_key_alias) 												\
			__hostname__=$($2.hostname) 															\
			__identities_only__=$($2.identities_only) 												\
			__identity_agent__=$($2.identity_agent) 												\
			__identity_file__=$($2.identity_file) 													\
			__ignore_unknown__=$($2.ignore_unknown) 												\
			__include__=$($2.include) 																\
			__ip_qos__=$($2.ip_qos) 																\
			__kbd_interactive_authentication__=$($2.kbd_interactive_authentication) 				\
			__kbd_interactive_devices__=$($2.kbd_interactive_devices) 								\
			__kex_algorithms__=$($2.kex_algorithms) 												\
			__local_command__=$($2.local_command) 													\
			__local_forward__=$($2.local_forward) 													\
			__log_level__=$($2.log_level) 															\
			__macs__=$($2.macs) 																	\
			__no_host_authentication_for_local_host__=$($2.no_host_authentication_for_local_host) 	\
			__number_of_password_prompts__=$($2.number_of_password_prompts) 						\
			__password_authentication__=$($2.password_authentication) 								\
			__permit_local_command__=$($2.permit_local_command) 									\
			__pkcs11_provider__=$($2.pkcs11_provider) 												\
			__preferred_authentications__=$($2.preferred_authentications) 							\
			__proxy_command__=$($2.proxy_command) 													\
			__proxy_jump__=$($2.proxy_jump) 														\
			__proxy_use_fdpass__=$($2.proxy_use_fdpass) 											\
			__pubkey_accepted_key_types__=$($2.pubkey_accepted_key_types) 							\
			__pubkey_authentication__=$($2.pubkey_authentication) 									\
			__rekey_limit__=$($2.rekey_limit) 														\
			__remote_forward__=$($2.remote_forward) 												\
			__remote_command__=$($2.remote_command) 												\
			__request_tty__=$($2.request_tty) 														\
			__revoked_host_keys__=$($2.revoked_host_keys) 											\
			__send_env__=$($2.send_env) 															\
			__server_alive_count_max__=$($2.server_alive_count_max) 								\
			__server_alive_interval__=$($2.server_alive_interval) 									\
			__stream_local_bind_mask__=$($2.stream_local_bind_mask) 								\
			__stream_local_bind_unlink__=$($2.stream_local_bind_unlink) 							\
			__strict_host_key_checking__=$($2.strict_host_key_checking) 							\
			__tcp_keep_alive__=$($2.tcp_keep_alive) 												\
			__tunnel__=$($2.tunnel) 																\
			__tunnel_device__=$($2.tunnel_device) 													\
			__update_host_keys__=$($2.update_host_keys) 											\
			__use_privileged_port__=$($2.use_privileged_port) 										\
			__user_known_hosts_file__=$($2.user_known_hosts_file) 									\
			__verify_host_key_dns__=$($2.verify_host_key_dns) 										\
			__visual_host_key__=$($2.visual_host_key) 												\
			__xauth_location__=$($2.xauth_location)													\
			__sha__																					\
			__aes__																					\
			__ssh_opts__

	# Configurações	
	__ssh_opts__+=${__add_keys_to_agent__:+-o AddKeysToAgent=$__add_keys_to_agent__ }
	__ssh_opts__+=${__address_family__:+-o AddressFamily=$__address_family__ }
	__ssh_opts__+=${__batch_mode__:+-o BatchMode=$__batch_mode__ }
	__ssh_opts__+=${__bind_address__:+-o BindAddress=$__bind_address__ }
	__ssh_opts__+=${__canonical_domains__:+-o CanonicalDomains=$__canonical_domains__ }
	__ssh_opts__+=${__canonicalize_fallback_local__:+-o CanonicalizeFallbackLocal=$__canonicalize_fallback_local__ }
	__ssh_opts__+=${__canonicalize_hostname__:+-o CanonicalizeHostname=$__canonicalize_hostname__ }
	__ssh_opts__+=${__canonicalize_max_dots__:+-o CanonicalizeMaxDots=$__canonicalize_max_dots__ }
	__ssh_opts__+=${__canonicalize_permitted_cnames__:+-o CanonicalizePermittedCNAMEs=$__canonicalize_permitted_cnames__ }
	__ssh_opts__+=${__cetificate_file__:+-o CertificateFile=$__cetificate_file__ }
	__ssh_opts__+=${__challenge_response_authentication__:+-o ChallengeResponseAuthentication=$__challenge_response_authentication__ }
	__ssh_opts__+=${__check_host_ip__:+-o CheckHostIP=$__check_host_ip__ }
	__ssh_opts__+=${__ciphers__:+-o Ciphers=$__ciphers__ }
	__ssh_opts__+=${__clear_all_forwardings__:+-o ClearAllForwardings=$__clear_all_forwardings__ }
	__ssh_opts__+=${__compression_level__:+-o  $__compression_level__ }
	__ssh_opts__+=${__compression__:+-o Compression=$__compression__ }
	__ssh_opts__+=${__config_file__:+-F $__config_file__ }
	__ssh_opts__+=${__connection_attempts__:+-o ConnectionAttempts=$__connection_attempts__ }
	__ssh_opts__+=${__connect_timeout__:+-o ConnectTimeout=$__connect_timeout__ }
	__ssh_opts__+=${__control_master__:+-o ControlMaster=$__control_master__ }
	__ssh_opts__+=${__control_path__:+-o ControlPath=$__control_path__ }
	__ssh_opts__+=${__control_persist__:+-o ControlPersist=$__control_persist__ }
	__ssh_opts__+=${__dynamic_forward__:+-o DynamicForward=$__dynamic_forward__ }
	__ssh_opts__+=${__enable_ssh_keysing__:+-o EnableSSHKeysign=$__enable_ssh_keysing__ }
	__ssh_opts__+=${__escape_char__:+-o EscapeChar=$__escape_char__ }
	__ssh_opts__+=${__exit_on_forward_failure__:+-o ExitOnForwardFailure=$__exit_on_forward_failure__ }
	__ssh_opts__+=${__finger_print_hash__:+-o FingerprintHash=$__finger_print_hash__ }
	__ssh_opts__+=${__forward_agent__:+-o ForwardAgent=$__forward_agent__ }
	__ssh_opts__+=${__forward_auth__:+-o $__forward_auth__ }
	__ssh_opts__+=${__forward_x11__:+-o ForwardX11=$__forward_x11__ }
	__ssh_opts__+=${__forward_x11_timeout__:+-o ForwardX11Timeout=$__forward_x11_timeout__ }
	__ssh_opts__+=${__forward_x11_trusted__:+-o ForwardX11Trusted=$__forward_x11_trusted__ }
	__ssh_opts__+=${__gateway_ports__:+-o GatewayPorts=$__gateway_ports__ }
	__ssh_opts__+=${__global_known_hosts_file__:+-o GlobalKnownHostsFile=$__global_known_hosts_file__ }
	__ssh_opts__+=${__gssapi_authentication__:+-o GSSAPIAuthentication=$__gssapi_authentication__ }
	__ssh_opts__+=${__gssapi_client_identity__:+-o GSSAPIClientIdentity=$__gssapi_client_identity__ }
	__ssh_opts__+=${__gssapi_delegate_credentials__:+-o GSSAPIDelegateCredentials=$__gssapi_delegate_credentials__ }
	__ssh_opts__+=${__gssapi_key_exchange__:+-o GSSAPIKeyExchange=$__gssapi_key_exchange__ }
	__ssh_opts__+=${__gssapi_renewal_forces_rekey__:+-o GSSAPIRenewalForcesRekey=$__gssapi_renewal_forces_rekey__ }
	__ssh_opts__+=${__gssapi_server_identity__:+-o GSSAPIServerIdentity=$__gssapi_server_identity__ }
	__ssh_opts__+=${__gssapi_trust_dns__:+-o GSSAPITrustDns=$__gssapi_trust_dns__ }
	__ssh_opts__+=${__hash_known_hosts__:+-o HashKnownHosts=$__hash_known_hosts__ }
	__ssh_opts__+=${__host_based_authentication__:+-o HostbasedAuthentication=$__host_based_authentication__ }
	__ssh_opts__+=${__host_based_key_types__:+-o HostbasedKeyTypes=$__host_based_key_types__ }
	__ssh_opts__+=${__host_key_algorithms__:+-o HostKeyAlgorithms=$__host_key_algorithms__ }
	__ssh_opts__+=${__host_key_alias__:+-o HostKeyAlias=$__host_key_alias__ }
	__ssh_opts__+=${__hostname__:+-o HostName=$__hostname__ }
	__ssh_opts__+=${__identities_only__:+-o IdentitiesOnly=$__identities_only__ }
	__ssh_opts__+=${__identity_agent__:+-o IdentityAgent=$__identity_agent__ }
	__ssh_opts__+=${__identity_file__:+-o IdentityFile=$__identity_file__ }
	__ssh_opts__+=${__ignore_unknown__:+-o IgnoreUnknown=$__ignore_unknown__ }
	__ssh_opts__+=${__include__:+-o Include=$__include__ }
	__ssh_opts__+=${__ip_qos__:+-o IPQoS=$__ip_qos__ }
	__ssh_opts__+=${__kbd_interactive_authentication__:+-o KbdInteractiveAuthentication=$__kbd_interactive_authentication__ }
	__ssh_opts__+=${__kbd_interactive_devices__:+-o KbdInteractiveDevices=$__kbd_interactive_devices__ }
	__ssh_opts__+=${__kex_algorithms__:+-o KexAlgorithms=$__kex_algorithms__ }
	__ssh_opts__+=${__local_command__:+-o LocalCommand=$__local_command__ }
	__ssh_opts__+=${__local_forward__:+-o LocalForward=$__local_forward__ }
	__ssh_opts__+=${__log_file__:+-E $__log_file__ }
	__ssh_opts__+=${__log_level__:+-o LogLevel=$__log_level__ }
	__ssh_opts__+=${__macs__:+-o MACs=$__macs__ }
	__ssh_opts__+=${__no_host_authentication_for_local_host__:+-o NoHostAuthenticationForLocalhost=$__no_host_authentication_for_local_host__ }
	__ssh_opts__+=${__number_of_password_prompts__:+-o NumberOfPasswordPrompts=$__number_of_password_prompts__ }
	__ssh_opts__+=${__password_authentication__:+-o PasswordAuthentication=$__password_authentication__ }
	__ssh_opts__+=${__permit_local_command__:+-o PermitLocalCommand=$__permit_local_command__ }
	__ssh_opts__+=${__pkcs11_provider__:+-o PKCS11Provider=$__pkcs11_provider__ }
	__ssh_opts__+=${__port__:+-o Port=$__port__ }
	__ssh_opts__+=${__preferred_authentications__:+-o PreferredAuthentications=$__preferred_authentications__ }
	__ssh_opts__+=${__proxy_command__:+-o ProxyCommand=$__proxy_command__ }
	__ssh_opts__+=${__proxy_jump__:+-o ProxyJump=$__proxy_jump__ }
	__ssh_opts__+=${__proxy_use_fdpass__:+-o ProxyUseFdpass=$__proxy_use_fdpass__ }
	__ssh_opts__+=${__pubkey_accepted_key_types__:+-o PubkeyAcceptedKeyTypes=$__pubkey_accepted_key_types__ }
	__ssh_opts__+=${__pubkey_authentication__:+-o PubkeyAuthentication=$__pubkey_authentication__ }
	__ssh_opts__+=${__rekey_limit__:+-o RekeyLimit=$__rekey_limit__ }
	__ssh_opts__+=${__remote_command__:+-o RemoteCommand=$__remote_command__ }
	__ssh_opts__+=${__remote_forward__:+-o RemoteForward=$__remote_forward__ }
	__ssh_opts__+=${__request_tty__:+-o RequestTTY=$__request_tty__ }
	__ssh_opts__+=${__revoked_host_keys__:+-o RevokedHostKeys=$__revoked_host_keys__ }
	__ssh_opts__+=${__send_env__:+-o SendEnv=$__send_env__ }
	__ssh_opts__+=${__server_alive_count_max__:+-o ServerAliveCountMax=$__server_alive_count_max__ }
	__ssh_opts__+=${__server_alive_interval__:+-o ServerAliveInterval=$__server_alive_interval__ }
	__ssh_opts__+=${__stream_local_bind_mask__:+-o StreamLocalBindMask=$__stream_local_bind_mask__ }
	__ssh_opts__+=${__stream_local_bind_unlink__:+-o StreamLocalBindUnlink=$__stream_local_bind_unlink__ }
	__ssh_opts__+=${__strict_host_key_checking__:+-o StrictHostKeyChecking=$__strict_host_key_checking__ }
	__ssh_opts__+=${__tcp_keep_alive__:+-o TCPKeepAlive=$__tcp_keep_alive__ }
	__ssh_opts__+=${__tunnel_device__:+-o TunnelDevice=$__tunnel_device__ }
	__ssh_opts__+=${__tunnel__:+-o Tunnel=$__tunnel__ }
	__ssh_opts__+=${__update_host_keys__:+-o UpdateHostKeys=$__update_host_keys__ }
	__ssh_opts__+=${__use_privileged_port__:+-o UsePrivilegedPort=$__use_privileged_port__ }
	__ssh_opts__+=${__user_known_hosts_file__:+-o UserKnownHostsFile=$__user_known_hosts_file__ }
	__ssh_opts__+=${__verify_host_key_dns__:+-o VerifyHostKeyDNS=$__verify_host_key_dns__ }
	__ssh_opts__+=${__visual_host_key__:+-o VisualHostKey=$__visual_host_key__ }
	__ssh_opts__+=${__xauth_location__:+-o XAuthLocation=$__xauth_location__ }

	# Gera as chaves de decodificação da senha e salva as configurações
	# de conexão no objeto da sessão.
	IFS='|' read -r __sha__ __aes__ < <(ssh.__openssl_crypt__ "$__pass__")
	printf -v $1 '%s|%s|%s|%s|%s' "$__host__" "$__user__" "$__sha__" "$__aes__" "$__ssh_opts__"

	return $?
}

# .FUNCTION ssh.shell <session[ssh_t]> <commands[str]> -> [bool]
#
# Executa os comandos na sessão especificada.
#
# == EXEMPLO ==
#
# #!/bin/bash
#
# source ssh.sh
#
# var client ssh_t            # Sessão
# var config ssh_config_st    # Configurações
#
# # Definindo configurações de conexão e autenticação.
# config.host = '192.168.25.10'
# config.user = 'shaman'
# config.pass = 'senha123'
#
# # Criando uma nova sessão com as configurações estabelecidas.
# client.new config
#
# # Executando comandos no host remoto.
# client.shell 'lsb_release -a; echo ---; who'
#
# == SAÍDA ==
#
# Distributor ID: Ubuntu
# Description:    Ubuntu 16.04 LTS
# Release:        16.04
# Codename:       xenial
# ---
# ubuntu   tty7         2019-01-12 11:41 (:0)
# shaman   pts/4        2019-01-12 12:00 (192.168.25.3)
#
function ssh.shell()
{
    getopt.parse 2 "session:ssh_t:$1" "commands:str:$2" "${@:3}"

    local __ssh_key__ __user__ __host__ __sha__ __aes__ __ssh_opts__

    IFS='|' read -r __host__ __user__ __sha__ __aes__ __ssh_opts__ <<< ${!1}
    __ssh_key__=$(ssh.__openssl_decrypt__ "$__sha__" "$__aes__")

    export DISPLAY=:0
    export SSH_ASKPASS=$__ssh_key__

	# Remove o script de decodificação em caso de falha ou sucesso.
    trap "rm -f $__ssh_key__ &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM SIGKILL SIGTSTP RETURN

	# Inicia uma nova sessão de conexão com o host remoto.
    setsid	-w ssh -qt						\
           	-o StrictHostKeyChecking=no     \
           	-o UserKnownHostsFile=/dev/null \
           	$__ssh_opts__					\
           	$__user__@$__host__        		\
           	"$2"

	# Falha de conexão.
	if [[ $? -eq 255 ]]; then
		error.error "'$__host__' não foi possível conectar ao host"
		return 1
    fi

    return $?
}

# .FUNCTION ssh.exec <session[ssh_t]> <script[str]> -> [bool]
#
# Executa o script no host remoto.
#
function ssh.exec()
{
	getopt.parse 2 "session:ssh_t:$1" "script:str:$2" "${@:3}"

	local __host__ __user__ __sha__ __aes__ __ssh_opts__ __ssh_key__
	
	if [[ ! -f "$2" ]]; then
		error.error "'$2' não é um arquivo regular"
		return 1
	elif [[ ! -r "$2" ]]; then
		error.error "'$2' não foi possível ler o arquivo"
		return 1
	fi

	IFS='|' read -r __host__ __user__ __sha__ __aes__ __ssh_opts__ <<< ${!1}
	
	__ssh_key__=$(ssh.__openssl_decrypt__ "$__sha__" "$__aes__")

	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key__
	
	trap "rm -f $__ssh_key__ &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM SIGKILL SIGTSTP RETURN

	setsid	-w ssh -qt						\
			-o StrictHostKeyChecking=no		\
			-o UserKnownHostsFile=/dev/null	\
			$__ssh_opts__					\
			$__user__@$__host__				< "$2"

	if [[ $? -eq 255 ]]; then
		error.error "'$__host__' não foi possível conectar ao host"
		return 1
    fi

    return $?
}

# .FUNCTION ssh.upload <session[ssh_t]> <srcpath[str]> <destpath[str]> -> [bool]
#
# Envia direetório/arquivo local para o host remoto.
#
function ssh.upload()
{
	getopt.parse 3 "session:ssh_t:$1" "srcpath:str:$2" "destpath:str:$3" "${@:4}"
	
	local __host__ __user__ __sha__ __aes__ __ssh_opts__ __ssh_key__ __rec__

	if [[ ! -r "$2" ]]; then
		error.error "'$2' não foi possível ler o arquivo ou diretório"
		return 1
	fi

	IFS='|' read -r __host__ __user__ __sha__ __aes__ __ssh_opts__ <<< ${!1}
	__ssh_key__=$(ssh.__openssl_decrypt__ "$__sha__" "$__aes__")

	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key__
	
	trap "rm -f $__ssh_key &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM SIGKILL SIGTSTP RETURN
	
	setsid	-w scp -q							\
			-o StrictHostKeyChecking=no         \
			-o UserKnownHostsFile=/dev/null     \
			$__ssh_opts__						\
			-r "$2"								\
			$__user__@$__host__:"$3"
				
	return $?
}

# .FUNCTION ssh.download <session[ssh_t]> <srcpath[str]> <destpath[str]> -> [bool]
#
# Baixa o diretório/arquivo remoto para o destino especificado.
#
function ssh.download()
{
	getopt.parse 3 "session:ssh_t:$1" "srcpath:str:$2" "destpath:str:$3" "${@:4}"
	
	local __host__ __user__ __sha__ __aes__ __ssh_opts__ __ssh_key__

	IFS='|' read -r __host__ __user__ __sha__ __aes__ __ssh_opts__ <<< ${!1}
	__ssh_key__=$(ssh.__openssl_decrypt__ "$__sha__" "$__aes__")

	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key__
	
	trap "rm -f $__ssh_key &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM SIGKILL SIGTSTP RETURN
	
	setsid	-w scp -q							\
			-o StrictHostKeyChecking=no         \
			-o UserKnownHostsFile=/dev/null     \
			$__ssh_opts__						\
			-r $__user__@$__host__:"$2"			\
			"$3"
				
	return $?
}

# .FUNCTION ssh.close <session[ssh_t]> -> [bool]
#
# Finaliza a sessão.
#
function ssh.close()
{
	getopt.parse 1 "session:ssh_t:$1" "${@:2}"
	del $1
	return $?
}

function ssh.__openssl_crypt__()
{
	local sha aes seed

	printf -v seed '%(%s)T'
	IFS=' ' read sha _ < <(sha256sum <<< "$((RANDOM * (BASHPID ^ seed)))")
	aes=$(openssl enc -e -aes-256-cbc -a -k "$sha" <<< $1)
	printf '%s|%s\n' "$sha" "$aes"

    return $?
}

function ssh.__openssl_decrypt__()
{
	local ssh_key

	# Gera o script de decodificação da chave ssh.
	ssh_key=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.key)
	cat > $ssh_key << _eof
#!/bin/bash
openssl enc -d -aes-256-cbc -k "$1" < <(openssl base64 -d <<< "$2")
_eof

	chmod u+x $ssh_key
	echo "$ssh_key"		# Retorna o script.

	return $?
}

# Estrutura
var ssh_config_st struct_t

# .STRUCT ssh_config_st
#
# Implementa o objeto 'S" com os membros:
#
# S.user                                     [str]
# S.pass                                     [str]
# S.host                                     [str]
# S.port                                     [uint]
# S.forward_auth                             [bool]
# S.bind_address                             [str]
# S.log_file                                 [str]
# S.config_file                              [str]
# S.add_keys_to_agent                        [str]
# S.address_family                           [str]
# S.batch_mode                               [str]
# S.canonical_domains                        [str]
# S.canonicalize_fallback_local              [str]
# S.canonicalize_hostname                    [str]
# S.canonicalize_max_dots                    [uint]
# S.canonicalize_permitted_cnames            [str]
# S.cetificate_file                          [str]
# S.challenge_response_authentication        [str]
# S.check_host_ip                            [str]
# S.ciphers                                  [str]
# S.clear_all_forwardings                    [str]
# S.escape_char                              [str]
# S.compression                              [str]
# S.compression_level                        [uint]
# S.connection_attempts                      [uint]
# S.connect_timeout                          [uint]
# S.control_master                           [str]
# S.control_path                             [str]
# S.control_persist                          [str]
# S.dynamic_forward                          [str]
# S.enable_ssh_keysing                       [str]
# S.exit_on_forward_failure                  [str]
# S.finger_print_hash                        [str]
# S.forward_agent                            [str]
# S.forward_x11                              [str]
# S.forward_x11_timeout                      [uint]
# S.forward_x11_trusted                      [str]
# S.gateway_ports                            [str]
# S.global_known_hosts_file                  [str]
# S.gssapi_authentication                    [str]
# S.gssapi_key_exchange                      [str]
# S.gssapi_client_identity                   [str]
# S.gssapi_server_identity                   [str]
# S.gssapi_delegate_credentials              [str]
# S.gssapi_renewal_forces_rekey              [str]
# S.gssapi_trust_dns                         [str]
# S.hash_known_hosts                         [str]
# S.host_based_authentication                [str]
# S.host_based_key_types                     [str]
# S.host_key_algorithms                      [str]
# S.host_key_alias                           [str]
# S.hostname                                 [str]
# S.identities_only                          [str]
# S.identity_agent                           [str]
# S.identity_file                            [str]
# S.ignore_unknown                           [str]
# S.include                                  [str]
# S.ip_qos                                   [str]
# S.kbd_interactive_authentication           [str]
# S.kbd_interactive_devices                  [str]
# S.kex_algorithms                           [str]
# S.local_command                            [str]
# S.local_forward                            [str]
# S.log_level                                [str]
# S.macs                                     [str]
# S.no_host_authentication_for_local_host    [str]
# S.number_of_password_prompts               [uint]
# S.password_authentication                  [str]
# S.permit_local_command                     [str]
# S.pkcs11_provider                          [str]
# S.preferred_authentications                [str]
# S.proxy_command                            [str]
# S.proxy_jump                               [str]
# S.proxy_use_fdpass                         [str]
# S.pubkey_accepted_key_types                [str]
# S.pubkey_authentication                    [str]
# S.rekey_limit                              [str]
# S.remote_forward                           [str]
# S.remote_command                           [str]
# S.request_tty                              [str]
# S.revoked_host_keys                        [str]
# S.send_env                                 [str]
# S.server_alive_count_max                   [uint]
# S.server_alive_interval                    [uint]
# S.stream_local_bind_mask                   [str]
# S.stream_local_bind_unlink                 [str]
# S.strict_host_key_checking                 [str]
# S.tcp_keep_alive                           [str]
# S.tunnel                                   [str]
# S.tunnel_device                            [str]
# S.update_host_keys                         [str]
# S.use_privileged_port                      [str]
# S.user_known_hosts_file                    [str]
# S.verify_host_key_dns                      [str]
# S.visual_host_key                          [str]
# S.xauth_location                           [str]
#
ssh_config_st.__add__	user									str		\
						pass									str		\
						host									str		\
						port									uint	\
						forward_auth							bool	\
						bind_address							str		\
						log_file								str		\
						config_file								str		\
						add_keys_to_agent						str		\
						address_family							str		\
						batch_mode								str		\
						canonical_domains						str		\
						canonicalize_fallback_local				str		\
						canonicalize_hostname					str		\
						canonicalize_max_dots					uint	\
						canonicalize_permitted_cnames			str		\
						cetificate_file							str		\
						challenge_response_authentication		str		\
						check_host_ip							str		\
						ciphers									str		\
						clear_all_forwardings					str		\
						escape_char								str		\
						compression								str		\
						compression_level						uint	\
						connection_attempts						uint	\
						connect_timeout							uint	\
						control_master							str		\
						control_path							str		\
						control_persist							str		\
						dynamic_forward							str		\
						enable_ssh_keysing						str		\
						exit_on_forward_failure					str		\
						finger_print_hash						str		\
						forward_agent							str		\
						forward_x11								str		\
						forward_x11_timeout						uint	\
						forward_x11_trusted						str		\
						gateway_ports							str		\
						global_known_hosts_file					str		\
						gssapi_authentication					str		\
						gssapi_key_exchange						str		\
						gssapi_client_identity					str		\
						gssapi_server_identity					str		\
						gssapi_delegate_credentials				str		\
						gssapi_renewal_forces_rekey				str		\
						gssapi_trust_dns						str		\
						hash_known_hosts						str		\
						host_based_authentication				str		\
						host_based_key_types					str		\
						host_key_algorithms						str		\
						host_key_alias							str		\
						hostname								str		\
						identities_only							str		\
						identity_agent							str		\
						identity_file							str		\
						ignore_unknown							str		\
						include									str		\
						ip_qos									str		\
						kbd_interactive_authentication			str		\
						kbd_interactive_devices					str		\
						kex_algorithms							str		\
						local_command							str		\
						local_forward							str		\
						log_level								str		\
						macs									str		\
						no_host_authentication_for_local_host	str		\
						number_of_password_prompts				uint	\
						password_authentication					str		\
						permit_local_command					str		\
						pkcs11_provider							str		\
						preferred_authentications				str		\
						proxy_command							str		\
						proxy_jump								str		\
						proxy_use_fdpass						str		\
						pubkey_accepted_key_types				str		\
						pubkey_authentication					str		\
						rekey_limit								str		\
						remote_forward							str		\
						remote_command							str		\
						request_tty								str		\
						revoked_host_keys						str		\
						send_env								str		\
						server_alive_count_max					uint	\
						server_alive_interval					uint	\
						stream_local_bind_mask					str		\
						stream_local_bind_unlink				str		\
						strict_host_key_checking				str		\
						tcp_keep_alive							str		\
						tunnel									str		\
						tunnel_device							str		\
						update_host_keys						str		\
						use_privileged_port						str		\
						user_known_hosts_file					str		\
						verify_host_key_dns						str		\
						visual_host_key							str		\
						xauth_location							str

# .TYPE ssh_t
#
# Implementa o objeto 'S' com os métodos:
#
# S.new
# S.shell
# S.exec
# S.upload
# S.download
# S.close
#
typedef ssh_t	ssh.new			\
				ssh.shell		\
				ssh.exec		\
				ssh.upload		\
				ssh.download	\
				ssh.close

# Funções (somente-leitura)
readonly -f		ssh.new					\
				ssh.shell				\
				ssh.exec				\
				ssh.upload				\
				ssh.download			\
				ssh.close				\
				ssh.__openssl_decrypt__	\
				ssh.__openssl_crypt__

# /* __SSH_SH__ */
