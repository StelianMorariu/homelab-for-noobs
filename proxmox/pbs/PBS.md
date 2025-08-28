# Proxmox Backup Server

https://www.youtube.com/watch?v=m4xEvN2wkj0&ab_channel=TechMeOut

1. Download PBS iso installer
2. Create VM on Sunology
3. Go through initial PBS setup
4. Post install steps

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pbs-install.sh)"
```

```
apt install qemu-guest-agent
```

restart VM
5. Create new mount folder
   
```
mkdir /mnt/synology
chown backup:backup /mnt/synology
chmod 775 /mnt/synology
```
6. Mount NFS folder with fstab
```
echo "192.168.100.52:/volume1/ProxmoxBackupServer /mnt/synology nfs vers=4,nouser,atime,auto,retrans=2,rw,dev,exec 0 0" >> /etc/fstab 
mount -a
systemctl daemon-reload
chmod 775 /mnt/synology
```

7. Create PBS user