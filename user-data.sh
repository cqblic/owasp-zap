#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#sudo apt update && sudo apt upgrade -y
#sudo apt install xorg openbox xserver-xorg-core xserver-xorg -y
#sudo apt install ubuntu-desktop -y
#sudo apt install xrdp -y
#sudo useradd -m carlos --shell /bin/bash
#sudo ufw allow 3389/tcp
#sudo ufw reload
#sudo apt install pipewire pipewire-audio pipewire-pulse wireplumber

sudo apt-get update
#sudo DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4
#sudo apt install xfce4-session
sudo apt install ubuntu-desktop -y
sudo apt install xrdp -y
sudo adduser xrdp ssl-cert
echo xfce4-session >~/.xsession

#sudo apt -y update
#sudo apt install -y python3-dev python3-pip 
#sudo apt install -y openjdk-8-jdk

# install zap proxy 
#cd /home/azureuser
#wget https://github.com/zaproxy/zaproxy/releases/download/v2.16.1/ZAP_2_16_1_unix.sh
