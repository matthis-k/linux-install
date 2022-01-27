#!/bin/fish
function local_settings -d "set up locales" 
    sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
    sudo hwclock --systohc
    sed 's/#\(de_DE.UTF-8\|en_US.UTF-8\)/\1/g' /etc/locale.gen | sudo tee /etc/locale.gen
    echo LANG=en_US.UTF-8 | sudo tee /etc/locale.conf
    echo KEYMAP=de-latin1 | sudo tee /etc/vconsole.conf
    echo myhostname | sudo tee /etc/hostname
    sudo locale-gen
end

function grub_settings -d "set up grub configuration"
    sed 's/#\?\(GRUB_DISABLE_OS_PROBER\)=\(.*\)/\1=false/g' /etc/default/grub | sudo tee /etc/default/grub
    sed 's/#\?\(GRUB_TIMEOUT\)=\(.*\)/\1=2/g' /etc/default/grub | sudo tee /etc/default/grub
    sudo mkinitcpio -P
    sudo grub-install --target=i386-pc /dev/vda
    sudo grub-mkconfig -o /boot/grub/grub.cfg
end

function install_base_packages -d "install base packages"
    pacman -Syu base-devel git rustup
    rustup roolchain add nightly
    rustup roolchain add stable
    rustup default nightly
end

function setup_configuraion -d "configuration"
    git clone https://github.com/matthis-k/config
    git clone https://github.com/matthis-k/config-manager
    config-manager/full-install config
    fish -c cfg_pull
end


local_settings
grub_settings
install_base_packages
setup_configuraion
