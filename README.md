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
  ```
  echo /swapfile none swap defaults 0 0 | sudo tee -a /etc/fstab
  ```
  - Update grub: - In `/etc/default/grub` add a kernel parameter called resume and resume offset.  
    It should look something like this:  
    `GRUB_CMDLINE_LINUX="resume=/dev/sdb2 resume_offset=2932736"`  
    Where:  
    `resume`: `findmnt -no UUID -T /swapfile`, or you know its partition (here `/dev/sdb2`)
    `resume_offset`: `filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'`
  - the following command should generate the file correctly:
    ```
    sed 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume='(findmnt -n -T /swapfile | awk '{print $2}' | sed 's#/#\\\/#g')' resume_offset='(sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')'"/g' /etc/default/grub | sudo tee /etc/default/grub
    ```
    - NOTE: using `/dev/sdx` always worked for me. If it does not work for you, just replace the `findmnt` command with the one above, which returns the UUID
  - Add kernel hook: `sed 's/HOOKS=(\(.*\))/HOOKS=(\1 resume)/g' /etc/mkinitcpio.conf | sudo tee /etc/mkinitcpio.conf`
  - `sudo update-grub` OR `sudo grub-mkconfig -o /boot/grub/grub.cfg`
  - `sudo mkinitcpio -P`
 - So in total this is:
 ```
sudo fallocate -l 17G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo /swapfile none swap defaults 0 0 | sudo tee -a /etc/fstab
sed 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="resume='\
(findmnt -n -T /swapfile | awk '{print $2}' | sed 's#/#\\\/#g')\
' resume_offset='(sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')'"/g' /etc/default/grub\
| sudo tee /etc/default/grub
sed 's/HOOKS=(\(.*\))/HOOKS=(\1 resume)/g' /etc/mkinitcpio.conf | sudo tee /etc/mkinitcpio.conf
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -P

 ```

 NOTE: On my (intel) laptop  I also had to:
 - Enable a kernel module:
```
sed 's/MODULES=(\(.*\))/MODULES=(\1 )/g' /etc/mkinitcpio.conf | sudo tee /etc/mkinitcpio.conf
sudo mkinitcpio -P
```
 - Change HibernationMode:
```
sed 's/#\?\(HibernateMode\)=\(.*\)/\1=shutdown/g' /etc/systemd/sleep.conf | sudo tee /etc/systemd/sleep.conf
```
