#!/bin/bash

# Install Dependencies.
echo "Started Shell script" > /var/lib/rioos
dir=/var/lib
sudo apt-get install wget curl
sudo mkdir -p /var/lib/rioos/containers/certs
sudo mkdir -p /var/lib/rioos/containers/auth

# Install docker.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker ${USER}

# Start docker
sudo systemctl start docker
sudo systemctl status docker

# Create registry.megam.io keyfile.
openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout /var/lib/rioos/containers/certs/registry.megam.io.key \
  -x509 -days 365 -out /var/lib/rioos/containers/certs/registry.megam.io.crt \
  -subj '/CN=www.megam.io/O=Megam Systems/C=AU'

# Login into registry.megam.io.
docker login registry.megam.io:5000 -u rioosadmin -p team4rio

# Pull images from registry.
docker pull registry.megam.io:5000/rioosccmock

# Launch a container named "wp" using "Wordpress" Images
echo "Launch a Container" >> /var/lib/rioos
CID=$(sudo docker run -d -it -p 4201:4201 --name=rioosccmock registry.megam.io:5000/rioosccmock)
echo "Finished LXD installation" >> /var/lib/rioos

# Get container IP address.
CIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CID)

# Rio/OS Configuration
sed -i 's/\<quiet splash\>//g' /etc/default/grub
sed -i 's/Ubuntu 16.04/Rio\/OS/g' /usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth

# Update grub configuration
update-grub
