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

[[ $__SSH_SH ]] && return 0

readonly __SSH_SH=1

source builtin.sh

readonly __ERR_SSH_HOST_CONNECT="não foi possível conectar ao host '%s'"
readonly __ERR_SSH_CP_FILE="erro durante a cópia do arquivo '%s'"

# Dependências.
__DEP__=(
[ssh]=
[scp]=
[setsid]=
[openssl]=
)

# Tipo.
__TYPE__[ssh_t]='
ssh.connect
ssh.connect_ex
ssh.shell
ssh.exec
ssh.upload
ssh.download
ssh.close
'

var ssh_config_t	struct_t

ssh_config_t.__add__	user					str	\
			pass					str	\
			host					str	\
			port					uint	\
			forward_auth				bool	\
			bind_address				str	\
			log_file				str	\
			config_file				str	\
			add_keys_to_agent			flag	\
			address_family				flag	\
			batch_mode				flag	\
			canonical_domains			str	\
			canonicalize_fallback_local		flag	\
			canonicalize_hostname			flag	\
			canonicalize_max_dots			uint	\
			canonicalize_permitted_cnames		str	\
			cetificate_file				file	\
			challenge_response_authentication	flag	\
			check_host_ip				flag	\
			ciphers					str	\
			clear_all_forwardings			flag	\
			escape_char				str	\
			compression				flag	\
			compression_level			uint	\
			connection_attempts			uint	\
			connect_timeout				uint	\
			control_master				flag	\
			control_path				path	\
			control_persist				flag	\
			dynamic_forward				str	\
			enable_ssh_keysing			flag	\
			exit_on_forward_failure			flag	\
			finger_print_hash			flag	\
			forward_agent				flag	\
			forward_x11				flag	\
			forward_x11_timeout			uint	\
			forward_x11_trusted			flag	\
			gateway_ports				flag	\
			global_known_hosts_file			str	\
			gssapi_authentication			flag	\
			gssapi_key_exchange			flag	\
			gssapi_client_identity			str	\
			gssapi_server_identity			str	\
			gssapi_delegate_credentials		flag	\
			gssapi_renewal_forces_rekey		flag	\
			gssapi_trust_dns			flag	\
			hash_known_hosts			flag	\
			host_based_authentication		flag	\
			host_based_key_types			str	\
			host_key_algorithms			str	\
			host_key_alias				str	\
			hostname				str	\
			identities_only				flag	\
			identity_agent				str	\
			identity_file				file	\
			ignore_unknown				str	\
			include					str	\
			ip_qos					flag	\
			kbd_interactive_authentication		flag	\
			kbd_interactive_devices			flag	\
			kex_algorithms				str	\
			local_command				str	\
			local_forward				str	\
			log_level				flag	\
			macs					str	\
			no_host_authentication_for_local_host	flag	\
			number_of_password_prompts		uint	\
			password_authentication			flag	\
			permit_local_command			flag	\
			pkcs11_provider				str	\
			preferred_authentications		str	\
			proxy_command				str	\
			proxy_jump				str	\
			proxy_use_fdpass			flag	\
			pubkey_accepted_key_types		str	\
			pubkey_authentication			flag	\
			rekey_limit				str	\
			remote_forward				str	\
			remote_command				str	\
			request_tty				flag	\
			revoked_host_keys			str	\
			send_env				str	\
			server_alive_count_max			uint	\
			server_alive_interval			uint	\
			stream_local_bind_mask			oct	\
			stream_local_bind_unlink		str	\
			strict_host_key_checking		flag	\
			tcp_keep_alive				flag	\
			tunnel					flag	\
			tunnel_device				str	\
			update_host_keys			flag	\
			use_privileged_port			flag	\
			user_known_hosts_file			str	\
			verify_host_key_dns			flag	\
			visual_host_key				flag	\
			xauth_location				file


function ssh.__openssl_crypt()
{
	local sha aes seed
	
	printf -v seed '%(%s)T'

	IFS=' ' read sha _ < <(sha256sum <<< "$((RANDOM * (BASHPID ^ seed)))")
	aes=$(openssl enc -e -aes-256-cbc -a -k "$sha" <<< $1)
	
	printf '%s|%s\n' \
		"$sha"	\
		"$aes"

	return $?
}

