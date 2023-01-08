#!/bin/env python3

import os
import json
import time

tempurature_poll_rate = 24 # How many seconds to wait before polling the CPU temperature again
minimum_fan_speed = 5
maximum_fan_speed = 100

minimum_temperature = 50 # fans at min at this temp
maximum_temperature = 80 # fans at max at this temp

temperature_power = 6 # decrease for cooler server, increase for quiter

def get_temp():
    sensors = json.loads(os.popen('/usr/bin/sensors -j').read())
    temp0 = 21
    temp1 = 21
    if 'coretemp-isa-0000' in sensors:
        highest_temp = 0
        for key in sensors["coretemp-isa-0000"].keys():
            if 'Core' in sensors["coretemp-isa-0000"][key]:
                for temp_key in sensors["coretemp-isa-0000"][key].keys():
                    if '_input' in temp_key:
                        temp0 = sensors["coretemp-isa-0000"][key][temp_key]
                        if temp0 > highest_temp:
                            highest_temp = temp0
                            print(f"Reached new highest tempurature of: {highest_temp}")
    if 'coretemp-isa-0001' in sensors:
        highest_temp = 0
        for key in sensors["coretemp-isa-0001"].keys():
            if 'Core' in sensors["coretemp-isa-0001"][key]:
                for temp_key in sensors["coretemp-isa-0001"][key].keys():
                    if '_input' in temp_key:
                        temp1 = sensors["coretemp-isa-0001"][key][temp_key]
                        if temp1 > highest_temp:
                            highest_temp = temp1
                            print(f"Reached new highest tempurature of: {highest_temp}")
    return max(temp0, temp1)

def determine_fan_level(temp):
    x = min(1, max(0, (temp - minimum_temperature) / (maximum_temperature - minimum_temperature)))
    return int(min(maximum_fan_speed, max(minimum_fan_speed, pow(x, temperature_power)*(maximum_fan_speed-minimum_fan_speed) + minimum_fan_speed)))

def set_fan(fan_level):
    # manual fan control
    os.system("ipmitool raw 0x30 0x30 0x01 0x00")
    # set fan level
    cmd = "ipmitool raw 0x30 0x30 0x02 0xff " + hex(fan_level)
    os.system(cmd)

if __name__ == "__main__":
    while True:
        temp = get_temp()
        fan = determine_fan_level(temp)
        print(f"CPU Temperature: {temp} Fan Level: {fan}")
        set_fan(fan)
        time.sleep(tempurature_poll_rate)