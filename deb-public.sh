#!/bin/bash

apt install samba samba-common -y
ufw allow 139
ufw allow 445

echo "Please insert shared folder name?"
read fn
mkdir -p /var/$fn
chmod -R 0777 /var/$fn
chown -R nobody:nobody /var/$fn

read -p "Do you want to create authentication for access samba shared folder? (Y / N)" mode

ase "$mode" in
	Y) do
		
	;;	

case "$mode" in
	Y) do
		echo "Please insert nethbios name?"
		read nbm
		echo "Please insert workgroup name?"
		read wg
		mv /etc/samba/smb.conf /etc/samba/smb.conf.ori
		cat > /etc/samba/smb.conf << EOF
		[global]
			workgroup = $wg
			netbios name = $nbm
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

		systemctl restart smbd.service
		ufw allow samba
		testpar
	;;