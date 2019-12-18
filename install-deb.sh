#!/usr/bin/env bash
set -e

# Alrighty lets start setting up minecraft
# with systemd support

#gets the latest server download link
server_download=$(curl https://www.minecraft.net/en-us/download/server/ 2> /dev/null | grep -E "server.jar" | cut -d "\"" -f 2)
if [[ -z "${server_download}" ]]; then
  
  adduser --system --shell /bin/bash --home /opt/minecraft --group minecraft
  
  mkdir -p /opt/minecraft/systemd
  chown -U root -R /opt/minecraft/systemd

  mv ./minecraft@.service /opt/minecraft/systemd
  ln -s /etc/systemd/system/minecraft@.service /opt/minecraft/systemd/minecraft@.service
  
  mkdir -p /opt/minecraft/vanilla
  curl "${server_download}" 2>/dev/null >/opt/minecraft/vanilla/minecraft_server.jar
  echo "eula=true" > /opt/minecraft/vanilla/eula.txt
  
  # Move and link up mapcrafter config
  mv ./mapcrafter.cfg /opt/minecraft
  ln -s /opt/minecraft/mapcrafter.cfg vanilla/mapcrafter.cfg
  
  mv ./mapcraft.sh /opt/minecraft
  
  # Alright, lets spin up minecraft and wait for a little.
  echo "Spinning up minecraft server for intregity check"
  systemctl start minecraft@vanilla
  sleep 360
  systemctl stop minecraft@vanilla
  systemctl enable minecraft@vanilla
  echo "Minecraft is successfully tied into systemd. use systemctl stop minecraft@vanilla"
else
  echo "Couldn't extract the latest minecraft server download"
  exit 1
fi

# Build mapcrafter

apt update

apt install nginx-light git libpng-dev libjpeg-dev libboost-iostreams-dev \
libboost-system-dev libboost-filesystem-dev libboost-program-options-dev \
build-essential cmake -y

git clone https://github.com/mapcrafter/mapcrafter.git --branch world113
cd mapcrafter
cmake .
make

# Install >:D

make install

cd ..
rm -rf mapcrafter

# Setup nginx setup

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
mv ./nginx/default /etc/nginx/sites-available/default
systemctl restart nginx

# Time to run mapcraft for the first time
if [[ -e /var/www/html ]]; then
  rm -rf /var/www/html/*
fi
mkdir -p /var/www/html/vanilla

mapcrafter -j 4 -c /opt/minecraft/vanilla/mapcrafter.cfg

mv /opt/minecraft/vanilla/output /var/www/html/vanilla/world-$(date +"%m-%d-%y")
ln -s /var/www/html/vanilla/world-$(date +"%m-%d-%y") /var/www/html/vanilla/latest

echo "Checking nginx"
curl http://127.0.0.1/vanilla/latest 2>@1 /dev/null

echo "assuming ubuntu firewall is installed

if [[ -z "$(whereis ufw)" ]]; then
  echo "popping ports 80 and 25565 open"
  ufw allow 80 25565
fi

echo "Starting services"

systemctl enable nginx
systemctl start minecraft@vanilla
