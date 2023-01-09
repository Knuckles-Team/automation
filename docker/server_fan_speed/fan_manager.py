#!/bin/env python3

import os
import sys
import getopt
import json
import time


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


def determine_fan_level(temperature: int, minimum_temperature: int, maximum_temperature: int, minimum_fan_speed: int,
                        maximum_fan_speed: int, temperature_power: int):
    x = min(1, max(0, (temperature - minimum_temperature) / (maximum_temperature - minimum_temperature)))
    fan_level = int(
        min(
            maximum_fan_speed,
            max(minimum_fan_speed, pow(x, temperature_power)*(maximum_fan_speed-minimum_fan_speed) + minimum_fan_speed)
        )
    )
    print(f'Current Fan Speed: {fan_level}')
    return fan_level


def set_fan(fan_level: int):
    # manual fan control
    cmd = f"ipmitool raw 0x30 0x30 0x01 0x00"
    os.system(cmd)
    # set fan level
    cmd = f"ipmitool raw 0x30 0x30 0x02 0xff {hex(fan_level)}"
    #print(f"Running: \n{cmd}")
    os.system(cmd)


def run_service(temperature_poll_rate: int = 24, minimum_fan_speed: int = 5, maximum_fan_speed: int = 100,
                minimum_temperature: int = 50, maximum_temperature: int = 80, temperature_power: int = 5):
    while True:
        cpu_temperature = get_temp()
        fan_level = determine_fan_level(temperature=cpu_temperature, minimum_temperature=minimum_temperature,
                                        maximum_temperature=maximum_temperature, minimum_fan_speed=minimum_fan_speed,
                                        maximum_fan_speed=maximum_fan_speed, temperature_power=temperature_power)
        set_fan(fan_level)
        time.sleep(temperature_poll_rate)


def usage():
    print(f"Usage: \n"
          f"-h | --help      [ See usage for fan-speed ]\n"
          f"-i | --intensity [ Intensity of Fan Speed - Scales Logarithmically (0-10) ]\n"
          f"-c | --cold      [ Minimum Temperature for Fan Speed ]\n"
          f"-w | --warm      [ Maximum Temperature for Fan Speed ]\n"          
          f"-s | --slow      [ Minimum Fan Speed ]\n"
          f"-f | --fast      [ Maximum Fan Speed ]\n"
          f"-p | --poll-rate [ Poll Rate for CPU Temperature in Seconds ]\n"
          f"\nExample: \n\t"
          f"fan-manager --intensity 5 --cold 50 --warm 80 --slow 5 --fast 100 --poll-rate 24\n")


def systems_manager(argv):
    temperature_poll_rate = 24  # How many seconds to wait before polling the CPU temperature again
    minimum_fan_speed = 5
    maximum_fan_speed = 100

    minimum_temperature = 50  # fans at min at this temp
    maximum_temperature = 80  # fans at max at this temp

    temperature_power = 5  # decrease for cooler server + louder, increase for it to be quieter + hotter

    try:
        opts, args = getopt.getopt(argv, "hcsf:i:p:w:",
                                   ["help", "cold=", "fast=", "slow=", "intensity=", "poll-rate=", "warm="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-c", "--cold"):
            minimum_temperature = arg
        elif opt in ("-i", "--intensity"):
            temperature_power = arg
        elif opt in ("-f", "--fast"):
            maximum_fan_speed = arg
        elif opt in ("-p", "--poll-rate"):
            temperature_poll_rate = arg
        elif opt in ("-s", "--slow"):
            minimum_fan_speed = arg
        elif opt in ("-u", "--update"):
            update = True
        elif opt in ("-t", "--theme"):
            maximum_temperature = arg

    run_service(temperature_poll_rate=temperature_poll_rate, minimum_fan_speed=minimum_fan_speed,
                maximum_fan_speed=maximum_fan_speed, minimum_temperature=minimum_temperature,
                maximum_temperature=maximum_temperature, temperature_power=temperature_power)


def main():
    if len(sys.argv) < 2:
        usage()
        sys.exit(2)
    systems_manager(sys.argv[1:])


if __name__ == "__main__":
    if len(sys.argv) < 2:
        usage()
        sys.exit(2)
    systems_manager(sys.argv[1:])