function ssh.__openssl_decrypt()
{
	local __ssh_key=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX)

	printf '#!/bin/bash\necho "%s"\n' \
		"$(openssl enc -d -aes-256-cbc -k "$1" < <(openssl base64 -d <<< "$2"))" > $__ssh_key

	chmod u+x $__ssh_key
	echo "$__ssh_key"
	
	return $?
}

# func ssh.connect_ex <[ssh_t]session> <[ssh_config_t]config> => [bool]
#
# Inicializa uma sessão ssh com configurações personalizadas.
#
# <session>         - Variável implementada por 'ssh_t'.
# <ssh_config_t>    - Estrutura contendo as opções avançadas.
#
function ssh.connect_ex()
{
	getopt.parse 2 "session:ssh_t:+:$1" "config:ssh_config_t:+:$2" "${@:3}"

	local __sha __aes __ssh_key __ssh_options

	local	__user=$($2.user) 									\
		__pass=$($2.pass) 									\
		__host=$($2.host) 									\
		__port=$($2.port) 									\
		__forward_auth=$($2.forward_auth) 							\
		__bind_address=$($2.bind_address) 							\
		__log_file=$($2.log_file) 								\
		__config_file=$($2.config_file) 							\
		__add_keys_to_agent=$($2.add_keys_to_agent) 						\
		__address_family=$($2.address_family) 							\
		__batch_mode=$($2.batch_mode) 								\
		__canonical_domains=$($2.canonical_domains) 						\
		__canonicalize_fallback_local=$($2.canonicalize_fallback_local) 			\
		__canonicalize_hostname=$($2.canonicalize_hostname) 					\
		__canonicalize_max_dots=$($2.canonicalize_max_dots) 					\
		__canonicalize_permitted_cnames=$($2.canonicalize_permitted_cnames) 			\
		__cetificate_file=$($2.cetificate_file) 						\
		__challenge_response_authentication=$($2.challenge_response_authentication)	 	\
		__check_host_ip=$($2.check_host_ip) 							\
		__ciphers=$($2.ciphers) 								\
		__clear_all_forwardings=$($2.clear_all_forwardings) 					\
		__escape_char=$($2.escape_char) 							\
		__compression=$($2.compression) 							\
		__compression_level=$($2.compression_level) 						\
		__connection_attempts=$($2.connection_attempts) 					\
		__connect_timeout=$($2.connect_timeout) 						\
		__control_master=$($2.control_master) 							\
		__control_path=$($2.control_path) 							\
		__control_persist=$($2.control_persist) 						\
		__dynamic_forward=$($2.dynamic_forward) 						\
		__enable_ssh_keysing=$($2.enable_ssh_keysing) 						\
		__exit_on_forward_failure=$($2.exit_on_forward_failure) 				\
		__finger_print_hash=$($2.finger_print_hash) 						\
		__forward_agent=$($2.forward_agent) 							\
		__forward_x11=$($2.forward_x11) 							\
		__forward_x11_timeout=$($2.forward_x11_timeout) 					\
		__forward_x11_trusted=$($2.forward_x11_trusted) 					\
		__gateway_ports=$($2.gateway_ports) 							\
		__global_known_hosts_file=$($2.global_known_hosts_file) 				\
		__gssapi_authentication=$($2.gssapi_authentication) 					\
		__gssapi_key_exchange=$($2.gssapi_key_exchange) 					\
		__gssapi_client_identity=$($2.gssapi_client_identity) 					\
		__gssapi_server_identity=$($2.gssapi_server_identity) 					\
		__gssapi_delegate_credentials=$($2.gssapi_delegate_credentials) 			\
		__gssapi_renewal_forces_rekey=$($2.gssapi_renewal_forces_rekey) 			\
		__gssapi_trust_dns=$($2.gssapi_trust_dns) 						\
		__hash_known_hosts=$($2.hash_known_hosts) 						\
		__host_based_authentication=$($2.host_based_authentication) 				\
		__host_based_key_types=$($2.host_based_key_types) 					\
		__host_key_algorithms=$($2.host_key_algorithms) 					\
		__host_key_alias=$($2.host_key_alias) 							\
		__hostname=$($2.hostname) 								\
		__identities_only=$($2.identities_only) 						\
		__identity_agent=$($2.identity_agent) 							\
		__identity_file=$($2.identity_file) 							\
		__ignore_unknown=$($2.ignore_unknown) 							\
		__include=$($2.include) 								\
		__ip_qos=$($2.ip_qos) 									\
		__kbd_interactive_authentication=$($2.kbd_interactive_authentication) 			\
		__kbd_interactive_devices=$($2.kbd_interactive_devices) 				\
		__kex_algorithms=$($2.kex_algorithms) 							\
		__local_command=$($2.local_command) 							\
		__local_forward=$($2.local_forward) 							\
		__log_level=$($2.log_level) 								\
		__macs=$($2.macs) 									\
		__no_host_authentication_for_local_host=$($2.no_host_authentication_for_local_host) 	\
		__number_of_password_prompts=$($2.number_of_password_prompts) 				\
		__password_authentication=$($2.password_authentication) 				\
		__permit_local_command=$($2.permit_local_command) 					\
		__pkcs11_provider=$($2.pkcs11_provider) 						\
		__preferred_authentications=$($2.preferred_authentications) 				\
		__proxy_command=$($2.proxy_command) 							\
		__proxy_jump=$($2.proxy_jump) 								\
		__proxy_use_fdpass=$($2.proxy_use_fdpass) 						\
		__pubkey_accepted_key_types=$($2.pubkey_accepted_key_types) 				\
		__pubkey_authentication=$($2.pubkey_authentication) 					\
		__rekey_limit=$($2.rekey_limit) 							\
		__remote_forward=$($2.remote_forward) 							\
		__remote_command=$($2.remote_command) 							\
		__request_tty=$($2.request_tty) 							\
		__revoked_host_keys=$($2.revoked_host_keys) 						\
		__send_env=$($2.send_env) 								\
		__server_alive_count_max=$($2.server_alive_count_max) 					\
		__server_alive_interval=$($2.server_alive_interval) 					\
		__stream_local_bind_mask=$($2.stream_local_bind_mask) 					\
		__stream_local_bind_unlink=$($2.stream_local_bind_unlink) 				\
		__strict_host_key_checking=$($2.strict_host_key_checking) 				\
		__tcp_keep_alive=$($2.tcp_keep_alive) 							\
		__tunnel=$($2.tunnel) 									\
		__tunnel_device=$($2.tunnel_device) 							\
		__update_host_keys=$($2.update_host_keys) 						\
		__use_privileged_port=$($2.use_privileged_port) 					\
		__user_known_hosts_file=$($2.user_known_hosts_file) 					\
		__verify_host_key_dns=$($2.verify_host_key_dns) 					\
		__visual_host_key=$($2.visual_host_key) 						\
		__xauth_location=$($2.xauth_location)
	
	# Definições.
	__ssh_options+="${__add_keys_to_agent:+-o AddKeysToAgent=$__add_keys_to_agent }"
	__ssh_options+="${__address_family:+-o AddressFamily=$__address_family }"
	__ssh_options+="${__batch_mode:+-o BatchMode=$__batch_mode }"
	__ssh_options+="${__bind_address:+-o BindAddress=$__bind_address }"
	__ssh_options+="${__canonical_domains:+-o CanonicalDomains=$__canonical_domains }"
	__ssh_options+="${__canonicalize_fallback_local:+-o CanonicalizeFallbackLocal=$__canonicalize_fallback_local }"
	__ssh_options+="${__canonicalize_hostname:+-o CanonicalizeHostname=$__canonicalize_hostname }"
	__ssh_options+="${__canonicalize_max_dots:+-o CanonicalizeMaxDots=$__canonicalize_max_dots }"
	__ssh_options+="${__canonicalize_permitted_cnames:+-o CanonicalizePermittedCNAMEs=$__canonicalize_permitted_cnames }"
	__ssh_options+="${__cetificate_file:+-o CertificateFile=$__cetificate_file }"
	__ssh_options+="${__challenge_response_authentication:+-o ChallengeResponseAuthentication=$__challenge_response_authentication }"
	__ssh_options+="${__check_host_ip:+-o CheckHostIP=$__check_host_ip }"
	__ssh_options+="${__ciphers:+-o Ciphers=$__ciphers }"
	__ssh_options+="${__clear_all_forwardings:+-o ClearAllForwardings=$__clear_all_forwardings }"
	__ssh_options+="${__compression_level:+-o  $__compression_level }"
	__ssh_options+="${__compression:+-o Compression=$__compression }"
	__ssh_options+="${__config_file:+-F $__config_file }"
	__ssh_options+="${__connection_attempts:+-o ConnectionAttempts=$__connection_attempts }"
	__ssh_options+="${__connect_timeout:+-o ConnectTimeout=$__connect_timeout }"
	__ssh_options+="${__control_master:+-o ControlMaster=$__control_master }"
	__ssh_options+="${__control_path:+-o ControlPath=$__control_path }"
	__ssh_options+="${__control_persist:+-o ControlPersist=$__control_persist }"
	__ssh_options+="${__dynamic_forward:+-o DynamicForward=$__dynamic_forward }"
	__ssh_options+="${__enable_ssh_keysing:+-o EnableSSHKeysign=$__enable_ssh_keysing }"
	__ssh_options+="${__escape_char:+-o EscapeChar=$__escape_char }"
	__ssh_options+="${__exit_on_forward_failure:+-o ExitOnForwardFailure=$__exit_on_forward_failure }"
	__ssh_options+="${__finger_print_hash:+-o FingerprintHash=$__finger_print_hash }"
	__ssh_options+="${__forward_agent:+-o ForwardAgent=$__forward_agent }"
	__ssh_options+="${__forward_auth:+-o $__forward_auth }"
	__ssh_options+="${__forward_x11:+-o ForwardX11=$__forward_x11 }"
	__ssh_options+="${__forward_x11_timeout:+-o ForwardX11Timeout=$__forward_x11_timeout }"
	__ssh_options+="${__forward_x11_trusted:+-o ForwardX11Trusted=$__forward_x11_trusted }"
	__ssh_options+="${__gateway_ports:+-o GatewayPorts=$__gateway_ports }"
	__ssh_options+="${__global_known_hosts_file:+-o GlobalKnownHostsFile=$__global_known_hosts_file }"
	__ssh_options+="${__gssapi_authentication:+-o GSSAPIAuthentication=$__gssapi_authentication }"
	__ssh_options+="${__gssapi_client_identity:+-o GSSAPIClientIdentity=$__gssapi_client_identity }"
	__ssh_options+="${__gssapi_delegate_credentials:+-o GSSAPIDelegateCredentials=$__gssapi_delegate_credentials }"
	__ssh_options+="${__gssapi_key_exchange:+-o GSSAPIKeyExchange=$__gssapi_key_exchange }"
	__ssh_options+="${__gssapi_renewal_forces_rekey:+-o GSSAPIRenewalForcesRekey=$__gssapi_renewal_forces_rekey }"
	__ssh_options+="${__gssapi_server_identity:+-o GSSAPIServerIdentity=$__gssapi_server_identity }"
	__ssh_options+="${__gssapi_trust_dns:+-o GSSAPITrustDns=$__gssapi_trust_dns }"
	__ssh_options+="${__hash_known_hosts:+-o HashKnownHosts=$__hash_known_hosts }"
	__ssh_options+="${__host_based_authentication:+-o HostbasedAuthentication=$__host_based_authentication }"
	__ssh_options+="${__host_based_key_types:+-o HostbasedKeyTypes=$__host_based_key_types }"
	__ssh_options+="${__host_key_algorithms:+-o HostKeyAlgorithms=$__host_key_algorithms }"
	__ssh_options+="${__host_key_alias:+-o HostKeyAlias=$__host_key_alias }"
	__ssh_options+="${__hostname:+-o HostName=$__hostname }"
	__ssh_options+="${__identities_only:+-o IdentitiesOnly=$__identities_only }"
	__ssh_options+="${__identity_agent:+-o IdentityAgent=$__identity_agent }"
	__ssh_options+="${__identity_file:+-o IdentityFile=$__identity_file }"
	__ssh_options+="${__ignore_unknown:+-o IgnoreUnknown=$__ignore_unknown }"
	__ssh_options+="${__include:+-o Include=$__include }"
	__ssh_options+="${__ip_qos:+-o IPQoS=$__ip_qos }"
	__ssh_options+="${__kbd_interactive_authentication:+-o KbdInteractiveAuthentication=$__kbd_interactive_authentication }"
	__ssh_options+="${__kbd_interactive_devices:+-o KbdInteractiveDevices=$__kbd_interactive_devices }"
	__ssh_options+="${__kex_algorithms:+-o KexAlgorithms=$__kex_algorithms }"
	__ssh_options+="${__local_command:+-o LocalCommand=$__local_command }"
	__ssh_options+="${__local_forward:+-o LocalForward=$__local_forward }"
	__ssh_options+="${__log_file:+-E $__log_file }"
	__ssh_options+="${__log_level:+-o LogLevel=$__log_level }"
	__ssh_options+="${__macs:+-o MACs=$__macs }"
	__ssh_options+="${__no_host_authentication_for_local_host:+-o NoHostAuthenticationForLocalhost=$__no_host_authentication_for_local_host }"
	__ssh_options+="${__number_of_password_prompts:+-o NumberOfPasswordPrompts=$__number_of_password_prompts }"
	__ssh_options+="${__password_authentication:+-o PasswordAuthentication=$__password_authentication }"
	__ssh_options+="${__permit_local_command:+-o PermitLocalCommand=$__permit_local_command }"
	__ssh_options+="${__pkcs11_provider:+-o PKCS11Provider=$__pkcs11_provider }"
	__ssh_options+="${__port:+-o Port=$__port }"
	__ssh_options+="${__preferred_authentications:+-o PreferredAuthentications=$__preferred_authentications }"
	__ssh_options+="${__proxy_command:+-o ProxyCommand=$__proxy_command }"
	__ssh_options+="${__proxy_jump:+-o ProxyJump=$__proxy_jump }"
	__ssh_options+="${__proxy_use_fdpass:+-o ProxyUseFdpass=$__proxy_use_fdpass }"
	__ssh_options+="${__pubkey_accepted_key_types:+-o PubkeyAcceptedKeyTypes=$__pubkey_accepted_key_types }"
	__ssh_options+="${__pubkey_authentication:+-o PubkeyAuthentication=$__pubkey_authentication }"
	__ssh_options+="${__rekey_limit:+-o RekeyLimit=$__rekey_limit }"
	__ssh_options+="${__remote_command:+-o RemoteCommand=$__remote_command }"
	__ssh_options+="${__remote_forward:+-o RemoteForward=$__remote_forward }"
	__ssh_options+="${__request_tty:+-o RequestTTY=$__request_tty }"
	__ssh_options+="${__revoked_host_keys:+-o RevokedHostKeys=$__revoked_host_keys }"
	__ssh_options+="${__send_env:+-o SendEnv=$__send_env }"
	__ssh_options+="${__server_alive_count_max:+-o ServerAliveCountMax=$__server_alive_count_max }"
	__ssh_options+="${__server_alive_interval:+-o ServerAliveInterval=$__server_alive_interval }"
	__ssh_options+="${__stream_local_bind_mask:+-o StreamLocalBindMask=$__stream_local_bind_mask }"
	__ssh_options+="${__stream_local_bind_unlink:+-o StreamLocalBindUnlink=$__stream_local_bind_unlink }"
	__ssh_options+="${__strict_host_key_checking:+-o StrictHostKeyChecking=$__strict_host_key_checking }"
	__ssh_options+="${__tcp_keep_alive:+-o TCPKeepAlive=$__tcp_keep_alive }"
	__ssh_options+="${__tunnel_device:+-o TunnelDevice=$__tunnel_device }"
	__ssh_options+="${__tunnel:+-o Tunnel=$__tunnel }"
	__ssh_options+="${__update_host_keys:+-o UpdateHostKeys=$__update_host_keys }"
	__ssh_options+="${__use_privileged_port:+-o UsePrivilegedPort=$__use_privileged_port }"
	__ssh_options+="${__user_known_hosts_file:+-o UserKnownHostsFile=$__user_known_hosts_file }"
	__ssh_options+="${__verify_host_key_dns:+-o VerifyHostKeyDNS=$__verify_host_key_dns }"
	__ssh_options+="${__visual_host_key:+-o VisualHostKey=$__visual_host_key }"
	__ssh_options+="${__xauth_location:+-o XAuthLocation=$__xauth_location }"

	__ssh_key=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX)

	printf '#!/bin/bash\necho "%s"\n' "$__pass" > $__ssh_key
	chmod u+x $__ssh_key

	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key
	
	trap "rm -f $__ssh_key &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM RETURN

	if ! setsid --wait ssh -qt				\
				-o StrictHostKeyChecking=no 	\
				-o UserKnownHostsFile=/dev/null \
				$__ssh_options 			\
				$__user@$__host 		\
				'exit'; then
		error.format 1 "$__ERR_SSH_HOST_CONNECT" "$__host"
		return $?
	fi

	IFS='|' read __sha __aes < <(ssh.__openssl_crypt "$__pass")
	
	printf -v $1 '%s|%s|%s|%s|%s' \
		"$__host" \
		"$__user" \
		"$__sha" \
		"$__aes" \
		"$__ssh_options"

	return $?
}

