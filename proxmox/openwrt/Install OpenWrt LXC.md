## Install OpenWRT as LXC

This guide is based on [NovaTechs video](https://www.youtube.com/watch?v=3mPbrunpjpk&ab_channel=NovaspiritTech) but with written instructions.

1. On the host node, go to `Network settings`
	- create a new `vmbr1` Linux Bridge
	- don't assign any devices to it	
	- create the bridge
	- click `Save and apply changes` 
	
2. Download OpenWrt image on host node so that we can create an LXC instead of a VM
-  on the host node, open a shell and download the official openwrt image
    - you will want to navigate to the latest version and copy the download link for the `rootfs.tar.xz`

```
  wget https://fra1lxdmirror01.do.letsbuildthe.cloud/images/openwrt/23.05/amd64/default/20240924_11%3A57/rootfs.tar.xz
```

After the command completes, you will have `rootfs.tar.xz` on your host node.

3. Create the OpenWrt container
- in the host shell, type the following command

   ```
   pct create 100 ./rootfs.tar.xz --unprivileged 1 --ostype unmanaged --hostname openwrt --net0 name=eth0 --net1 name=eth1 --storage local-lvm 
   ```

4. On the LXC `Network settings`
    - modify `eth0` and set it to use `vmbr0`
       - clicking save will throw an error at this point so just close the dialog 
    - modify `eth1` and set it to use `vmbr1`

5. On host node, allow the LXC to access the networking tunnel 

To do this, we need to manually edit the `conf` file for the LXC.

Enter the command bellow and replace `100` with the ID of your container:

```
   nano /etc/pve/lxc/100.conf
```

add the following lines:

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

(control+X, y, enter to save the changes)

6. Start the LXC container
At this stage you won't be able to access the Web UI but we'll fix that in the next step.

7. Update LXC container firewall rules to gain access to web ui
   - on the LXC console, type
  
```
vi /etc/config/firewall
```
- scroll to the bottom, and add the following rule
   - tap `i` so you can edit the file
   - add 

```
config rule
        option src      wan
        option dest_port   80
        option proto   tcp
        option target  ACCEPT
```
   - tap `Esc` to exit interactive mode
   - type `:wq` to save and exit

8. In the LXC shell, type `ip a` to find out the IP address
9. You can now access OpenWrt by going to `IP:80`   

### Configuring OpenWrt

1. When you first access the OpenWrt WebUi type anything for the password
2. Set a new password 
3. Go to `Network / Interfaces` and add a new interface
    - name it `lan`
    - select `Static Address` for the protocol
    - assign it to `eth1`
    - click `Create interface`
    - on the next screen
        - you can now enter the internal LAN IP you want to use
        - choose the `255.255.255.0` subnet mask
        - leave all the other settings as they are
        - click `Save`
4. After the interface is created, click `Save and apply`

Now, all VMs that use the `vmbr1` bridge will get an IP address from OpenWrt.  

