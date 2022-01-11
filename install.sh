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