# func ssh.connect <[ssh_t]session> <[str]host> <[str]user> <[str]password> => [bool]
#
# Inicializa uma sessão ssh.
#
# <session>    - Variável implementada por 'ssh_t'.
# <host>       - Nome ou endereço do host de destino.
# <user>       - Nome do usuário remoto.
# <password>   - Senha.
#
function ssh.connect()
{
	getopt.parse 4 "session:ssh_t:+:$1" "host:str:+:$2" "user:str:+:$3" "password:str:+:$4" "${@:5}"
	
	local __sha __aes __ssh_key __pass 

	__ssh_key=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX)

	printf '#!/bin/bash\necho "%s"\n' "$4" > $__ssh_key
	chmod u+x $__ssh_key

	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key
	
	trap "rm -f $__ssh_key &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM RETURN

	if ! setsid --wait ssh -qt 				\
				-o StrictHostKeyChecking=no 	\
				-o UserKnownHostsFile=/dev/null \
				$3@$2 				\
				'exit 0' &>/dev/null; then
		error.format 1 "$__ERR_SSH_HOST_CONNECT" "$2"
		return $?
	fi

	IFS='|' read __sha __aes < <(ssh.__openssl_crypt "$4")

	printf -v $1 '%s|%s|%s|%s' \
		"$2" 	 \
		"$3"	 \
		"$__sha" \
		"$__aes"

	return $?
}

