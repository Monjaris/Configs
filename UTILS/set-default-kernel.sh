#!/bin/bash

set -e

CFG="/boot/grub/grub.cfg"

# Find first cachyos entry
entry=$(grep -P "menuentry '.*cachyos.*'" "$CFG" | head -n1 | cut -d"'" -f2)

if [[ -z "$entry" ]]; then
    echo "CachyOS kernel entry not found!"
    exit 1
fi

echo "Setting default kernel: "
echo "$entry"

sudo grub-set-default "$entry"

sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
mkinitcpio -P || dracut --rebuild
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Done."
