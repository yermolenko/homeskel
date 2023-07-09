#!/bin/bash
#
#  yaa-ssh-tricks - various ssh-based tricks
#
#  Copyright (C) 2010, 2013, 2019, 2020, 2021, 2022, 2023 Alexander
#  Yermolenko <yaa.mbox@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# source ./host-config || exit 1

die()
{
    local msg=${1:-"Unknown error"}
    shift
    echo "ERROR: $msg $@" 1>&2
    call_function_if_declared finalize
    exit 1
}

goodbye()
{
    die "Cancelled by user"
}

require()
{
    local cmd=${1:?"Command name is required"}
    local extra_info=${2:+"\nNote: $2"}
    hash "$cmd" 2>/dev/null || die "$cmd not found$extra_info"
}

function_is_declared()
{
    declare -f -F ${1:?"Function name is required"} >/dev/null 2>&1
}

call_function_if_declared()
{
    local function_name=${1:?"Function name is required"}
    shift
    function_is_declared "$function_name" && "$function_name" "$@"
}

var_is_declared()
{
    declare -p ${1:?"Variable name is required"} >/dev/null 2>&1
}

var_is_declared_and_nonzero()
{
    local var_name=${1:?"Variable name is required"}
    var_is_declared "$var_name" && [ "${!var_name}" -ne 0 ]
}

flag_is_set()
{
    var_is_declared_and_nonzero "$1"
}

flag_is_unset()
{
    ! var_is_declared_and_nonzero "$1"
}

info()
{
    local msg=${1:-"Unspecified message"}
    shift
    flag_is_set quiet_mode || \
        echo "INFO: $msg $@" 1>&2
}

require_var()
{
    var_is_declared "$1" || die "Variable '$1' is not declared"
}

check_var()
{
    var_is_declared "$1" && info "$1: declared" || info "$1: not declared"
}

timestamp()
{
    echo $(date "+%Y%m%d-%H%M%S")
}

check_host_config()
{
    check_var host
    check_var user
    check_var ssh_port

    check_var extra_ssh_options

    check_var sshfs_remote_root
    check_var extra_sshfs_options

    check_var local_port_forwarding_pairs

    check_var remote_port_forwarding_pairs

    check_var socks_proxy_local_port

    check_var remote_x11_server_displays
    check_var vnc_remote_port_start
    check_var vnc_local_port_start
}

prohibit_using_virtual_host_config()
{
    [ -e ./.virtual ] && die "The host config is virtual. Remove ./.virtual to use it"
}

ssh_login()
{
    require_var host
    require_var user
    require_var ssh_port

    require ssh

    prohibit_using_virtual_host_config

    if var_is_declared ssh_password;
    then
        require sshpass
        SSHPASS="$ssh_password" sshpass -e \
               ssh "${extra_ssh_options[@]}" \
               -p $ssh_port \
               "$user@$host"
    elif var_is_declared ssh_password_file;
    then
        require sshpass
        sshpass -f "$ssh_password_file" \
                ssh "${extra_ssh_options[@]}" \
                -p $ssh_port \
                "$user@$host"
    else
        ssh "${extra_ssh_options[@]}" \
            -p $ssh_port \
            "$user@$host"
    fi
}

ssh_copy_id()
{
    require_var host
    require_var user
    require_var ssh_port

    require ssh-copy-id

    prohibit_using_virtual_host_config

    ssh-copy-id -p $ssh_port "${extra_ssh_options[@]}" "$user@$host"
}

sftp_interactive()
{
    require_var host
    require_var user
    require_var ssh_port

    require sftp

    prohibit_using_virtual_host_config

    sftp "${extra_ssh_options[@]}" -P $ssh_port "$user@$host"
}

