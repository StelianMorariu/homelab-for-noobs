# Homepage

## Install Homepage 

This is available as an LXC but it's a lot easier to manage with Docker

- go to Portainer and create directories for config and images

```
services:
  dockerproxy:
   image: ghcr.io/tecnativa/docker-socket-proxy:latest
   container_name: dockerproxy
   environment:
     - CONTAINERS=1 # Allow access to viewing containers
     - SERVICES=1 # Allow access to viewing services (necessary when using Docker Swarm)
     - TASKS=1 # Allow access to viewing tasks (necessary when using Docker Swarm)
     - POST=0 # Disallow any POST operations (effectively read-only)
   ports:
     - 127.0.0.1:2375:2375
   volumes:
     - /var/run/docker.sock:/var/run/docker.sock:ro # Mounted as read-only
   restart: unless-stopped
  
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    env_file: stack.env # Pass docker env vars to homepage
    ports:
      - 3000:3000
    environment:
      - PUID=1001
      - PGID=1000
      - TZ=Europe/London 
    volumes:
      - /var/lib/docker/volumes/homepage/config:/app/config # Make sure your local config directory exists
      - /var/lib/docker/volumes/homepage/images:/app/public/images #For images
    restart: unless-stopped  
```

`dockerproxy` allows read only access to the docker processes so it's generally safer than running the container as root.
https://gethomepage.dev/configs/docker/#using-docker-socket-proxy


If you want to run the homepage container as root:
- remove the PUID/GUID from the homepage container definition
- delete the dockerproxy config

If you want to run `dockerproxy` you will also need to:
- edit `/var/lib/docker/volumes/homepage/config/docker.yaml` and add

```
my-docker:
  host: dockerproxy
  port: 2375
```

## Customize appearance


Copy your assets to the image folder

```
scp /Users/stelian/resources/smo_favicon_color.png  root@192.168.100.175:/var/lib/docker/volumes/homepage/images/icons
```

 

You need to restart the container everytime you add a new image asset!

If you're changing favicon you may need to force the browser to refresh the page without cache: CMD+SHIT+R

## Configure Proxmox 

https://gethomepage.dev/widgets/services/proxmox/

## Configure Portainer

https://gethomepage.dev/widgets/services/portainer/

 https://docs.portainer.io/api/access


## Configure Synology


## Configure Unify Dream Machine


## Configure Plex 