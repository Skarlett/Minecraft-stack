#!/usr/bin/env bash
# iterates over /opt/minecraft/
# and uses mapcrafter on all servers with the config file
#####
set -e

WORLD=world-$(date +"%m-%d-%y")
WORKERS=4
HOOK=$DHOOK
MAPHOME="/var/www/html"
DOMAIN="$DOMAIN:-$IP}"

TIMESTAMP=$(date +'%s')

time_taken() {
  python -c "import time; import datetime; print(str(datetime.timedelta(seconds=time.time() - $TIMESTAMP)))"
}

discord(){
  if [[ -z "${HOOK}" ]]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" $HOOK
  fi
}

discord "⚙️️ Reimaging Server ⚙️"

for entry in $(ls /opt/minecraft); do
  if [[ -d $entry ]] && [[ -e $entry/mapcrafter.cfg ]]; then
    systemctl stop minecraft@$entry
    mapcrafter -b -j $WORKERS -c $entry/mapcrafter.cfg
    systemctl start minecraft@$entry

    mv $entry/output $MAPHOME/$entry/$WORLD

    if [[ -e $MAPHOME/$entry/latest ]]; then
       rm -rf $MAPHOME/$entry/latest
    fi
    ln -s $MAPHOME/$entry/$WORLD $MAPHOME/$entry/latest
  fi

done

discord "Done imaging [$(time_taken)] http://$DOMAIN/"
