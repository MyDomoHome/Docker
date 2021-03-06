#/bin/bash
# pour installer centos 7.2 ==> Adding initcall_blacklist=clocksource_done_booting to GRUB_CMDLINE_LINUX in /etc/default/grub and then grub2-mkconfig -o /etc/grub2.cfg fix this bug (https://bugs.centos.org/view.php?id=9860)

#MONTAGE des disques
mkdir /mnt/3TO
mkdir /mnt/2TO
mkdir /mnt/1TO
cp /etc/fstab /etc/fstab.bak
echo 'LABEL=3TO /mnt/3TO auto nosuid,nodev,nofail 0 0' >> /etc/fstab 
echo 'LABEL=2TO /mnt/2TO auto nosuid,nodev,nofail 0 0' >> /etc/fstab
echo 'LABEL=1TO /mnt/1TO auto nosuid,nodev,nofail 0 0' >> /etc/fstab


#paramétrage du bridge réseau
cat << 'EOF' >> /etc/sysconfig/network-scripts/ifcfg-br0
TYPE=Bridge
BOOTPROTO=none
DEVICE=br0
ONBOOT=yes
IPADDR=192.168.10.250
NETMASK=255.255.255.0
GATEWAY=192.168.10.254
DNS1=8.8.8.8
EOF

cat /etc/sysconfig/network-scripts/ifcfg-enp2s0
#mv /etc/sysconfig/network-scripts/ifcfg-enp2s0 /etc/sysconfig/network-scripts/ifcfg-enp2s0.bak
cat << 'EOF' >> /etc/sysconfig/network-scripts/ifcfg-enp2s0
HWADDR=E8:39:35:EE:1E:9B
TYPE=Ethernet
NAME="eth0"
UUID=f27b0043-59e5-4c0e-b1b8-387634e21181
ONBOOT=yes
BRIDGE=br0
EOF

#desactivation de la securité selinux pour kvm
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#DOCKER
yum update -y
#reboot
yum update
curl -fsSL https://get.docker.com/ | sh
systemctl enable docker.service
systemctl start docker.service
yum install epel-release -y
yum install -y python-pip -y
pip install docker-compose
yum upgrade python* -y
pip install --upgrade backports.ssl_match_hostname
#docker-compose up
usermod -aG docker zaraki

docker run --restart=always --name Samba -d -p 137:137 -p 139:139 -p 445:445 -v /mnt:/mnt -d dperson/samba -n -s "public;/mnt;yes;no;yes" -w "<workgroup>"
docker run --restart=always --name MySQL -p 3306:3306 -e MYSQL_ROOT_PASSWORD=RebOOt007 -v /mnt/3TO/DockerData/MySQL/config:/etc/mysql/conf.d -v /mnt/3TO/DockerData/MySQL/Data:/var/lib/mysql -d mysql
docker run --restart=always --name Transmission -p 12345:12345 -p 12345:12345/udp -p 9091:9091 -e ADMIN_PASS=RebOOt007 -v /mnt/1TO/Download:/var/lib/transmission-daemon/downloads -d zaraki673/docker-transmission
docker run --restart=always --name SickRage -p 8081:8081 -h SickRage -v /mnt/3TO/DockerData/SickRage:/config -v /mnt/1TO/Download:/downloads -v /mnt/1TO/Multimedia/SeriesTV:/tv -v /etc/localtime:/etc/localtime:ro -d sickrage/sickrage
#docker run --restart=always -d --name tvheadend --privileged=true -v /mnt/3TO/DockerData/tvheadend/config:/config -v /mnt/3TO/DockerData/tvheadend/recordings:/recordings -v /etc/localtime:/etc/localtime:ro -p 9981:9981 -p 9982:9982 -p 5500:5500 tobbenb/tvheadend-unstable
#docker run --restart=always -d --name="Zoneminder-1.29" --privileged=true -v /mnt/3TO/DockerData/ZM/config:/config:rw -v /etc/localtime:/etc/localtime:ro -p 8082:80 aptalca/zoneminder-1.29
#docker run --restart=always -d -p 8080:8080 --name=Domoticz -v /mnt/3TO/DockerData/Domoticz/config:/config -v /etc/localtime:/etc/localtime:ro --device=<device_id> sdesbure/domoticz

##docker run -v /mnt/3TO/DockerData/OpenVPN:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://vpn.mydomohome.eu
##docker run -v /mnt/3TO/DockerData/OpenVPN:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
#docker run -v /mnt/3TO/DockerData/OpenVPN:/etc/openvpn -d -p 1194:1194/udp --privileged kylemanna/openvpn
##docker run -v /mnt/3TO/DockerData/OpenVPN:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full Kevin nopass
##docker run -v /mnt/3TO/DockerData/OpenVPN:/etc/openvpn --rm -it kylemanna/openvpn ovpn_getclient Kevin > /mnt/3TO/Kevin.ovpn

#KVM-QEMU
yum -y install qemu-kvm libvirt bridge-utils
sed -i 's/#LIBVIRTD_ARGS/LIBVIRTD_ARGS/g' /etc/sysconfig/libvirtd
sed -i 's/#listen_tls/listen_tls/g' /etc/libvirt/libvirtd.conf
sed -i 's/#listen_tcp/listen_tcp/g' /etc/libvirt/libvirtd.conf
sed -i 's/#auth_tcp/auth_tcp/g' /etc/libvirt/libvirtd.conf
sed -i 's/#vnc_listen/vnc_listen/g' /etc/libvirt/qemu.conf		


#SSH
sed -i 's/#PermitRootLogin yes/PermitRootLogin no\nAllowUsers zaraki/g' /etc/ssh/sshd_config




