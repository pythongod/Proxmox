```
     ____
    / __ \_________  _  ______ ___  ____  _  __
   / /_/ / ___/ __ \| |/_/ __ `__ \/ __ \| |/_/
  / ____/ /  / /_/ />  </ / / / / / /_/ />  <
 /_/   /_/   \____/_/|_/_/ /_/ /_/\____/_/|_|
      __  __          __      __
     / / / /___  ____/ /___ _/ /____  ____
    / / / / __ \/ __  / __ `/ __/ _ \/ __/
   / /_/ / /_/ / /_/ / /_/ / /_/  __/ /
   \____/ .___/\____/\____/\__/\___/_/
       /_/
```


# Proxmox-Updater

Features:
- Update Proxmox (the host / all cluster nodes / all included LXCs and VMs)
- Normal run is "Interactive" / Headless Mode can be run with `update -s`
- Logging
- Exit tracking, so you can send additional commands for finish or failure (edit files in /root/Proxmox-Update-Scripts/exit)
- Extra updates for specific container (edit `update-extras.sh` if you want)

Info can be found with `update -h`


## Update the script:
`update -up`

If update run into issue, please remove first with:
```
bash <(curl -s https://raw.githubusercontent.com/BassT23/Proxmox/master/install.sh) uninstall
```
and install new


## Installation:
In Proxmox GUI Host Shell or as root on proxmox host terminal:
```
bash <(curl -s https://raw.githubusercontent.com/BassT23/Proxmox/master/install.sh)
```
### If you want to update the VMs also, please install and run `qemu-guest-agent` on VM.

check out here: <https://pve.proxmox.com/wiki/Qemu-guest-agent> for more infos.


## Extra Updates:
 If updater detects Installation: (disable, if you wand in `/root/Proxmox-Updater-Scripts/update-extras.sh`)
- PiHole
- ioBroker
- Pterodactyl
- Octoprint
- Docker Container Images (disabled by default - need some fixing)


## Beta Testing:
If anybody want to help with failure search, please test our beta (if available).
Install beta update with:
```
bash <(curl -s https://raw.githubusercontent.com/BassT23/Proxmox/beta/install.sh) update
```


## Credits:
[@Uruk](https://github.com/Uruknara) - for help with the code
