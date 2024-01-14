#!/usr/bin/env bash

source non_sudo_check.sh

LOGS_DIR_PATH="/var/log/asus-accel-tablet-mode-driver"

source install_logs.sh

echo

# log output from every installing attempt aswell
LOGS_INSTALL_LOG_FILE_NAME=install-"$(date +"%d-%m-%Y-%H-%M-%S")".log
LOGS_INSTALL_LOG_FILE_PATH="$LOGS_DIR_PATH/$LOGS_INSTALL_LOG_FILE_NAME"


{
    if [[ $(sudo apt-get install 2>/dev/null) ]]; then
        sudo apt-get -y install ibus libevdev2 python3-dev python3-libevdev
    elif [[ $(sudo pacman -h 2>/dev/null) ]]; then
        # arch does not have header packages (python3-dev), headers are shipped with base? python package should contains almost latest version python3.*
        sudo pacman --noconfirm --needed -S ibus libevdev python python-libevdev
    elif [[ $(sudo dnf help 2>/dev/null) ]]; then
        sudo dnf -y install ibus libevdev python3-devel python3-libevdev
    elif [[ $(sudo yum help 2>/dev/null) ]]; then
        # yum was replaced with newer dnf above
        sudo yum --y install ibus libevdev python3-devel python3-libevdev
    elif [[ $(sudo zypper help 2>/dev/null) ]]; then
        sudo zypper install ibus libevdev2 python3-devel python3-libevdev
    else
        echo "Not detected package manager. Driver may not work properly because required packages have not been installed. Please create an issue (https://github.com/asus-linux-drivers/asus-accel-tablet-mode-driver/issues)."
    fi

    echo

    # do not install __pycache__
    if [[ -d conf/__pycache__ ]]; then
        sudo rm -rf conf/__pycache__
    fi

    INSTALL_DIR_PATH="/usr/share/asus-accel-tablet-mode-driver"

    sudo mkdir -p "$INSTALL_DIR_PATH/conf"
    sudo chown -R $USER "$INSTALL_DIR_PATH"
    sudo install asus_accel_driver.py "$INSTALL_DIR_PATH"
    sudo install -t "$INSTALL_DIR_PATH/conf" conf/*.py

    echo

    source install_user_groups.sh

    echo

    source install_layout_select.sh

    echo

    source install_service.sh

    echo

    echo "Installation finished succesfully"

    echo

    read -r -p "Reboot is required. Do you want reboot now? [y/N]" response
    case "$response" in [yY][eE][sS]|[yY])
        reboot
        ;;
    *)
        ;;
    esac

    echo

    exit 0
} 2>&1 | sudo tee "$LOGS_INSTALL_LOG_FILE_PATH"