# func ssh.shell <[ssh_t]session> <[str]commands> => [bool]
#
# Inicia um shell não interativo, executando a lista de comandos no host remoto.
#
# <session>    - Sessão ssh ativa. (veja: ssh.connect ou ssh.connect_ex)
# <commands>   - Lista de comandos válidos a serem executados.
#
function ssh.shell()
{
	getopt.parse 2 "session:ssh_t:+:$1" "commands:str:+:$2" "${@:3}"

	local __user __host __sha __aes __ssh_options
	local -n __ref=$1

	IFS='|' read __host __user __sha __aes __ssh_options <<< $__ref
	__ssh_key=$(ssh.__openssl_decrypt "$__sha" "$__aes" 2>/dev/null)

	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key
	
	trap "rm -f $__ssh_key &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM RETURN
	
	setsid --wait ssh	-t 				\
				-o StrictHostKeyChecking=no 	\
				-o UserKnownHostsFile=/dev/null \
				$__ssh_options 			\
				$__user@$__host 		\
				"exec 2>&1; $2" 2>/dev/null

	if [[ $? -eq 255 ]]; then
		error.format 1 "$__ERR_SSH_HOST_CONNECT" "$__host"
		return $?
	fi

	return $?
}

# func ssh.exec <[ssh_t]session> <[file]script> => [bool]
#
# Executa o script local no host remoto.
#
# <session>    - Sessão ssh ativa. (veja: ssh.connect ou ssh.connect_ex)
# <script>     - Script local a ser executado.
#
function ssh.exec()
{
	getopt.parse 2 "session:ssh_t:+:$1" "script:file:+:$2" "${@:3}"

	local __user __host __sha __aes __ssh_options __base64src __cmd __remote_path __ssh_key
	local -n __ref=$1

	IFS='|' read __host __user __sha __aes __ssh_options <<< $__ref

	__ssh_key=$(ssh.__openssl_decrypt "$__sha" "$__aes" 2>/dev/null)
	__remote_path=$(mktemp -qtu XXXXXXXXXXXXXXXXXXXX.sh)
	__base64src=$(base64 --wrap=0 "$2")

	__cmd+="base64 --decode <<< $__base64src > $__remote_path;"
	__cmd+="chmod u+x $__remote_path;"
	__cmd+="$__remote_path 2>&1;"
	__cmd+="rm -f $__remote_path;"
	__cmd+='exit 0'
	
	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key
	
	trap "rm -f $__ssh_key &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM RETURN

	setsid --wait ssh 	-t				\
				-o StrictHostKeyChecking=no 	\
				-o UserKnownHostsFile=/dev/null \
				$__ssh_options			\
				$__user@$__host 		\
				"exec 2>&1; $__cmd" 2>/dev/null

	if [[ $? -eq 255 ]]; then
		error.format 1 "$__ERR_SSH_HOST_CONNECT" "$__host"
		return $?
	fi

	return $?
}

