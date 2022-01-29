# Installation
* [On the live installation media](#on-the-live-installation-media)
* [On the live installation media](#on-the-actual-install)  
  *  [Basic setup](#basic-setup)  
  *  [Other things to do](#other-things-to-do)  
     * [Log in to Firefox](#log-in-to-firefox)
     * [Set up nordvpn](#set-up-nordvpn)
     * [Hibernation](#set-up-hibernation)
       * [Not working?](#not-working-on-laptops?)
     * [Ssh](#ssh)

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

### Basic setup
Run the following when logged in:

```
sudo loadkeys de-latin1 # depends on your kb layout
# find your station with
iwctl station list # here wlan0 as example
# find your SSID (name of WLAN)
iwctl station wlan0 scan # here "Your SSID" as example
iwctl station wlan0 connect "Your SSID"
./install.sh
```

NOTE: right now `wireplumber` is in conflict with `pipewire-media-session`, which is why one could just move it above `pipewire` in the `packages`-file in the [config](https://github.com/matthis-k/config) repo

### Other things to do

#### Log in to firefox
#### Set up nordvpn:
  - `nordvpn login`
  - `nordvpn set autoconnect enabled`
  - This enables ssh usage while connected to nordvpn: `nordvpn whitelist port 22`
#### Set up hibernation:
Run this in fish, not bash. For bash you will have to change the subshells from `(...)` to `$(...)`.
```
# create swapfile (17G large)
sudo fallocate -l 17G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# add swapfile to fstab
echo /swapfile none swap defaults 0 0 | sudo tee -a /etc/fstab
# set kernel parameter
sed 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume='\
(findmnt -n -T /swapfile | awk '{print $2}' | sed 's#/#\\\/#g')\
' resume_offset='(sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')'"/g' /etc/default/grub\
| sudo tee /etc/default/grub
# add resume hook
sed 's/HOOKS=(\(.*\))/HOOKS=(\1 resume)/g' /etc/mkinitcpio.conf | sudo tee /etc/mkinitcpio.conf
# update grub configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg
# generate initfsrams
sudo mkinitcpio -P
```
NOTE: If this does not work, try replacing the `findmnt` command with this: `findmnt -no UUID -T /swapfile`

##### Not working on laptops?
Try this:
 - Add kernel module:
    ```
    sed 's/MODULES=(\(.*\))/MODULES=(\1 )/g' /etc/mkinitcpio.conf | sudo tee /etc/mkinitcpio.conf
    sudo mkinitcpio -P
    ```
 - Change Hibernate Mode:
    ```
    sed 's/#\?\(HibernateMode\)=\(.*\)/\1=shutdown/g' /etc/systemd/sleep.conf | sudo tee /etc/systemd/sleep.conf
    ```
#### Ssh
How to set up ssh?  
It is quite simple:
On local machine:
```
ssh-keygen -t rsa -b 4096
ssh-add <path-to-private-key> # ~/.ssh/id_rsa by default
# scp works just like cp, except that you have to prefix the remote machine with <remote-user>@<remote-address>:/absolute/path
scp <path-to-public-key> <remote>@<remote-adress>:<path-to-.ssh-directory>
```
On remote machine:
```
cat <path-to-pub-key> >> ~/.ssh/authorized_keys
```
