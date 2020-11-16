#!/bin/bash

sudo apt update
sudo apt install android-tools-adb android-tools-fastboot -y

adb version
