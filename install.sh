ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
sed 's/#\(de_DE.UTF-8\|en_US.UTF-8\)/\1/g' /etc/locale.gen > /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
KEYMAP=de-latin1 > /etc/vconsole.conf
echo myhostname > /etc/hostname
mkinitcpio -P
passwd
grub-install --target=i386-pc /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg
sudo pacman -Syy rustup base-devel git
rustup toolchain add nightly && rustup toolchain add stable && rustup default nightly
git clone https://github.com/matthis-k/config
git clone https://github.com/matthis-k/config-manager
(
    cd config-manager/
    sudo ./deploy-config  ~/config
    ./install-needed-packags ~/config
)
sudo systemctl enable sddm
sudo systemctl enable preload
sudo systemctl enable iwd
sudo systemctl enable bluetooth
chsh -s /bin/fish
sudo chsh -s /bin/fish
