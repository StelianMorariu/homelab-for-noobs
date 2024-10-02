# Homeassistant 


- install from [ttek script](https://tteck.github.io/Proxmox/#home-assistant-os-vm)
```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/vm/haos-vm.sh)"
```

Use advanced settings if you want to change VM id


## VS Code Add-on

- go to Settings -> Add-Ons
- search for `Studio Code Server`
- install it

By default, the add-on will not have access to the internal `.storage` directory. 
To fix that you need to:
- open the VS code
- go to `Settings`
- search for `files.exclude`
- rmeove the `.storage` from the list of patterns


## Zigbe2MQTT add-on

Official guide [here](https://github.com/zigbee2mqtt/hassio-zigbee2mqtt#installation)

- in Home Assistant go to `Settings` → `Add-ons` → `Add-on store` and install the `Mosquitto broker` addon, then start it.
- Go back to the `Add-on store`, 
    - click ⋮ → `Repositories`, 
    - fill in `https://github.com/zigbee2mqtt/hassio-zigbee2mqtt` 
    - click `Add` → `Close` 