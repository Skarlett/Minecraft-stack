# Minecraft-stack

My personal Minecraft stack setup


+ Mapcrafter
+ Nginx
+ Systemd

after properly setting up everything - you should be able to control the server with systemd, which should allow for scheduled tasks.

After the implementation you should be able to run scripts like
`/opt/minecraft/mapcraft.sh`
which will then allow you to see the changes from the webserver.

You may also hook tasks up to cron
```

crontab -e
* * */4  *  * systemctl restart minecraft@vanilla
* 15 12 30 *  DHOOK=discord_webhook DOMAIN="machines IP/domain" /opt/minecraft/mapcraft.sh
```
