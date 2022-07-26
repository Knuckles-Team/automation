#!/usr/bin/python3

import socket
from multiprocessing import Pool
import time


# List of IPs/Ports to test. To add a new one: ["<IP or website>", "<Port>"]
firewall_ips = [ ["galaxy.ansible.com", "443"], ["galaxy.ansible.com", "80"],
                 ["us-docker.pkg.dev", "443"], ["us-docker.pkg.dev", "80"],
                 ["archive.ubuntu.com", "443"], ["archive.ubuntu.com", "80"],
                 ["docker.io", "443"], ["docker.com", "443"], ["googleapis.com", "443"]]


# This function will check the IP/Ports to verify they are open
def firewall_check(ip_info_list):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    socket.setdefaulttimeout(2.0)
    try:
        result = sock.connect_ex((f'{ip_info_list[0]}', int(ip_info_list[1])))
        if result == 0:
            print(f"Open >   Address: {ip_info_list[0]}\tPort: {ip_info_list[1]}".expandtabs(24))
        else:
            print(f"Closed > Address: {ip_info_list[0]}\tPort: {ip_info_list[1]}".expandtabs(24))
    except Exception:
        print(f"Error >  Address: {ip_info_list[0]}\tPort: {ip_info_list[1]}".expandtabs(24))
    sock.close()


print("Checking Addresses with Port\n")
t = time.time()
pool = Pool(processes=4)
results = pool.map(firewall_check, firewall_ips)
elapsed_time = time.time() - t
format_time = time.strftime("%H:%M:%S", time.gmtime(elapsed_time))
print(f"Execution time: {format_time}")

