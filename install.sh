sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sudo hwclock --systohc
sudo sed 's/#\(de_DE.UTF-8\|en_US.UTF-8\)/\1/g' /etc/locale.gen > /etc/locale.gen
sudo locale-gen
sudo echo LANG=en_US.UTF-8 > /etc/locale.conf
sudo KEYMAP=de-latin1 > /etc/vconsole.conf
sudo echo myhostname > /etc/hostname
sudo mkinitcpio -P
passwd
sudo grub-install --target=i386-pc /dev/vda
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo pacman -Syy rustup base-devel git --noconfirm
rustup toolchain add nightly && rustup toolchain add stable && rustup default nightly
git clone https://github.com/matthis-k/config
git clone https://github.com/matthis-k/config-manager
sudo config-manager/deploy-config  ~/config
sudo pacman -Syyu
config-manager/install-needed-packags ~/config
sudo systemctl enable sddm
sudo systemctl enable preload
sudo systemctl enable iwd
sudo systemctl enable bluetooth
chsh -s /bin/fish
sudo chsh -s /bin/fish
