#!/bin/bash

echo "Started Shell script" > /target//var/lib/rioos
dir=/target/var/lib

# Rio/OS Configuration
sed -i 's/\<quiet splash\>//g' /target/etc/default/grub
sed -i 's/Ubuntu 16.04/Rio\/OS/g' /target/usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth
sed -i '/LXD_IPV4_ADDR=""/c\LXD_IPV4_ADDR="10.0.8.1"' /target/etc/default/lxd-bridge
sed -i '/LXD_IPV4_NETMASK=""/c\LXD_IPV4_NETMASK="255.255.255.0"' /target/etc/default/lxd-bridge
sed -i '/LXD_IPV4_NETWORK=""/c\LXD_IPV4_NETWORK="10.0.8.0/24"' /target/etc/default/lxd-bridge
sed -i '/LXD_IPV4_DHCP_RANGE=""/c\LXD_IPV4_DHCP_RANGE="10.0.8.2,10.0.8.254"' /target/etc/default/lxd-bridge
sed -i '/LXD_IPV4_DHCP_MAX=""/c\LXD_IPV4_DHCP_MAX="250"' /target/etc/default/lxd-bridge

#Install Packages
echo "Run LXD installation" >> /target//var/lib/rioos
#apt install -y lxd lxd-client >> /target//var/lib/rioos
#apt install -y -t xenial-backports lxd lxd-client >> /target//var/lib/rioos
#apt install -y snapd >> /target//var/lib/rioos
snap install lxd >> /target//var/lib/rioos
lxd init --auto >> /target//var/lib/rioos

#Import lxd images into server
echo "Import WordPress Image in LXD" >> /target//var/lib/rioos
lxc image import $dir/wordpress.tar.gz --alias wordpress >> /target//var/lib/rioos

#Launch a container named "wp" using "Wordpress" Images
echo "Launch a Container" >> /target//var/lib/rioos
lxc launch wordpress wp >> /target//var/lib/rioos
echo "Finished LXD installation" >> /target//var/lib/rioos
