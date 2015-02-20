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

echo "Creating a default user. This user will be part of the wheel group and as such will be able to use sudo."
echo -n "Please enter a username (leave blank to skip): "
read username
echo

if [[ "$username" != "" ]]; then
	useradd $username --create-home -s /usr/bin/zsh -g users -G wheel
	echo "Created user $username"
	sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
	passwd $username

	echo "Installing core utilities (meta-utils)"
	cp -r meta-utils /tmp/meta-utils
	cd /tmp/meta-utils
	sudo -u $username makepkg -s --noconfirm
	pacman -U *.xz --noconfirm
	rm -rf /tmp/meta-utils

	# Set PermitRootLogin appropriately for ssh
	while [[ "$y" != "yes" && "$y" != "no" && "$y" != "without-password" ]]; do
		echo "Do you want to permit SSH root logins? (Enter exact value: [yes | no | without-password])"
		read y
	done
	sed -i "s/#PermitRootLogin.*/PermitRootLogin $y/" /etc/ssh/sshd_config
fi

if [[ -d /sys/firmware/efi/efivars ]]; then
	echo -n "Do you want to install gummiboot? [y/N] "
	read y
	if [[ "$y" == "y" || "$y" == "Y" ]]; then
		pacman -S gummiboot --noconfirm
		partition=$(findmnt --noheadings --output=source /)
		uuid=$(blkid -o value -s PARTUUID $partition)
		printf "%s\n" "default arch" "timeout 3" >> /boot/loader/loader.conf
		printf "%s\n" \
			"title	Arch Linux" \
			"linux	/vmlinuz-linux" \
			"initrd	/initramfs-linux.img" \
			"options	root=PARTUUID=$uuid rw" > /boot/loader/entries/arch.conf
		echo "Configured in /boot/loader/loader.conf and /boot/loader/entries/arch.conf"
	fi
else
	echo -n "Do you want to install syslinux? [y/N] "
	read y
	if [[ "$y" == "y" || "$y" == "Y" ]]; then
		pacman -S syslinux --noconfirm
		syslinux-install_update -iam
		echo "WARNING: syslinux autodetection can be erroneous. You may need to edit /boot/syslinux/syslinux.cfg."
	fi
fi


# Basic system configuration

# Console font (see man 5 vconsole.conf)
# Setting to eurlatgr, courtesy of Fedora
echo "FONT=eurlatgr" >> /etc/vconsole.conf

if [[ -f /bin/dash ]]; then
	echo "Replacing /usr/bin/sh by dash. Reinstall core/bash to revert."
	ln -sf --backup /usr/bin/dash /usr/bin/sh && rm "/usr/bin/sh~"
else
	echo "Not installing dash. Remember to install meta-utils!"
fi

# Time settings
timedatectl set-ntp true
hwclock --systohc --utc
echo "NTP has been enabled and hardware clock will be in UTC. More information: https://wiki.archlinux.org/index.php/Time"

# enable color output for pacman
sed -i "s/#Color/Color/" /etc/pacman.conf

if [[ -f /etc/vimrc ]]; then
	echo "Enabling some base vim settings"
	printf "%s\n" "syntax on" "filetype plugin indent on" "colorscheme darkblue" "set number" >> /etc/vimrc
fi
