services:
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 6881:6881
      - 6881:6881/udp
      - 8888:8888/tcp # HTTP proxy
      - 5055:5055 # Overseerr
    volumes:
      - /var/lib/docker/volumes/gluetun:/gluetun
    environment:
      - PUID=${OVERSEER_UID:?error} #CHANGE_TO_YOUR_UID
      - PGID=${OVERSEER_GUID:?error} #CHANGE_TO_YOUR_GID
      - TZ=${OVERSEER_TZ:?error} #CHANGE_TO_YOUR_TZ
      - VPN_SERVICE_PROVIDER=${OVERSEER_VPN_PROVIDER:?error}
      - VPN_TYPE=${OVERSEER_VPN_TYPE:?error} 
      - OPENVPN_USER=${OVERSEER_VPN_USER}
      - OPENVPN_PASSWORD=${OVERSEER_VPN_PASS}
      - SERVER_COUNTRIES=${OVERSEER_VPN_COUNTRIES:?error}
      - HTTPPROXY=off #change to on if you wish to enable
      - SHADOWSOCKS=off #change to on if you wish to enable
      - FIREWALL_OUTBOUND_SUBNETS=172.30.0.0/16,192.168.100.0/24 #change this in line with your subnet see note on guide.
#      - FIREWALL_VPN_INPUT_PORTS=12345 #uncomment this line and change the port as per the note on the guide
    network_mode: vpnBridge
    security_opt:
      - no-new-privileges:true
    restart: always
     

  overseerr:
    image: lscr.io/linuxserver/overseerr:latest
    container_name: overseerr
    network_mode: "service:gluetun"
    environment:
      - PUID=${OVERSEER_UID:?error}
      - PGID=${OVERSEER_GUID:?error}
      - TZ=${OVERSEER_TZ:?error}
      - UMASK=022
    volumes:
      - /var/lib/docker/volumes/overseerr/config:/config
    restart: unless-stopped  






OVERSEER_UID=1027
OVERSEER_GUID=100
OVERSEER_TZ=Europe/London
OVERSEER_VPN_PROVIDER=nordvpn
OVERSEER_VPN_TYPE=openvpn
OVERSEER_VPN_USER=xzcpSaHozeQpRTMmNw38qzx2
OVERSEER_VPN_PASS=D7uD4eTzeu5DuH6Rr6EBnEfc
OVERSEER_VPN_COUNTRIES=United Kingdom
OVERSEER_VPN_SUBNETS=172.30.0.0/16,192.168.100.0/24


/var/lib/docker/volumes/grafana-test-stack_grafana_data/_data

```
scp /Users/stelian/Downloads/config.zip root@192.168.100.62:/var/lib/docker/volumes/overseer/config/
```



## Gluetun on Portainer

- on the Proxmomx host node, edit lxc to allow access th /dev/net/tun

```
nano /etc/pve/lxc/<container_id>.conf
```

then add the following lines:
```
lxc.cgroup2.devices.allow = c 10:200 rwm
lxc.mount.entry = /dev/net/tun dev/net/tun none bind,optional,create=file
```

save, exit and start the container

- in Portainer
   - create new network that will be used by `gluetun`



Portainer is kind of shit with gluetun, so docker will fail to start

```
sudo systemctl stop docker
```

```
sudo rm -rf /var/lib/docker/network
```

```
sudo systemctl start docker
```

