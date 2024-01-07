#!/usr/bin/env python3

import sys
import importlib
import logging
import os
from typing import Optional
from libevdev import Device, EV_SW, EV_KEY, EV_SYN, InputEvent
from time import sleep
import subprocess

logging.basicConfig(
    format='%(asctime)s %(levelname)-8s %(message)s',
    level=os.environ.get('LOG', 'INFO')
)
log = logging.getLogger('Asus Accel Tablet Mode Driver')

# https://github.com/ejtaal/scripts/blob/fe16a68b8ce3d1f95a2c855dd8b52903600b462f/yoga-2-11-rotate.py

# UN5401QAB_UN5401QA:
#
# 2024-01-07 19:36:22,134 INFO     E: DRIVER=hid_sensor_accel_3d
# 2024-01-07 19:36:22,962 INFO     E: MODALIAS=platform:HID-SENSOR-200073
# 2024-01-07 19:36:23,811 INFO     E: USEC_INITIALIZED=6069275
# 2024-01-07 19:36:24,235 INFO     E: ID_PATH=platform-HID-SENSOR-200073.1.auto
# 2024-01-07 19:36:24,710 INFO     E: ID_PATH_TAG=platform-HID-SENSOR-200073_1_auto
# 2024-01-07 19:36:25,363 INFO     
# 2024-01-07 19:36:26,326 INFO     P: /devices/0020:1022:0001.0001/HID-SENSOR-200073.1.auto/iio:device0
# 2024-01-07 19:36:26,868 INFO     N: iio:device0
# 2024-01-07 19:36:27,315 INFO     L: 0
# 2024-01-07 19:36:27,823 INFO     E: DEVPATH=/devices/0020:1022:0001.0001/HID-SENSOR-200073.1.auto/iio:device0
# 2024-01-07 19:36:28,302 INFO     E: SUBSYSTEM=iio
# 2024-01-07 19:37:36,067 INFO     E: DEVNAME=/dev/iio:device0
# 2024-01-07 19:37:36,802 INFO     E: DEVTYPE=iio_device
# 2024-01-07 19:37:58,027 INFO     E: MAJOR=511
# 2024-01-07 19:37:58,679 INFO     E: MINOR=0
# 2024-01-07 19:37:59,236 INFO     E: USEC_INITIALIZED=6165210
# 2024-01-07 19:37:59,902 INFO     E: IIO_SENSOR_PROXY_TYPE=iio-poll-accel iio-buffer-accel
# 2024-01-07 19:38:06,034 INFO     E: SYSTEMD_WANTS=iio-sensor-proxy.service
# 2024-01-07 19:38:07,557 INFO     E: TAGS=:systemd:
# 2024-01-07 19:38:08,791 INFO     E: CURRENT_TAGS=:systemd:
# 2024-01-07 19:38:09,620 INFO     
# 2024-01-07 19:38:10,450 INFO     P: /devices/0020:1022:0001.0001/HID-SENSOR-200073.1.auto/trigger0
# 2024-01-07 19:38:12,734 INFO     L: 0
# 2024-01-07 19:38:13,388 INFO     E: DEVPATH=/devices/0020:1022:0001.0001/HID-SENSOR-200073.1.auto/trigger0
# 2024-01-07 19:38:16,206 INFO     E: SUBSYSTEM=iio
# 2024-01-07 19:38:16,858 INFO

accel_detected = 0
accel_device_dir_path: Optional[str] = None

cmd = ["udevadm", "info", "--export-db"]
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
for bytes_line in proc.stdout.readlines():
    try:
        line = bytes_line.decode("utf-8")
    except UnicodeDecodeError:
        log.error("Output of udevadm info --export-db has invalid (non utf-8) characters")
        exit(1)

    if accel_detected == 0 and "accel" in line:
        accel_detected = 1

    if accel_detected == 1:
        if "P: " in line:
            accel_device_dir_path = "/sys" + line.split(" ")[1].replace("\n", "")
            accel_detected = 2
            break

