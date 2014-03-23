sudo pacman -S yajl &&
mkdir -p _yaourt && cd _yaourt
mkdir -p _package-query && cd _package-query
curl https://aur.archlinux.org/packages/pa/package-query/PKGBUILD -o PKGBUILD &&
makepkg &&
sudo pacman -U --noconfirm package-query-*.xz
curl https://aur.archlinux.org/packages/ya/yaourt/PKGBUILD -o PKGBUILD &&
makepkg &&
sudo pacman -U --noconfirm yaourt-*.xz
cd ../..
rm -rf _yaourt
