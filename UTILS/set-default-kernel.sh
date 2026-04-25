#!/bin/bash

set -e
CFG="/boot/grub/grub.cfg"
KERN="$1"


# Filter and set $entry
entry=$(sudo grep -P "menuentry '.*Linux linux$KERN'" "$CFG" | head -n1 | cut -d"'" -f2)
if [[ -z "$entry" ]]; then
    echo "$KERN kernel entry not found!"
    exit 1
fi
echo "Setting default kernel: "
echo "$entry"


# Configuire grub
sudo grub-set-default "$entry"
sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub

# Generate initramfs and grub.cfg
sudo mkinitcpio -P || sudo dracut --rebuild || \
    { echo "Initramfs generation failed!"; exit 1; }
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Done."
