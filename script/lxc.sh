#!/bin/bash

echo "Started Shell script" > /var/lib/rioos
dir=/var/lib

# Rio/OS Configuration
sed -i 's/\<quiet splash\>//g' /etc/default/grub
sed -i 's/Ubuntu 16.04/Rio\/OS/g' /usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth
sed -i '/LXD_IPV4_ADDR=""/c\LXD_IPV4_ADDR="10.0.8.1"' /etc/default/lxd-bridge
sed -i '/LXD_IPV4_NETMASK=""/c\LXD_IPV4_NETMASK="255.255.255.0"' /etc/default/lxd-bridge
sed -i '/LXD_IPV4_NETWORK=""/c\LXD_IPV4_NETWORK="10.0.8.0/24"' /etc/default/lxd-bridge
sed -i '/LXD_IPV4_DHCP_RANGE=""/c\LXD_IPV4_DHCP_RANGE="10.0.8.2,10.0.8.254"' /etc/default/lxd-bridge
sed -i '/LXD_IPV4_DHCP_MAX=""/c\LXD_IPV4_DHCP_MAX="250"' /etc/default/lxd-bridge

#Install Packages
echo "Run LXD installation" >> /var/lib/rioos
#apt install -y lxd lxd-client >> /var/lib/rioos
#apt install -y -t xenial-backports lxd lxd-client >> /target//var/lib/rioos
#apt install -y snapd >> /var/lib/rioos
snap install lxd >> /var/lib/rioos
lxd init --auto >> /var/lib/rioos

#Import lxd images into server
echo "Import WordPress Image in LXD" >> /var/lib/rioos
lxc image import $dir/wordpress.tar.gz --alias wordpress >> /var/lib/rioos

#Launch a container named "wp" using "Wordpress" Images
echo "Launch a Container" >> /var/lib/rioos
lxc launch wordpress wp >> /var/lib/rioos
echo "Finished LXD installation" >> /var/lib/rioos
