#!/bin/bash
#run as admin in deployment/pliant

echo "Stopping pliant-proxy..."
docker stop pliant-proxy

echo "Getting docker compose..."
sudo apt-get install docker-compose

echo "cloning nginx-certbot folder..."
git clone https://github.com/wmnnd/nginx-certbot.git

cd nginx-certbot

echo "Writing default configuration settings to /data/nginx/app.conf..."
echo 'server { listen 80; server_name example.org; server_tokens off; location /.well-known/acme-challenge/ { root /var/www/certbot; } location / { return 301 https://$host$request_uri; } } server { listen 443 ssl; server_name example.org; server_tokens off; ssl_certificate /etc/letsencrypt/live/example.org/fullchain.pem; ssl_certificate_key /etc/letsencrypt/live/example.org/privkey.pem; include /etc/letsencrypt/options-ssl-nginx.conf; ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; location / { proxy_pass http://pliant-front; proxy_set_header Host $http_host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; } }' > ./data/nginx/app.conf

echo "Writing $1 instead of example.org to app.conf file..."
sed -i 's/example.org/'domain-name.pliant.io'/g' ./data/nginx/app.conf

echo "connecting nginxcertbot_nginx_1 to pliant-net..."
docker network connect pliant-net nginxcertbot_nginx_1

echo "enabling command line args in init-letsencrypt.sh..."
sed -i 's/example.org/\$1/g' ./init-letsencrypt.sh
sed -i 's/example.com/\$1/g' ./init-letsencrypt.sh


echo "Allowing execution of init-letsecrypt.sh..."
chmod +x ./init-letsencrypt.sh

echo "Correcting URLLIB version..."
pip uninstall urllib3;pip install urllib3==1.22

echo "running init-letscrypt to with domain name $1 ..."
./init-letsencrypt.sh $1

















