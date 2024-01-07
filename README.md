# Asus Accel Tablet Mode Driver

[![License: GPLv2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
![Maintainer](https://img.shields.io/badge/maintainer-ldrahnik-blue)
[![GitHub Release](https://img.shields.io/github/release/asus-linux-drivers/asus-accel-tablet-mode-driver.svg?style=flat)](https://github.com/asus-linux-drivers/asus-accel-tablet-mode-driver/releases)
[![GitHub commits](https://img.shields.io/github/commits-since/asus-linux-drivers/asus-accel-tablet-mode-driver/v0.0.1.svg)](https://GitHub.com/asus-linux-drivers/asus-accel-tablet-mode-driver/commit/)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fasus-linux-drivers%2Fasus-fliplock-driver&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

The driver is written in python and runs as a systemctl service. TODO:

If you find this project useful, please do not forget to give it a [![GitHub stars](https://img.shields.io/github/stars/asus-linux-drivers/asus-numberpad-driver.svg?style=social&label=Star&maxAge=2592000)](https://github.com/asus-linux-drivers/asus-accel-tablet-mode-driver/stargazers) People already did!

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## Features

- TODO:


## Installation

Get latest dev version using `git`

```bash
$ git clone https://github.com/asus-linux-drivers/asus-accel-tablet-mode-driver
$ cd asus-accel-tablet-mode-driver
```

and install

```bash
$ bash install.sh
```

or run separately parts of the install script

- run notifier every time when the user log in (do NOT run as `$ sudo`, works via `systemctl --user`)

```bash
$ bash install_service.sh
```

## Uninstallation

To uninstall run

```bash
$ bash uninstall.sh
```

or run separately parts of the uninstall script

```bash
$ bash uninstall_service.sh
```

**Troubleshooting**

To activate logger, do in a console:
```
LOG=DEBUG sudo -E ./asus_accel_driver.py "default"
```

**Why was this project created?** For laptops which do not indicate tablet modes (e.g. `UN5401QAB_UN5401QA` does not send `EV_SW.SW_TABLET_MODE` or `EV_KEY.KEY_PROG2` neither)