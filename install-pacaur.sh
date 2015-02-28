mkdir -p _pacaur && cd _pacaur
mkdir -p _cower && cd _cower
curl https://aur.archlinux.org/packages/co/cower/PKGBUILD -o PKGBUILD &&
makepkg -s &&
sudo pacman -U --noconfirm cower-*.xz
curl https://aur.archlinux.org/packages/pa/pacaur/PKGBUILD -o PKGBUILD &&
makepkg -s &&
sudo pacman -U --noconfirm pacaur-*.xz
cd ../..
rm -rf _pacaur
