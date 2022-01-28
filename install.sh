sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sudo hwclock --systohc
sed 's/#\(de_DE.UTF-8\|en_US.UTF-8\)/\1/g' /etc/locale.gen | sudo tee /etc/locale.gen
echo LANG=en_US.UTF-8 | sudo tee /etc/locale.conf
echo KEYMAP=de-latin1 | sudo tee /etc/vconsole.conf
echo myhostname | sudo tee /etc/hostname
sed 's/#\?\(GRUB_DISABLE_OS_PROBER\)=\(.*\)/\1=false/g' /etc/default/grub | sudo tee /etc/default/grub
sed 's/#\?\(GRUB_TIMEOUT\)=\(.*\)/\1=2/g' /etc/default/grub | sudo tee /etc/default/grub
sudo locale-gen
sudo mkinitcpio -P
sudo grub-install --target=i386-pc /dev/vda
sudo grub-mkconfig -o /boot/grub/grub.cfg

sudo pacman -Syu rustup base-devel git --noconfirm
rustup toolchain add nightly && rustup toolchain add stable && rustup default nightly
git clone https://github.com/matthis-k/config
git clone https://github.com/matthis-k/config-manager
sudo config-manager/full-install  ~/config
sudo systemctl enable sddm
sudo systemctl enable preload
sudo systemctl enable iwd
sudo systemctl enable bluetooth
chsh -s /bin/fish
sudo chsh -s /bin/fish
