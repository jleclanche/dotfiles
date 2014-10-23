#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Must be root." 1>&2
	exit 1
fi

echo -n "Enter a hostname for this machine: "
read hostname
echo
echo $hostname > /etc/hostname

# Make zsh the default shell
chsh -s /usr/bin/zsh
cp .zshrc ~
cp .zshrc /etc/skel
mkdir -p ~/.config /etc/skel/.config ~/.cache /etc/skel/.cache


# Set LANG
echo "Setting LANG to en_US.UTF-8. Change it in /etc/locale.gen then run locale-gen"
sed -i "s/#en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

echo "Setting timezone to UTC. Change it by updating the /etc/localtime symlink."
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

echo "Please enter password for root user."
passwd

# install some basic stuff
cd meta-utils
makepkg --asroot -s --noconfirm
pacman -U *.xz --noconfirm
rm *.xz

# Replace sh by dash
ln -sf --backup /usr/bin/dash /usr/bin/sh && rm "/usr/bin/sh~"

echo -n "Do you want to install syslinux? [y/N] "
read y
if [[ "$y" == "y" || "$y" == "Y" ]]; then
	pacman -S syslinux --noconfirm
	syslinux-install_update -iam
fi
