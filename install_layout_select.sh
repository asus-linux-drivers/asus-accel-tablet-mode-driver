#!/usr/bin/env bash

source non_sudo_check.sh

echo "Select layout:"
echo
PS3="Please enter your choice "
OPTIONS=($(ls conf) "Quit")
select SELECTED_OPT in "${OPTIONS[@]}"; do
    if [ "$SELECTED_OPT" = "Quit" ]; then
        exit 0
    fi

    for OPTION in $(ls conf); do
        if [ "$OPTION" = "$SELECTED_OPT" ]; then
            LAYOUT_NAME=${SELECTED_OPT::-3}
            break
        fi
    done

    if [ -z "$LAYOUT_NAME" ]; then
        echo "invalid option $REPLY"
    else
        break
    fi
done

echo

echo "Selected key layout: $LAYOUT_NAME"