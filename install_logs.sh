#!/usr/bin/env bash

source non_sudo_check.sh

# INHERIT
if [ -z "$LOGS_DIR_PATH" ]; then
    LOGS_DIR_PATH="/var/log/asus-accel-tablet-mode-driver"
fi

sudo groupadd "acceltabletmodedriver"

sudo usermod -a -G "acceltabletmodedriver" $USER

if [[ $? != 0 ]]; then
    echo "Something went wrong when adding the group acceltabletmodedriver to current user"
    exit 1
else
    echo "Added group acceltabletmodedriver to current user"
fi

sudo mkdir -p "$LOGS_DIR_PATH"
sudo chown -R :acceltabletmodedriver "$LOGS_DIR_PATH"
sudo chmod -R g+w "$LOGS_DIR_PATH"