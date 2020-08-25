#!/usr/bin/env bash
#################
# run.sh vanilla
# NOTE:use systemd instead of this
#################
# These flags will cause startup of the server to very expensive
# but in turn the TPS will be much higher
# this is configured for 20 or less people.
# if you're allocating more than 12GB refer to mcflags.emc.gs
FLAGS="
-XX:+UseG1GC
-XX:+ParallelRefProcEnabled
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+DisableExplicitGC
-XX:+AlwaysPreTouch
-XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40
-XX:G1HeapRegionSize=8M
-XX:G1ReservePercent=20
-XX:G1HeapWastePercent=5
-XX:G1MixedGCCountTarget=4
-XX:InitiatingHeapOccupancyPercent=15
-XX:G1MixedGCLiveThresholdPercent=90
-XX:G1RSetUpdatingPauseTimePercent=5
-XX:SurvivorRatio=32
-XX:+PerfDisableSharedMem
-XX:MaxTenuringThreshold=1
-Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

instance_dir="/opt/minecraft/instance/"
BIN="$1/server.jar"

java -server \
     -Xms4G -Xmx6G \
     $FLAGS -jar "$instance_dir/$BIN" --noconsole --nogui

