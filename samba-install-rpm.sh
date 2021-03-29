#!/bin/bash

dnf install -y samba samba-client samba-common
systemctl start smb
systemctl enable smb
firewall-cmd --permanent --add-service=samba --zone=public
firewall-cmd --reload

echo "Please insert shared folder name?"
read fn
mkdir -p /var/$fn
chmod -R 0777 /var/$fn
chown -R nobody:nobody /var/$fn
chcon -t samba_share_t /var/$fn

mv /etc/samba/smb.conf /etc/samba/smb.conf.ori

echo "Please insert nethbios name?"
read nbn
echo "Please insert workgroup name? (type WORKGROUP for default)"
read wg

read -p "Do you want to create authentication for access samba shared folder? (y / n)" mode

case "$mode" in
	y) do
		echo "Please insert username?"
		read $un
		adduser -M $un -s /sbin/nologin
		echo "Please insert password?"
		read $pass
		smbpasswd -a $un
				
		cat > /etc/samba/smb.conf << EOF
		[global]
			workgroup = $wg
			netbios name = $nbn
			security = user
			
		[$fn]
			path = /var/$fn
			browsable =yes
			writable = yes
			guest ok = no
			read only = no
		EOF
	;;

case "$mode" in
	n) do
		cat > /etc/samba/smb.conf << EOF
		[global]
			workgroup = $wg
			netbios name = $nbn
			security = user
			map to guest = Bad User

		[$fn]
			comment = Anonymous File Server Share
			path = /var/$fn
			browsable =yes
			writable = yes
			guest ok = yes
			read only = no
			force user = nobody
		EOF
	;;
	
systemctl restart smb.service
systemctl restart nmb.service
testparm