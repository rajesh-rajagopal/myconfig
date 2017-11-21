#!/bin/bash

# Install Dependencies.
dir=/var/lib
sudo apt-get -y update
sudo apt-get install -y software-properties-common python-software-properties
mkdir -p /etc/docker/certs.d/registry.megam.io:5000

# Install docker.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker ${USER}

# Start docker
sudo systemctl start docker
sudo systemctl status docker

# Get certificate keys.
sudo wget https://s3.amazonaws.com/rioos/registry/ca.crt
export CA_CRT=$PWD/ca.crt
mv $CA_CRT /etc/docker/certs.d/registry.megam.io:5000

# Login into registry.megam.io.
sudo docker login registry.megam.io:5000 -u rioosadmin -p team4rio

# Pull images from registry.
sudo docker pull registry.megam.io:5000/rioosccmock

# Launch a docker container.
CID=$(sudo docker run -d -it -p 4201:4201 --name=rioosccmock registry.megam.io:5000/rioosccmock)

# Get container IP address.
CIP=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CID)

# Rio/OS Configuration
sed -i 's/\<quiet splash\>//g' /etc/default/grub
sed -i 's/Ubuntu 16.04/Rio\/OS v2/g' /usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth

# Update grub configuration
update-grub