sshfs_mount()
{
    require_var host
    require_var user
    require_var ssh_port

    require sshfs

    prohibit_using_virtual_host_config

    [ -e ./fs ] || mkdir ./fs
    [ -d ./fs ] || die "Cannot create mountpoint"

    if [ ${#extra_ssh_options[@]} -eq 0 ]; then
        ssh_command_option_for_sshfs=()
    else
        ssh_command_option_for_sshfs=(-o ssh_command="ssh ${extra_ssh_options[*]}")
    fi

    if var_is_declared do_not_pass_extra_ssh_options_to_sshfs;
    then
        ssh_command_option_for_sshfs=()
    fi

    info "extra_sshfs_options: ${extra_sshfs_options[@]}"
    info "ssh_command_option_for_sshfs: ${ssh_command_option_for_sshfs[@]}"

    if var_is_declared ssh_password;
    then
        echo "$ssh_password" | \
            sshfs "$user@$host":"$sshfs_remote_root" ./fs/ \
                  -p $ssh_port "${extra_sshfs_options[@]}" \
                  "${ssh_command_option_for_sshfs[@]}" \
                  -o password_stdin
    elif var_is_declared ssh_password_file;
    then
        [ -f "$ssh_password_file" ] || die "ssh_password_file does not exist"
        sshfs "$user@$host":"$sshfs_remote_root" ./fs/ \
              -p $ssh_port "${extra_sshfs_options[@]}" \
              "${ssh_command_option_for_sshfs[@]}" \
              -o password_stdin \
              < "$ssh_password_file"
    else
        sshfs "$user@$host":"$sshfs_remote_root" ./fs/ \
              -p $ssh_port "${extra_sshfs_options[@]}" \
              "${ssh_command_option_for_sshfs[@]}"
    fi
}

sshfs_umount()
{
    fusermount -u ./fs && sleep 2 && rmdir ./fs
}

exit_ssh_via_control_sockets_list()
{
    require_var host

    require ssh

    ssh_control_sockets_list_file=${1:?Filename of the file containing control sockets filenames is required}

    [ -e "$ssh_control_sockets_list_file" ] || return 0

    removal_was_clean=1

    ssh_control_sockets_directory=$( mktemp -d )
    rmdir "$ssh_control_sockets_directory"

    while IFS= read -r socket_file_name; do
        [ -e "$socket_file_name" ] && \
            info "Sending exit command to the socket: $socket_file_name" && \
            ssh -S "$socket_file_name" \
                -O exit \
                "$host"
        ssh_control_sockets_directory="$(dirname $socket_file_name)"
        [ -e "$socket_file_name" ] && sleep 1
        [ -e "$socket_file_name" ] && \
            removal_was_clean=0 && \
            info "WARNING: socket $socket_file_name still exists"

        [ -e "$socket_file_name.stdout" ] && [ $removal_was_clean -eq 1 ] && \
            rm "$socket_file_name.stdout"
        [ -e "$socket_file_name.stdout" ] && \
            removal_was_clean=0 && \
            info "WARNING: log file $socket_file_name.stdout still exists"

        [ -e "$socket_file_name.stderr" ] && [ $removal_was_clean -eq 1 ] && \
            rm "$socket_file_name.stderr"
        [ -e "$socket_file_name.stderr" ] && \
            removal_was_clean=0 && \
            info "WARNING: log file $socket_file_name.stderr still exists"
    done < "$ssh_control_sockets_list_file"

    [ $removal_was_clean -eq 1 ] && \
        rm "$ssh_control_sockets_list_file"

    [ $removal_was_clean -eq 1 ] && [ -d "$ssh_control_sockets_directory" ] && \
        rmdir "$ssh_control_sockets_directory"
}

local_port_forwarding_setup()
{
    require_var host
    require_var user
    require_var ssh_port

    require ssh

    prohibit_using_virtual_host_config

    local_port_start=${1:?Local port number is required}
    remote_port_start=${2:?Remote port number is required}
    forwarded_ports_count=${3:-1}
    ssh_control_sockets_list_file=${4:-./local_port_forwarding.ssh_control_sockets}

    port_shift_limit=$(( ${forwarded_ports_count:-1} - 1 ))
    port_shift=0

    tempdir=$( mktemp -d )

    while true
    do
        remote_port=$(( $remote_port_start + $port_shift ))
        local_port=$(( $local_port_start + $port_shift ))

        info "Preparing port forwarding: local $local_port -> remote $remote_port ..."

        socket_file_name="$tempdir/.ssh-${host:${#host}<15?0:-15}-lpf-$remote_port-$local_port"

        ssh -S "$socket_file_name" -M \
            -C -N -f -p $ssh_port \
            "${extra_ssh_options[@]}" -o ExitOnForwardFailure=yes \
            -L $local_port:127.0.0.1:$remote_port \
            "$user@$host" \
            > "$socket_file_name.stdout" 2> "$socket_file_name.stderr" || info "$(timestamp): ssh lpf setup call failed"

        echo "$socket_file_name" >> "$ssh_control_sockets_list_file"

        port_shift=$(( $port_shift + 1 ))
        [ $port_shift -gt $port_shift_limit ] && break
    done
}

local_port_forwarding_setup_from_config()
{
    require_var local_port_forwarding_pairs

    prohibit_using_virtual_host_config

    for port_fwd_pair in "${local_port_forwarding_pairs[@]}" ; do
        local_port=${port_fwd_pair%%:*}
        remote_port=${port_fwd_pair#*:}
        info "Read from config: local_port: $local_port, remote_port: $remote_port"
        local_port_forwarding_setup $local_port $remote_port
    done
}

local_port_forwarding_remove()
{
    exit_ssh_via_control_sockets_list ./local_port_forwarding.ssh_control_sockets
}

remote_port_forwarding_setup()
{
    require_var host
    require_var user
    require_var ssh_port

    require ssh

    prohibit_using_virtual_host_config

    info "To bind to non-loopback interfaces on the server GatewayPorts should be enabled in sshd_config"

    remote_port_start=${1:?Remote port number is required}
    local_port_start=${2:?Local port number is required}
    forwarded_ports_count=${3:-1}
    ssh_control_sockets_list_file=${4:-./remote_port_forwarding.ssh_control_sockets}

    port_shift_limit=$(( ${forwarded_ports_count:-1} - 1 ))
    port_shift=0

    tempdir=$( mktemp -d )

    while true
    do
        remote_port=$(( $remote_port_start + $port_shift ))
        local_port=$(( $local_port_start + $port_shift ))

        info "Preparing port forwarding: remote $remote_port -> local $local_port ..."

        socket_file_name="$tempdir/.ssh-${host:${#host}<15?0:-15}-rpf-$remote_port-$local_port"

        ssh -S "$socket_file_name" -M \
            -C -N -f -p $ssh_port \
            "${extra_ssh_options[@]}" -o ExitOnForwardFailure=yes \
            -R :$remote_port:127.0.0.1:$local_port \
            "$user@$host" \
            > "$socket_file_name.stdout" 2> "$socket_file_name.stderr" || info "$(timestamp): ssh rpf setup call failed"

        echo "$socket_file_name" >> "$ssh_control_sockets_list_file"

        port_shift=$(( $port_shift + 1 ))
        [ $port_shift -gt $port_shift_limit ] && break
    done
}

remote_port_forwarding_setup_from_config()
{
    require_var remote_port_forwarding_pairs

    prohibit_using_virtual_host_config

    for port_fwd_pair in "${remote_port_forwarding_pairs[@]}" ; do
        remote_port=${port_fwd_pair%%:*}
        local_port=${port_fwd_pair#*:}
        info "Read from config: remote_port: $remote_port, local_port: $local_port"
        remote_port_forwarding_setup $remote_port $local_port
    done
}

remote_port_forwarding_remove()
{
    exit_ssh_via_control_sockets_list ./remote_port_forwarding.ssh_control_sockets
}

socks_proxy()
{
    require_var host
    require_var user
    require_var ssh_port

    require_var socks_proxy_local_port

    require ssh

    prohibit_using_virtual_host_config

    local ssh_command=(ssh)
    ssh_command+=(-D 127.0.0.1:$socks_proxy_local_port -C -N)
    ssh_command+=(-o ExitOnForwardFailure=yes)
    ssh_command+=(-o ConnectTimeout=15)
    ssh_command+=("${extra_ssh_options[@]}")
    ssh_command+=(-p $ssh_port)
    ssh_command+=(-l "$user" "$host")

    local ssh_log_base="./socks_proxy"

    if var_is_declared ssh_password;
    then
        require sshpass

        local sshpass_command=(sshpass -e)
        sshpass_command+=("${ssh_command[@]}")

        SSHPASS="$ssh_password" "${sshpass_command[@]}" \
            1> "$ssh_log_base.stdout" \
            2> "$ssh_log_base.stderr" || \
            info "$(timestamp): ssh dpf setup call failed"
    elif var_is_declared ssh_password_file;
    then
        require sshpass

        local sshpass_command=(sshpass -f "$ssh_password_file")
        sshpass_command+=("${ssh_command[@]}")

        "${sshpass_command[@]}" \
            1> "$ssh_log_base.stdout" \
            2> "$ssh_log_base.stderr" || \
            info "$(timestamp): ssh dpf setup call failed"
    else
        "${ssh_command[@]}" \
            1> "$ssh_log_base.stdout" \
            2> "$ssh_log_base.stderr" || \
            info "$(timestamp): ssh dpf setup call failed"
    fi
}

socks_proxy_setup()
{
    require_var host
    require_var user
    require_var ssh_port

    require_var socks_proxy_local_port

    require ssh

    prohibit_using_virtual_host_config

    ssh_control_sockets_list_file=./socks_proxy.ssh_control_sockets

    tempdir=$( mktemp -d )

    socket_file_name="$tempdir/.ssh-${host:${#host}<15?0:-15}-socks-proxy-$socks_proxy_local_port"

    ssh -S "$socket_file_name" -M \
        -C -N -f -p $ssh_port \
        "${extra_ssh_options[@]}" -o ExitOnForwardFailure=yes \
        -D 127.0.0.1:$socks_proxy_local_port \
        "$user@$host" \
        > "$socket_file_name.stdout" 2> "$socket_file_name.stderr" || info "$(timestamp): ssh call failed"

    echo "$socket_file_name" >> "$ssh_control_sockets_list_file"
}

socks_proxy_remove()
{
    exit_ssh_via_control_sockets_list ./socks_proxy.ssh_control_sockets
}

vnc_setup()
{
    require_var host
    require_var user
    require_var ssh_port

    require_var remote_x11_server_displays
    require_var vnc_remote_port_start
    require_var vnc_local_port_start

    require ssh

    prohibit_using_virtual_host_config

    vnc_remote_port=$vnc_remote_port_start
    vnc_local_port=$vnc_local_port_start

    for x11_server_display in "${remote_x11_server_displays[@]}" ; do
        info "Setting up x11vnc for display $x11_server_display"

        local_port_forwarding_setup \
            $vnc_local_port \
            $vnc_remote_port \
            1 \
            ./local_port_forwarding_for_vnc.ssh_control_sockets

        ssh -f -p $ssh_port \
            "${extra_ssh_options[@]}" \
            "$user@$host" \
            "sh -c '\
        cd /tmp; \
        nohup killall x11vnc > /dev/null 2>&1; \
        sleep 3; \
        nohup x11vnc -display $x11_server_display -localhost -rfbport $vnc_remote_port -quiet -many -noxdamage > /dev/null 2>&1 &\
        '"

        vnc_remote_port=$(( $vnc_remote_port + 1 ))
        vnc_local_port=$(( $vnc_local_port + 1 ))
    done
}

vnc_remove()
{
    require_var host
    require_var user
    require_var ssh_port

    # require_var remote_x11_server_displays

    require ssh

    prohibit_using_virtual_host_config

    ssh -p $ssh_port \
        "${extra_ssh_options[@]}" \
        "$user@$host" \
        "sh -c '\
cd /tmp; \
nohup killall x11vnc > /dev/null 2>&1 &\
'"

    exit_ssh_via_control_sockets_list ./local_port_forwarding_for_vnc.ssh_control_sockets
}

vnc_run_ssvncviewer()
{
    require_var vnc_local_port_start

    require ssvncviewer

    vnc_local_port=${1:-$vnc_local_port_start}
    info "Connecting to 127.0.0.1:$vnc_local_port"
    ssvncviewer -16bpp 127.0.0.1:$vnc_local_port
}

vnc_run_ssvncviewer_viewonly()
{
    require_var vnc_local_port_start

    require ssvncviewer

    vnc_local_port=${1:-$vnc_local_port_start}
    info "Connecting to 127.0.0.1:$vnc_local_port"
    ssvncviewer -16bpp -viewonly 127.0.0.1:$vnc_local_port
}

# echo "yaa-ssh-tricks is a library"
