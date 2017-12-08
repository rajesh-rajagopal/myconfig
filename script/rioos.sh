#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
cert_dir=/etc/docker/certs.d/registry.megam.io:5000
DOCKER_IMG_NAME=('registry.megam.io:5000/rioosuimock' 'registry.megam.io:5000/rioosccmock')

# Install Dependencies.
function install_dependencies {
  echo -e "${GREEN}Start Installing Dependencies${NC}"
  mkdir -p $cert_dir
  sudo apt-get -y update
  sudo apt-get install -y software-properties-common python-software-properties
}

function install_docker {
  docker_version=$(docker -v)

  if ! which docker > /dev/null; then
    echo -e "${GREEN}Start installing docker-engine${NC}"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo usermod -aG docker ${USER}

    # Start docker
    sudo systemctl start docker
    sudo systemctl status --no-pager docker
  else
    echo -e "${GREEN}Docker already installed${NC}"
    # check status of docker-engine
    sudo systemctl status --no-pager docker
  fi
}

function get_certificate {
  # Get certificate keys.
  \which wget >/dev/null 2>&1 || echo "${RED}Could not find 'wget' command, make sure it's available first before continuing installation${NC}"
  echo team4rio > $PWD/my_password.txt
  if [ -f "$cert_dir/ca.crt" ]
  then
    echo -e "${GREEN}Certificate file already exists${NC}"
    login_registry
  else
    sudo wget https://s3.amazonaws.com/rioos/registry/ca.crt
    export CA_CRT=$PWD/ca.crt
    mv $CA_CRT /etc/docker/certs.d/registry.megam.io:5000
    login_registry
  fi
}

function login_registry {
  # Login into registry.megam.iod04052a7c044
  result=$(cat $PWD/my_password.txt | sudo docker login registry.megam.io:5000 -u rioosadmin --password-stdin)

  if [ "$result" = "Login Succeeded" ]
  then
    sudo rm -f $PWD/my_password.txt
    echo -e "${GREEN}Successfully login into Rio/OS private registry${NC}"
    pull_images
    create_containers
  else
    echo -e "${RED}Error in Rio/OS private registry login${NC}"
  fi
}

function pull_images {
  sudo docker pull registry.megam.io:5000/rioosuimock
  sudo docker pull registry.megam.io:5000/rioosccmock
}

function create_containers {
  # Launch a docker container
  rioos_cc=$(sudo docker run -d -it -p 4201:4201 --name=rioosccmock --restart always registry.megam.io:5000/rioosccmock)
  rioos_ui=$(sudo docker run -d -it -p 4200:4200 --name=rioosuimock --restart always registry.megam.io:5000/rioosuimock)

  echo -e "${GREEN}Container created. Rio/OS commandcenter container_id is $rioos_cc ${NC}"
  echo -e "${GREEN}Container created. Rio/OS UI container_id is $rioos_ui ${NC}"

  # Get container IPaddress
  rioos_cc_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $rioos_cc)
  rioos_ui_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $rioos_ui)

  echo -e "${GREEN}Rio/OS commandcenter container IPaddress $rioos_cc_ip ${NC}"
  echo -e "${GREEN}Rio/OS UI container IPaddress $rioos_ui_ip ${NC}"
}

function modify_grubconfig {
  # Rio/OS Configuration
  sed -i 's/GRUB_HIDDEN_TIMEOUT=0/# GRUB_HIDDEN_TIMEOUT=0/g' /etc/default/grub
  sed -i 's/\<quiet splash\>//g' /etc/default/grub
  sed -i.bak 's/^\(GRUB_DISTRIBUTOR=\).*/\1"Rio\/OS v2"/' /etc/default/grub
  sed -i 's/Ubuntu 16.04/Rio\/OS v2/g' /usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth

  # Update grub configuration
  update-grub
  reboot
}

modify_grubconfig
install_dependencies
install_docker
get_certificate

