sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sudo hwclock --systohc
sed 's/#\(de_DE.UTF-8\|en_US.UTF-8\)/\1/g' /etc/locale.gen > locale.gen
sudo mv locale.gen /etc/locale.gen
sudo locale-gen
echo LANG=en_US.UTF-8 > locale.conf
sudo mv locale.conf /etc/locale.conf
echo KEYMAP=de-latin1 > vconsole.conf
sudo mv vconsole.conf /etc/vconsole.conf
echo myhostname > hostname
sudo mv hostname /etc/hostname
sudo mkinitcpio -P
sudo grub-install --target=i386-pc /dev/vda
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo pacman -Syu rustup base-devel git --noconfirm
rustup toolchain add nightly && rustup toolchain add stable && rustup default nightly
git clone https://github.com/matthis-k/config
git clone https://github.com/matthis-k/config-manager
sudo config-manager/deploy-config  ~/config
sudo pacman -Syy --noconfirm
chmod +x config-manager/install-needed-packages
config-manager/install-needed-packages ~/config
sudo systemctl enable sddm
sudo systemctl enable preload
sudo systemctl enable iwd
sudo systemctl enable bluetooth
chsh -s /bin/fish
sudo chsh -s /bin/fish