if accel_detected != 2:
    log.error("Can't find accel sensor (code: %s)", accel_detected)
    sys.exit(1)
if accel_detected == 2 and not accel_device_dir_path:
    log.error("Can't find accel sensor device path")
    sys.exit(1)


# Layout
layout = 'default'
if len(sys.argv) > 1:
    layout = sys.argv[1]
try:
    layout = importlib.import_module('conf.' + layout)
except:
    log.error("Layout *.py from dir conf is required as first argument. Re-run install script or add missing first argument (valid value is default, ..).")
    sys.exit(1)


def isEventKey(key):
    if hasattr(key, "name") and hasattr(EV_KEY, key.name):
        return True
    elif hasattr(key, "name") and hasattr(EV_SW, key.name):
        return True
    return False


def isEventInput(event):
    if hasattr(event, "code") and isEventKey(event.code):
        return True
    return False


dev = Device()
dev.name = "Asus WMI accel tablet mode"

for key_to_enable in layout.flip_keys:
    if isEventKey(key_to_enable):
        dev.enable(key_to_enable)
for event_to_enable in layout.laptop_mode_events:
    if isEventInput(event_to_enable):
        dev.enable(event_to_enable.code)
for event_to_enable in layout.tablet_mode_events:
    if isEventKey(event_to_enable):
        dev.enable(event_to_enable.code)

# Sleep for a bit so udev, libinput, Xorg, Wayland, ... all have had
# a chance to see the device and initialize it. Otherwise the event
# will be sent by the kernel but nothing is ready to listen to the
# device yet
udev = dev.create_uinput_device()
sleep(1)


def flip(tablet_mode):

    keys_to_send_press_events = []
    keys_to_send_release_events = []
    events_to_send = []

    # Keys
    for keys_to_send_press in layout.flip_keys:
        if isEventKey(keys_to_send_press):
            keys_to_send_press_events.append(InputEvent(keys_to_send_press, 1))
    for keys_to_send_release in layout.flip_keys:
        if isEventKey(keys_to_send_release):
            keys_to_send_release_events.append(InputEvent(keys_to_send_release, 0))

    # Events
    if tablet_mode:
        for event_to_send in layout.tablet_mode_events:
            if isEventInput(event_to_send):
                events_to_send.append(event_to_send)
    else:
        for event_to_send in layout.laptop_mode_events:
            if isEventInput(event_to_send):
                events_to_send.append(event_to_send)

    # Sync event
    sync_event = [
        InputEvent(EV_SYN.SYN_REPORT, 0)
    ]

    try:
        udev.send_events(keys_to_send_press_events)
        udev.send_events(sync_event)
        udev.send_events(keys_to_send_release_events)
        udev.send_events(sync_event)
        udev.send_events(events_to_send)
        udev.send_events(sync_event)
    except OSError as e:
        log.error("Cannot send event, %s", e)


def read_accel_file(name):
    fp = open(os.path.join(accel_device_dir_path, name))
    fp.seek(0)
    return float(fp.read()) #* 1 # TODO: * scale?

tablet_mode = False

while True:
    x = read_accel_file("in_accel_x_raw")
    y = read_accel_file("in_accel_y_raw")
    z = read_accel_file("in_accel_z_raw")

    criterium_for_accel_be_recognized_as_tablet_mode = ((x >= -5 and x <= 5) and (y >= -5 and y <= 5) and z <= -9) # TODO: add better recognition, probably inverted check? Or something more sofistikated with movement trace?

    # Call only once when is state changed
    if criterium_for_accel_be_recognized_as_tablet_mode and tablet_mode is False:
        tablet_mode = True
        flip(tablet_mode)
        log.info("Flip to tablet mode")
    elif not criterium_for_accel_be_recognized_as_tablet_mode and tablet_mode is True:
        tablet_mode = False
        flip(tablet_mode)
        log.info("Flip to laptop mode")

    sleep(0.5)