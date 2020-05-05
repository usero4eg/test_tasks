#! /bin/bash

echo "Show currently timezone"
timedatectl

echo "Set timezone"
timedatectl set-timezone Europe/Moscow

echo "Show currently locales"
locale -a

echo "Set locale"
localectl set-locale LANG=ru_RU.UTF8

echo "Change sshd port"
echo "Port 2498" >> /etc/ssh/ssh_config.d/test_01.config 
echo "PermitRootLogin no" >> /etc/ssh/ssh_config.d/test_01.config

echo "Restart sshd service"
systemctl restart sshd

echo "Add serviceuser account with grants to start/stop/restart services"
useradd --system --shell /bin/bash serviceuser
echo "serviceuser ALL=NOPASSWD:/bin/systemctl" >> /etc/sudoers

echo "Install NGINX server"
apt-get update && apt-get upgrade -y && apt install -y nginx
systemctl enable nginx

echo " Install Monit server"
apt-get install -y monit
systemctl enable monit

echo " Configure Monit server"
echo "set httpd port 2812" >> /etc/monit/monitrc
echo "allow devops:test" >> /etc/monit/monitrc
systemctl restart monit

echo " Configure NGINX server"
echo \
    'server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://localhost:2812;
            proxy_set_header Host $host;
        }
    }' > /etc/nginx/sites-available/monit
ln -s /etc/nginx/sites-available/monit /etc/nginx/sites-enabled/monit
nginx -s reload