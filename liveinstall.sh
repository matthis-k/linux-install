#!/bin/bash

DISK=vda
ROOT=vda2
EFI=vda1

loadkeys de-latin1
IS_UEFI=0
ls /sys/firmware/efi/efivars && IS_UEFI=1
timedatectl set-ntp true
cfdisk /dev/$DISK
mkfs.ext4 /dev/$ROOT
mkfs.fat -F 32 /dev/$EFI
mount /dev/$ROOT /mnt
mkdir /mnt/boot
mount /dev/$EFI /mnt/boot
pacstrap /mnt base linux linux-firmware base-devel vi vim rustup git iwd man-pages man-db texinfo
genfstab -U /mnt >> /mnt/etc/fstab
[ $IS_UEFI == 1 ] && echo Note: this is an uefi system || echo Note: this is no uefi system

read you will chroot onto the install
arch-chroot /mnt

