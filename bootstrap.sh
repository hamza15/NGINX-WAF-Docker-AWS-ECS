#!/bin/bash
set -x
echo BEGIN
apt-get update && \
apt-get install -y \
        python \
        python-pip \
        python-setuptools \
        wget \
        nano \
        elinks\
        less \
        && pip --no-cache-dir install --upgrade awscli \
    && apt-get clean

#Create directory for your NGINX-PLUS repo & cert keys.
mkdir /etc/ssl/nginx
cd /etc/ssl/nginx

#ASSUMING YOUR REPO AND CERT KEY ARE IN AN AWS S3 Bucket. Also assumes your container's host will have access to S3 via IAM roles.
#The following block closely follows NGINX's official guide for installing NGINX PLUS on Debian and Ubuntu. https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-plus/#install_debian_ubuntu
aws s3 cp s3://path/to/your/nginx-repo.key /etc/ssl/nginx/nginx-repo.key
aws s3 cp s3://path/to/your/nginx-repo.crt /etc/ssl/nginx/nginx-repo.crt

#Download signing key and add it.
wget https://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key

#Install the apt-utils package and the NGINX Plus repository.
apt-get install -y apt-transport-https lsb-release ca-certificates
printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list

#Download the 90nginx file to /etc/apt/apt.conf.d.
wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx

#Update the repo
apt-get update

#Install nginx-plus
apt-get install -y nginx-plus

#Install module security
apt-get install -y nginx-plus-module-modsecurity

#Dowload OWASP Detection rules for nginx plus modsecurity.
wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.2.tar.gz
tar -xzvf v3.0.2.tar.gz
mv owasp-modsecurity-crs-3.0.2 /usr/local
cd /usr/local/owasp-modsecurity-crs-3.0.2

#Copy example file to a config file that you can use for security rules.
cp crs-setup.conf.example crs-setup.conf

#Remove pre-existing config files.
rm /etc/nginx/modsec/main.conf -rf
rm /etc/nginx/modsec/modsecurity.conf -rf
rm /etc/nginx/nginx.conf -rf
rm /etc/nginx/conf.d/default.conf -rf

#Copy your own config files from AWS S3 bucket assuming your container's host has access to AWS S3 via IAM roles.
aws s3 cp s3://path/to/your/main.conf /etc/nginx/modsec/main.conf
aws s3 cp s3://path/to/your/modsecurity.conf /etc/nginx/modsec/modsecurity.conf
aws s3 cp s3://path/to/your/nginx.conf /etc/nginx/nginx.conf
aws s3 cp s3://path/to/your/cert/ServerCert.pem /etc/nginx/ssl/ServerCert.pem
aws s3 cp s3://path/to/your/allowed/internal_ips.conf /etc/nginx/internal_ips.conf

#Create directory for dhparams and public key infrastructure (pki)
mkdir /etc/pki/nginx
chmod 666 /etc/pki/*
openssl dhparam -out /etc/pki/nginx/dhparams.pem 2048

#Start nginx service
service nginx start

#start nginx at boot
update-rc.d nginx defaults


