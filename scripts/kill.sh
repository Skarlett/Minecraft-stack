#!/usr/bin/env bash
#################
# rcon_kill.sh vanilla

instance_dir="/opt/minecraft/instance"
input="$instance_dir/$1"

function prop_search() { cat $2/server.properties | grep $1 | cut -d "=" -f 2; }

function rcon_enabled() { prop_search "rcon-enable" $input; }
function rcon_port() { prop_search "rcon.port" $input; }
function rcon_passwd() { prop_search "rcon.password" $input; }

if [[ $(rcon_enabled) == "false" ]]; then
  echo "rcon is not enabled"
  exit 1
fi

/usr/local/bin/mcrcon -H "127.0.0.1" -P "$(rcon_port)" -p "$(rcon_passwd)" -c "stop"
