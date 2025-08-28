# Glances

## 1. Install or uninstall using ttek script


```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/glances.sh)"
```

After that, you can access glances on  the port `61208` of the machine where it was installed

http://192.168.100.60:61208 



## 2. Configure as server

https://www.derekseaman.com/2023/04/home-assistant-monitor-proxmox-with-glances.html

- stop glances
```
systemctl stop glances
```

- manually run glances and set username and password
```
glances -w --username --password
```
- Enter user name and password
- Choose to save the password
- You can now press CTRL+C to exit the server
- If everything went ok, you should be able to find a password file by running
  ```
  find / -name glances.pwd
  ```
- edit the glances service config

`nano /etc/systemd/system/glances.service`

Update the start command and pass in the user argument
```
[Unit]
Description=Glances - An eye on your system
After=network.target

[Service]
ExecStart=/usr/local/bin/glances -w -u glances
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

- Restart glances
```
systemctl restart glances.service
```

It might ask you to reload the daemon so do that
```
systemctl daemon-reload
```