#!/bin/bash

dist=`grep PRETTY_NAME /etc/*-release | awk -F '="' '{print $2}'`
OS=$(echo $dist | awk '{print $1;}')
OS1=`cut -d' ' -f1 /etc/redhat-release`

case "$OS" in
  "Fedora")
     ip route add default via 192.168.1.1
esac

if [ "$OS" = "Red Hat" ]  || [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ] || [ "$OS" = "CentOS" ] || [ "$OS1" = "CentOS" ] || [ "$OS" = "Fedora" ]
then
CONF='//var/lib/rioos/gulp/gulpd.conf'
else
  CONF='//var/lib/rioos/rioosgulp/conf/gulpd.conf'
fi
cat >$CONF  <<'EOF'
apiVersion: v1
kind: Config
preferences: {}
assemblyId: "811934182660907008"
EOF

sed -i "s/^[ \t]*assemblyId.*/    assemblyId = \"$ASSEMBLY_ID\"/" $CONF
SERVICE=/etc/systemd/system/rioosgulp.service

case "$OS1" in
   "CentOS")
        sudo service rioosgulp start
          ;;
esac


case "$OS" in
   "Ubuntu")
dist=`grep VERSION_ID /etc/*-release | awk -F '="' '{print $2}'`
v=$(echo $dist | awk -F '"' '{print $1;}')
  case "$v" in
         "14.04")
         stop rioosgulp
         start rioosgulp
          ;;
         "16.04")
cat >$SERVICE  <<'EOF'
[Unit]
Description=gulp Agent
After=network.target

[Service]
ExecStart=/usr/share/rioos/gulp/bin/gulpd --api-server=http://localhost:9636 --leader-elect=false --rioos-api-content-type=application/json --rioconfig /var/lib/rioos/gulp/gulpd.conf
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

          service rioosgulp stop
          service rioosgulp start
         ;;
  esac
HOSTNAME=`hostname`
echo $HOSTNAME

sudo cat >> //etc/hosts <<EOF
127.0.0.1  `hostname` localhost
EOF

   ;;
   "Debian")
	systemctl stop rioosgulp.service
	systemctl start rioosgulp.service
   ;;
   "Fedora")
	sudo systemctl stop rioosgulp.service
	sudo systemctl start rioosgulp.service
  ;;
   "CentOS")
	systemctl stop rioosgulp.service
	systemctl start rioosgulp.service

   ;;
   "CoreOS")
if [ -f /mnt/context.sh ]; then
  . /mnt/context.sh
fi

sudo cat >> //home/core/.ssh/authorized_keys <<EOF
$SSH_PUBLIC_KEY
EOF

sudo -s

sudo cat > //etc/hostname <<EOF
$HOSTNAME
EOF

sudo cat > //etc/hosts <<EOF
127.0.0.1 $HOSTNAME localhost
EOF

sudo cat > //etc/systemd/network/static.network <<EOF
[Match]
Name=ens3

[Network]
Address=$ETH0_IP/27
Gateway=$ETH0_GATEWAY
DNS=8.8.8.8
DNS=8.8.4.4

EOF

	sudo systemctl restart systemd-networkd

	systemctl stop rioosgulp.service
	systemctl start rioosgulp.service
	ip route add default via 192.168.1.1		# Replace with Subnet Gateway IPs
;;
esac
