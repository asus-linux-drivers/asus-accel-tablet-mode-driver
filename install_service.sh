#!/usr/bin/env bash

source non_sudo_check.sh

# INHERIT VARS
if [ -z "$CONFIG_FILE_DIR_PATH" ]; then
    CONFIG_FILE_DIR_PATH="/usr/share/asus-accel-tablet-mode-driver"
fi
if [ -z "$LAYOUT_NAME" ]; then
    LAYOUT_NAME="default"
fi
if [ -z "$LOGS_DIR_PATH" ]; then
    LOGS_DIR_PATH="/var/log/asus-accel-tablet-mode-driver"
fi

echo "Systemctl service"
echo

read -r -p "Do you want install systemctl service? [y/N]" RESPONSE
case "$RESPONSE" in [yY][eE][sS]|[yY])

    SERVICE_FILE_PATH=asus_accel_tablet_mode_driver.service
    SERVICE_INSTALL_FILE_NAME="asus_accel_tablet_mode_driver@.service"
    SERVICE_INSTALL_DIR_PATH="/usr/lib/systemd/user"

    DBUS_SESSION_BUS_ADDRESS=$(echo $DBUS_SESSION_BUS_ADDRESS)
    ERROR_LOG_FILE_PATH="$LOGS_DIR_PATH/error.log"

    echo
    echo "LAYOUT_NAME: $LAYOUT_NAME"
    echo
    echo "env var DBUS_SESSION_BUS_ADDRESS: $DBUS_SESSION_BUS_ADDRESS"
    echo
    echo "ERROR LOG FILE: $ERROR_LOG_FILE_PATH"
    echo

    cat "$SERVICE_FILE_PATH" | LAYOUT_NAME=$LAYOUT_NAME DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS ERROR_LOG_FILE_PATH=$ERROR_LOG_FILE_PATH envsubst '$LAYOUT_NAME $DBUS_SESSION_BUS_ADDRESS $ERROR_LOG_FILE_PATH' | sudo tee "$SERVICE_INSTALL_DIR_PATH/$SERVICE_INSTALL_FILE_NAME" >/dev/null

    if [[ $? != 0 ]]; then
        echo "Something went wrong when moving the $SERVICE_FILE_PATH"
        exit 1
    else
        echo "Service $SERVICE_FILE_PATH placed"
    fi

    systemctl --user daemon-reload

    if [[ $? != 0 ]]; then
        echo "Something went wrong when was called systemctl daemon reload"
        exit 1
    else
        echo "Systemctl daemon reloaded"
    fi

    systemctl enable --user asus_accel_tablet_mode_driver@$USER.service

    if [[ $? != 0 ]]; then
        echo "Something went wrong when enabling the $SERVICE_FILE_PATH"
        exit 1
    else
        echo "Service $SERVICE_FILE_PATH enabled"
    fi

    systemctl restart --user asus_accel_tablet_mode_driver@$USER.service
    if [[ $? != 0 ]]; then
        echo "Something went wrong when starting the $SERVICE_FILE_PATH"
        exit 1
    else
        echo "Service $SERVICE_FILE_PATH started"
    fi
esac