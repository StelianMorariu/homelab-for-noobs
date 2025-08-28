## Plex LXC with hardware passthrough

## Plex LXC
- use vteck scripts
```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/plex.sh)"
```
- select `advanced settings`
    -  this is required in order to setup a root password and enable ssh
    - ssh will be required when setting up a new server
- the script should also install required video drivers
- you can check IOMMU availability by typing the following command in the container shell:
```
lspci -v | grep -e VGA
```



## Setup a new Plex server


The Plex server needs to be accessed via _localhost_ for the initial setup.

In order to do this you need to  follow the steps from the [official article](https://support.plex.tv/articles/200288586-installation/):

- on your local machine, open a terminal and enter the following command:
```
ssh -L 8888:127.0.0.1:32400 user@ip.address.of.server
```

for example: ssh -L 8888:127.0.0.1:32400 root@192.168.100.230
- with the ssh open, go to [http://127.0.0.1:8888/web](http://127.0.0.1:8888/web)
- this will now let you sign in to plex and set up a new server

- after the new server is created and claimed you can exit ssh
- you can now access Plex using the LXC IP and update configurations as you want


## NFS mount points

- on Proxmox host
```
pct set 200 -mp0 /mnt/pve/nas-ds923-plex-data/media/,mp=/data/media
 ```

 - most likely, the Plex container will not have the correct permissions to access these folders properly
 - you can checl ownership of the mount source by typing the following command in the proxomox host console
 
 ```
 ls -l /mnt/pve/nas-ds923-plex-data/media/
```
This will show you the UID and GUID that have access to the folders.

We now have 2 options: 
- add UID/GID mappings 
- use idmap to map container users

### Add UID/GID Mappings in Container Config
To resolve the permission mismatch, you can try remapping the container to the correct UID (1026) that owns the directories in your mounted share. Here's how to add it:

Open the LXC config file:
```
nano /etc/pve/lxc/200.conf
```

Add or modify the following lines to match the owner of the directory (UID 1026):
```
mp0: /mnt/pve/nas-ds923-plex-data/media/,mp=/data/media,uid=1026,gid=users
```

This tells Proxmox to map the container's user to the host's user 1026, and the container will now have permissions to access the directories.

### Use lxc.idmap to Remap UIDs
If you need to remap the UIDs specifically for this container, you can use the lxc.idmap option in the container configuration file:

Open the container config:
```
nano /etc/pve/lxc/200.conf
```
Add the following lines to map UID 1026 in the container to 1026 on the host:

```
lxc.idmap = u 0 100000 1026
lxc.idmap = g 0 100000 1026
```

This will map the container’s root user to 1026 on the host, which matches the UID of the files.

Restart the container after applying the changes:
```
pct stop 200
pct start 200
```