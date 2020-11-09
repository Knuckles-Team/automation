#!/bin/bash

# This will set the default audio device to be line-out
# Open "Startup Applications" and add the following application:
pactl set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
