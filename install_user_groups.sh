#!/usr/bin/env bash

source non_sudo_check.sh

sudo groupadd "uinput"

sudo usermod -a -G "uinput" $USER

if [[ $? != 0 ]]; then
    echo "Something went wrong when adding the uinput group to current user"
    exit 1
else
    echo "Added groups uinput to current user"
fi

sudo modprobe uinput

# check if the uinput module is successfully loaded
if [[ $? != 0 ]]; then
    echo "uinput module cannot be loaded"
    exit 1
else
    echo "uinput module loaded"
fi

sudo chown :uinput /dev/uinput

echo 'KERNEL=="uinput", GROUP="uinput", MODE="0660"' | sudo tee /usr/lib/udev/rules.d/99-asus-accel-tablet-mode-driver-uinput.rules >/dev/null
echo 'uinput' | sudo tee /etc/modules-load.d/uinput-asus-accel-tablet-mode-driver.conf >/dev/null

if [[ $? != 0 ]]; then
    echo "Something went wrong when adding uinput module to auto loaded modules"
    exit 1
else
    echo "uinput module added to auto loaded modules"
fi

sudo udevadm control --reload-rules && sudo udevadm trigger --sysname-match=uinput

if [[ $? != 0 ]]; then
    echo "Something went wrong when reloading or triggering uinput udev rules"
else
    echo "Udev rules reloaded and triggered"
fi