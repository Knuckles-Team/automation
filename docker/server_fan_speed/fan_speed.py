#!/bin/env python3

import os
import json
import time

tempurature_poll_rate = 24 # How many seconds to wait before polling the CPU temperature again
minimum_fan_speed = 5
maximum_fan_speed = 100

minimum_temperature = 50 # fans at min at this temp
maximum_temperature = 80 # fans at max at this temp

temperature_power = 5 # decrease for cooler server, increase for quiter


def get_core_temp(cpus, sensors):
    highest_temp = 0
    highest_core = 0
    highest_cpu = ""
    cores = 0
    temp_cpu = 0
    for cpu in cpus:
        if cpu in sensors:
            for key in sensors[cpu].keys():
                if 'Core' in key:
                    cores = cores + 1
                    for temp_key in sensors[cpu][key].keys():
                        if '_input' in temp_key:
                            temp_cpu = sensors[cpu][key][temp_key]
                            # print(f"CPU {cpu} - Core {cores} Temperature: {temp_cpu}")
                            if temp_cpu > highest_temp:
                                highest_temp = temp_cpu
                                highest_core = cores
                                highest_cpu = cpu
            temp_cpu = highest_temp
    print(f"Highest \n\tCPU: {highest_cpu} \n\tCore: {highest_core} \n\tTemperature: {highest_temp}")
    return temp_cpu


def get_temp():
    sensors = json.loads(os.popen('sensors -j').read())
    cpus = ['coretemp-isa-0000', 'coretemp-isa-0001']
    temp_cpu = get_core_temp(cpus, sensors)
    print(f'Current Temperature: {temp_cpu}')
    return temp_cpu


def determine_fan_level(temp):
    x = min(1, max(0, (temp - minimum_temperature) / (maximum_temperature - minimum_temperature)))
    fan_level = int(min(maximum_fan_speed, max(minimum_fan_speed, pow(x, temperature_power)*(maximum_fan_speed-minimum_fan_speed) + minimum_fan_speed)))
    print(f'Current Fan Speed: {fan_level}')
    return fan_level


def set_fan(fan_level):
    # manual fan control
    cmd = f"ipmitool raw 0x30 0x30 0x01 0x00"
    os.system(cmd)
    # set fan level
    cmd = f"ipmitool raw 0x30 0x30 0x02 0xff {hex(fan_level)}"
    #print(f"Running: \n{cmd}")
    os.system(cmd)


if __name__ == "__main__":
    while True:
        temp = get_temp()
        fan = determine_fan_level(temp)
        set_fan(fan)
        time.sleep(tempurature_poll_rate)