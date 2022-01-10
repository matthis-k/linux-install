#!/bin/bash
loadkeys de-latin1
ls /sys/firmware/efi/efivars
timedatectl set-ntp true
cfdisk /dev/disk
mkfs.ext4 /dev/root_partition
mkfs.fat -F 32 /dev/efi_system_partition
mount /dev/root_partition /mnt
mkdir /mnt/boot
mount /dev/efi_system_partition /mnt/boot
pacstrap /mnt base linux linux-firmware base-devel vi vim rustup git iwd man-pages man-db texinfo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

