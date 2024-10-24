# Docker utils


## Add user and groups

```
sudo adduser <new-username>
```

```
sudo groupadd <group-name>
```


```
sudo usermod -aG <group-name> <new-username>
```

Verify:
```
groups <new-username>
```

List UID & GUID

```
id <user-name>
```


sudo groupadd los_muertos_homelab
sudo adduser jimmy
sudo usermod -aG los_muertos_homelab jimmy