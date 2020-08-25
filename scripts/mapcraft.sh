#!/usr/bin/env bash
# iterates over /opt/minecraft/
# and uses mapcrafter on all servers with the config file
#####
set -e

WORLD=world-$(date +"%m-%d-%y")
WORKERS=4

#HOOK="https://discord.com/api/webhooks/744631594702209064/7oWEdb-TQj0Vm_2CUk7T68dNeY66fGY0eLzHkCj1Ki80lAxpv46tqcVZXVp1YWtH-PmL"

MAPHOME="/var/www/default/public/minecraft/"
DOMAIN="159.89.82.85"

TIMESTAMP=$(date +'%s')

time_taken() {
  python -c "import time; import datetime; print(str(datetime.timedelta(seconds=time.time() - $TIMESTAMP)))"
}

discord(){
  curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" $HOOK
}

discord "⚙️️ Reimaging Server ⚙️"

for entry in $(ls .); do
  if [[ -d $entry ]] && [[ -e $entry/mapcrafter.cfg ]]; then
    systemctl stop minecraft@$entry
    mapcrafter -b -j $WORKERS -c $entry/mapcrafter.cfg
    systemctl start minecraft@$entry

    mv $entry/output $MAPHOME/$entry/$WORLD

    if [[ -e $MAPHOME/$entry/latest ]]; then
       rm -rf $MAPHOME/$entry/latest
    fi
    #     /var/www/html/vanilla/latest /var/www/html/vanilla/world-12-12-12
    ln -s $MAPHOME/$entry/$WORLD $MAPHOME/$entry/latest
  fi

done

discord "Done imaging [$(time_taken)] http://$DOMAIN/"

