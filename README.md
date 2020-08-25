# Minecraft-stack

My personal Minecraft stack setup


+ Mapcrafter
+ Nginx
+ Systemd
+ Discord Watcher - quick program to allow stop/start/restart of minecraft from discord
+ rcon

after properly setting up everything - you should be able to control the server with systemd, which should allow for scheduled tasks.

After the implementation you should be able to run scripts like
`/opt/minecraft/mapcraft.sh`
which will then allow you to see the changes from the webserver.

You may also hook tasks up to cron
```
crontab -e
* * */4  *  * systemctl restart minecraft@vanilla
* 15 12 30 *  DHOOK="discord_webhook" /opt/minecraft/mapcraft.sh
```
