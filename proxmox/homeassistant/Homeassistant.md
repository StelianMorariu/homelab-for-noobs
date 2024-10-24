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





# Zigbee stuff

1. Attach USB device to Proxmox host
2. Edit the VM and pass the USB device

## Install SSH add-on

This is required to get the USB device path  which is needed for Zigbee

```
ls -l /dev/serial/by-id/
```

## Install MQTTBroker

- install from the add-on store
- create separate user & pass to be used only by mqtt


## Install Zigbe2Mqtt

Official guide [here](https://github.com/zigbee2mqtt/hassio-zigbee2mqtt#installation)

- in Home Assistant go to `Settings` → `Add-ons` → `Add-on store` and install the `Mosquitto broker` addon, then start it.
- Go back to the `Add-on store`, 
    - click ⋮ → `Repositories`, 
    - fill in `https://github.com/zigbee2mqtt/hassio-zigbee2mqtt` 
    - click `Add` → `Close` 



MQTT section: 

```
server: mqtt://core-mosquitto:1883
user: mqtt
password: "blood-suck-wire"
```

Serial section:

```
port: >-
  /dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231218172750-if00
adapter: ezsp
```
