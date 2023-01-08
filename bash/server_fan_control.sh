#!/bin/bash

function install_dependencies(){
  apt update
  apt install -y ipmitool
}

function set_fan_speed(){
  # Take ownership of fans
  sudo ipmitool raw 0x30 0x30 0x01 0x00
  # Set fan speed
  sudo ipmitool raw 0x30 0x30 0x02 0xff 0x14
}

set_fan_speed