# func ssh.upload <[ssh_t]session> <[path]source> <[str]destination> <[bool]recursive> => [bool]
#
# Envia um diretório/arquivo local para o diretório do host remoto.
#
# <session>     - Sessão ssh ativa. (veja: ssh.connect ou ssh.connect_ex)
# <source>      - Diretório/arquivo válido a ser enviado.
# <destination> - Diretório remoto.
#
function ssh.upload()
{
	getopt.parse 4 "session:ssh_t:+:$1" "source:path:+:$2" "destination:str:+:$3" "recursive:bool:+:$4" "${@:5}"
	
	local __user __host __sha __aes __ssh_options __rec __ssh_key
	local -n __ref=$1
	
	__rec=${4#false}

	IFS='|' read __host __user __sha __aes __ssh_options <<< $__ref
	__ssh_key=$(ssh.__openssl_decrypt "$__sha" "$__aes" 2>/dev/null)
	
	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key

	trap "rm -f $__ssh_key &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM RETURN
	
	if ! setsid --wait scp 	-o StrictHostKeyChecking=no 		\
				-o UserKnownHostsFile=/dev/null 	\
				$__ssh_options				\
				${__rec:+-r} "$2"			\
				$__user@$__host:"$3" &>/dev/null; then
		error.format 1 "$__ERR_SSH_CP_FILE" "$2"
		return $?
	fi
		
	return $?
}

# func ssh.download <[ssh_t]session> <[str]source> <[path]destination> <[bool]recursive> => [bool]
#
# Baixa o diretório/arquivo remoto para o caminho especificado.
#
# <source> 	- Diretório remoto a ser copiado.
# <destination>	- Diretório local onde o arquivo será salvo.
# <recursive>	- Habilita cópia recursiva para diretórios.
#
function ssh.download()
{
	getopt.parse 4 "session:ssh_t:+:$1" "source:str:+:$2" "destination:path:+:$3" "recursive:bool:+:$4" "${@:5}"
	
	local __user __host __sha __aes __ssh_options __rec __ssh_key __rec
	local -n __ref=$1

	__rec=${4#false}

	IFS='|' read __host __user __sha __aes __ssh_options <<< $__ref
	__ssh_key=$(ssh.__openssl_decrypt "$__sha" "$__aes" 2>/dev/null)

	export DISPLAY=:0
	export SSH_ASKPASS=$__ssh_key

	trap "rm -f $__ssh_key &>/dev/null; unset SSH_ASKPASS DISPLAY" SIGINT SIGTERM RETURN
	
	if ! setsid --wait scp 	-o StrictHostKeyChecking=no 		\
				-o UserKnownHostsFile=/dev/null 	\
				$__ssh_options				\
				${__rec:+-r} $__user@$__host:"$2"	\
				"$3" &>/dev/null; then
		error.format 1 "$__ERR_SSH_CP_FILE" "$2"
		return $?
	fi
		
	return $?
}

# func ssh.close <[ssh_t]session> => [bool]
#
# Fecha a sessão ssh.
# 
# <session>    - Sessão ssh ativa. (veja: ssh.connect ou ssh.connect_ex)
#
function ssh.close()
{
	getopt.parse 1 "session:ssh_t:+:$1" "${@:2}"
	del $1
	return $?
}

source.__INIT__
# /* __SSH_SH */