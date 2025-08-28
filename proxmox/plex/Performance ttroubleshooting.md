# Troubleshooting


## Frequent buffering on direct play

- change NAS to NFS 4.1
- check Proxmox mount options
  ```
  mount | grep nfs
```
or

```
nano /etc/pve/storage.cfg
```

- remount to renegotiate rsizes
```
umount /mnt/pve/my-nfs-storage
```

```
mount /mnt/pve/my-nfs-storage
```