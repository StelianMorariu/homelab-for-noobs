## Install OpenVPN in OpenWrt

This guide is based on [NovaTechs video](https://www.youtube.com/watch?v=3mPbrunpjpk&ab_channel=NovaspiritTech) but with written instructions.
An official OpenWrt guide is also available [here](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client-luci).

1. Install the OpenVpn UI packages for OpenWrt
   - in the OpenWrt Web UI, go to `System/Software`
   - click `Update lists`
   - in the `Filter` box, type `openvpn`
   - from the search results, install `openvpn-openssl` and `luci-app-openvpn`

2. Refresh your browser and you should see a new menu item -> `VPN`

3. Now select `VPN/OpenVPN`

4. At this point you will need to go to your VPN provider and obtain a configuration file

5. Upload the configuration file to OpenWrt

6. Edit the configuration file

- search the `auth-user-pass` field and add the suggested values
```
auth-user-pass /etc/openvpn/pia_london.auth
```
Don't forget to out your username and passowrd on separate lines, in the box bellow the configuration file

- you can also add the dhcp options in this configuration file, you should get these DNS servers from your VPN provider

```
dhcp-option DNS 10.0.0.243
dhcp-option DNS 10.0.0.241
```

- it's also recommended to disable cache for authentication

```
auth-nocache
```

The updated configration should look like this
```
dhcp-option DNS 10.0.0.243
dhcp-option DNS 10.0.0.241
auth-user-pass /etc/openvpn/pia_london.auth
auth-nocache
```

- click `Save`
PS: This will not close the screen
PPS: don't start the vpn client yet!

7. Create a new network interface

- go to `Network/Interfaces`
- click on `Add new interface...`
- add a new tun interface:
    - name: `tun0` 
    - protocol: `Unmanaged`
    - device: tap on the device dropdown, at the bottom, in the _custom_ field enter `tun0` and tap Enter
    - click on `Create interface`
    - in the next dialog click `Save`

 You now have a new network interface but the changes have not been applied yet.

 8. Update firewall rules for `tun0`

 - go to `Network/Firewall`
 - edit the `wan` zone
 - on the edit screen, search for `Covered networks`
    - click on the dropdown and click on the `tun0` interface
- click `Save`, this edit screen will close
- now  click `Save & Apply` to apply all pending changes 

9. If you're accessing the Homelab from a VLAN

In order to still have access to the Web UI when you're accessing OpenWrt from a different VLAN we need to add a static route.
Without this static rule, OpenWrt doesn't know about the VLANs so it will route the call through the VPN tunnel.

This solution was posted in the [proxmox forum](https://forum.proxmox.com/threads/openwrt-on-lxc-gui-access-dies-when-vpn-starts.151070/post-683996)

You basically have to instruct the router to route your VPN through the router gateway:
- go to `Network/Routing`
- on the `Static IPv4 Routes` tab(which should be the first one on the screen) tap  `Add`
- on the new dialog enter the values:
    - Interface: `wan`
    - Route type: `unicast`
    - Target: your VLAN CIDR address(ie: 192.160.30.0/24)  
    - Gateway: your main router gateway (ie: 192.168.100.1)
       - this should be the gateway that gives the IP to OpenWrt LXC
    - click `Save`
- click `Save & Apply`  

You can double check these settings where applied by going to Proxmox, selecting the OpenWrt container, open a console
and type:

```
ip route list
```

10. Start the VPN client

- go to `VPN/OpenVPN`
- next to the VPN config that you uploaded, tick the `Enabled` checkbox
- click `Save & Apply`
- this will take a bit longer than other updates but your browser should automatically refresh and you should see the that the client was started

