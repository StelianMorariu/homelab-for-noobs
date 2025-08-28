## Caddy reverse proxy

### Installing Caddy and Cloudflare DNS resolver

1. Install from tteck scripts to get the LXC container

Run this in the host node

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/caddy.sh)"
```

2. download caddy with the cloudflare dns solver

 - go to https://caddyserver.com/download
 - select platform in the top left (`Linux amd64`)
 - in the modules list, search for `caddy-dns/cloudflare`
 - click the item
 - now click `Download` (top right of the page, above the available modules list)

3.  Stop caddy

In the caddy container, run

```
caddy stop
```


4. Upload the new caddy binary

Open a terminal on the machine you downloaded the new caddy binary and type

```
scp /Users/stelian/Downloads/caddy_linux_amd64_custom  root@192.168.100.8:/usr/bin/caddy
```

- replace with the correct path of the new binary
- replace the container IP

The above command will upload the new binary in `/usr/bin/caddy` on the container

5. Give correct permissions

In the Caddy LXC container, run 

```
sudo chmod +x /usr/bin/caddy
```

6.  Start caddy

In the Caddy LXC container, run 

```
caddy start
```

7. Check modules

You can check if the desired modules are installed by running the following command in the Caddy LXC container:

```
caddy list-modules
```

### Configure Caddy SSL 



#### Override env vars

Official docs [here](https://caddyserver.com/docs/running#overrides)

1. Edit caddy service 
```
sudo systemctl edit caddy
```

2. Add overrides for environment variables
```
[Service]
EnvironmentFile=/etc/caddy/.env
```

3. Create the Caddy .env file 
```
touch /etc/caddy/.env
```

Set the correct file permissions
```
sudo chown root:caddy /etc/caddy/.env
```

```
sudo chmod 640 /etc/caddy/.env
```

4. Add your env variables

```
nano /etc/caddy/.env
```

DON'T USE QUOTES FOR THE VALUES!!
```
CF_API_TOKEN=your-api-token
```

5. Restart caddy

```
sudo systemctl restart caddy
```

6. Verification

Cady will log all the env variables it uses during startup so you can check the logs with

```
journalctl -u caddy -b
```


#### Caddyfile

1. On the host node, open a terminal and run

```
cd /etc/caddy
```

You should already have a `Caddyfile` which you will need to edit
(If yu don't have the file create it with `touch Caddyfile`)

2. Add tls configuration

```
nano Caddyfile
```

Add your configuration

```
{
        email stelian.morariu@gmail.com
}

*.local.morariu.app {
    tls {
        dns cloudflare {env.CF_API_TOKEN}
        resolvers 1.1.1.1
    }

    # Reverse proxies
    @portainer host portainer.local.morariu.app
    handle @portainer {
        reverse_proxy https://192.168.100.110:9443 {
            transport http {
                # ignore Portainer self signed certificate
                tls_insecure_skip_verify
           }
        }
    }

    # drop everything that doesn't match the domain
    handle {
       abort
    }
    
}
```



3. Validate your config

```
caddy validate --config /etc/caddy/Caddyfile
```

It might complain about formatting, in which case:

```
caddy fmt --overwrite
```


4. Update Caddy configuration

```
caddy reload --config /etc/caddy/Caddyfile
```

Check if certificates have been issued
```
ls -l /var/lib/caddy/.local/share/caddy/acme/acme-v02.api.letsencrypt.org-directory
```

#### Debugging

Caddy Status

```
sudo systemctl status caddy
```

Certificate logs
```
sudo journalctl -u caddy --no-pager | grep -i "certificate"
```

Host resolution
```
curl -I https://portainer.local.morariu.app
```


### Check Cloudflare token

curl -X GET "https://api.cloudflare.com/client/v4/zones" -H "Authorization: 2C4bYhuz_MN4yzDp63acrGvWSeD88DE6BJOss4QU"

curl -X GET "https://api.cloudflare.com/client/v4/zones" \
     -H "Authorization: Bearer 2C4bYhuz_MN4yzDp63acrGvWSeD88DE6BJOss4QU" \
     -H "Content-Type: application/json"


curl -X GET "https://api.cloudflare.com/client/v4/zones/5a46a3b8235a058f07ee9ef31b48b285/dns_records" \
     -H "Authorization: Bearer 2C4bYhuz_MN4yzDp63acrGvWSeD88DE6BJOss4QU" \
     -H "Content-Type: application/json"

curl -X GET "https://api.cloudflare.com/client/v4/zones?name=morariu.app" \
  -H "Authorization: Bearer 2C4bYhuz_MN4yzDp63acrGvWSeD88DE6BJOss4QU" \
  -H "Content-Type: application/json"


curl -X GET "https://api.cloudflare.com/client/v4/zones/5a46a3b8235a058f07ee9ef31b48b285/dns_records" \
  -H "Authorization: Bearer 2C4bYhuz_MN4yzDp63acrGvWSeD88DE6BJOss4QU" \
  -H "Content-Type: application/json"


dig TXT _acme-challenge.portainer.local.morariu.app

sudo journalctl -u caddy.service --no-pager | grep -i "tls"

## Homepage widget

In order to use the Homepage Caddy widget we need to bind the admin API to the actual container IP

Add this in the Caddyfile

```
{
    admin 192.168.100.8:2019
}
```

In the LXC container console
```
caddy fmt --overwrite
```
 then 

 ```
caddy validate --config /etc/caddy/Caddyfile
```

and finally, we need to restart the container insted of just applying the changes

```
sudo systemctl restart caddy
```


