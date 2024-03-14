#!/bin/bash
clear

# 1. ایجاد دایرکتوری "tbf" در /var
sudo mkdir -p /var/tbf

# 2. ایجاد فایل .env در دایرکتوری tbf
sudo touch /var/tbf/.env

# 3. قرار دادن مقادیر در فایل .env
echo "PORT_SSH=22" | sudo tee -a /var/tbf/.env
echo "PORT_DROPBEAR=2083" | sudo tee -a /var/tbf/.env
echo "PORT_UDPGW=7302" | sudo tee -a /var/tbf/.env
echo "PORT_PANEL=8081" | sudo tee -a /var/tbf/.env
echo "TRAFFIC_BASE=12" | sudo tee -a /var/tbf/.env

# 4. دسترسی خواندن و نوشتن به فایل .env
sudo chmod 644 /var/tbf/.env
  
udpport=7302
echo -e "\nPlease input UDPGW Port ."
printf "Default Port is \e[33m${udpport}\e[0m, let it blank to use this Port: "
read udpport

sed -i "s/PORT_UDPGW=.*/PORT_UDPGW=$udpport/g" /var/tbf/.env
apt update -y
apt install git cmake -y
git clone https://github.com/ambrop72/badvpn.git /root/badvpn
mkdir /root/badvpn/badvpn-build
cd  /root/badvpn/badvpn-build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 &
wait
make &
wait
cp udpgw/badvpn-udpgw /usr/local/bin
cat >  /etc/systemd/system/videocall.service << ENDOFFILE
[Unit]
Description=UDP forwarding for badvpn-tun2socks
After=nss-lookup.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --loglevel none --listen-addr 127.0.0.1:$udpport --max-clients 999
User=videocall

[Install]
WantedBy=multi-user.target
ENDOFFILE
useradd -m videocall
systemctl enable videocall
systemctl start videocall
sed -i "s/PORT_UDPGW=.*/PORT_UDPGW=$udpport/g" /var/tbf/.env
