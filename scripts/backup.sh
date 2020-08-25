#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
  echo "$0 <dest>"
fi

for entry in $(ls .); do
  if [[ -d $entry ]]; then
    mkdir -p /tmp/minecraft-backup/$entry
    cp $entry/world /tmp/minecraft-backup/$entry
    tar -cf $1/world-$entry-$(date +"%m-%d-%y")
    rm -rf /tmp/minecraft-backup/$entry
  fi
done
