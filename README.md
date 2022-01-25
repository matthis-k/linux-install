# Installation

This is assuming you use the live installation media provided by [the offical website](https://archlinux.org/download/)

## On the live installation media

Run the following on the live media (no arch-chroot):

```bash
loadkeys de-latin1 # depends on your kb layout
# find your station with
iwctl station list # here wlan0 as example
# find your SSID (name of WLAN)
iwctl station wlan0 scan # here "Your SSID" as example
iwctl station wlan0 connect "Your SSID"
pacman -Sy git
git clone https://github.com/matthis-k/linux-install
# edit the config to your liking
vim linux-install/archinstall.json
archinstall --config linux-install/archinstall.json
cp linux-install/install.sh /mnt/home/matthisk # change "matthisk" to your username
reboot
```

When prompted if you want to arch-chroot onto the new system decline, as install.sh can not be used as root, because it uses paru

## On the actual install

I recommend to edit the `/etc/sudoers` file and `/etc/doas.conf` first, to skip too many prompts (either use a timeout or no password confirmation). Be aware that only the last rule applies to a user.  
```
NOTE: THIS IS NOT RECOMMENDED TO KEEP AS SETTING UNLESS YOU KNOW WHAT YOU ARE DOING!!! THIS IS A VERY INSECURE SETTING!
```

Run the following when logged in:

```bash
sudo loadkeys de-latin1 # depends on your kb layout
# find your station with
iwctl station list # here wlan0 as example
# find your SSID (name of WLAN)
iwctl station wlan0 scan # here "Your SSID" as example
iwctl station wlan0 connect "Your SSID"
./install.sh
```

NOTE: right now `wireplumber` is in conflict with `pipewire-media-session`, which is why one could just move it above `pipewire` in the `packages`-file in the [config](https://github.com/matthis-k/config) repo

## Other things to do

- Log in to firefox
- Set up nordvpn:
  - `nordvpn login`
  - `nordvpn set autoconnect enabled`
  - This enables ssh usage while connected to nordvpn: `nordvpn whitelist port 22`
- Set up hibernation:
  - Create hibernation file with needed properties:
  ```
  sudo fallocate -l 17G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  ```
  - Update `/etc/fstab` by adding `/swapfile none swap defaults 0 0`
  - Update grub: - In `/etc/default/grub` add a kernel parameter called resume and resume offset.  
    It should look something like this:  
    `GRUB_CMDLINE_LINUX="resume=/dev/sdb2 resume_offset=2932736"`  
    Where:  
    `resume`: `findmnt -no UUID -T /swapfile`, or you know its partition (here `/dev/sdb2`)
    `resume_offset`: `filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'`
  - `sudo update-grub` OR `sudo grub-mkconfig -o /boot/grub/grub.cfg`
  - `sudo mkinitcpio -P`
