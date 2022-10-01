#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket
import os
import urllib.request
import sys
import getopt
import time


class FTP:
    def __init__(self, sender_ip_address=None, port=12345):\
        self.sender_ip_address = sender_ip_address
        self.port = port
        self.internal_ip = ""
        self.external_ip = ""
        self.generate_ips()
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    def send(self, file):
        self.socket.bind(("", self.port))  # if the clients/server are on different network you shall bind to ('', port)
        self.socket.listen(10)
        print("Initiating file sending")
        connection, address = self.socket.accept()
        print(f'{address} connected.')
        open_file = open(file, "rb")
        file_size = os.path.getsize(file)
        file_bytes = open_file.read(file_size)
        connection.send_all(file_bytes)
        open_file.close()
        print("Done sending!")

    def receive(self, file):
        attempts = 1
        while attempts <= 3:
            try:
                self.socket.connect((self.external_ip,
                                     self.port))  # here you must past the public external ipaddress of the server machine, not that local address
            except Exception as e:
                if attempts == 3:
                    print(
                        f"Unable to connect to Sender. Max Attempts Reached. \n\tError: {e} \n\tAttempts: ({attempts})")
                    sys.exit(2)
                else:
                    print(f"Unable to connect to Sender. Trying again... \n\tError: {e} \n\tAttempt: ({attempts})")
            time.sleep(6)
            attempts = attempts + 1
        open_file = open(file, "wb")
        print(f"Initiating file download from: {self.sender_ip_address}")
        while True:
            file_bytes = self.socket.recv(1024)
            data = file_bytes
            if file_bytes:
                while file_bytes:
                    file_bytes = self.socket.recv(1024)
                    data += file_bytes
                else:
                    break
        open_file.write(data)
        open_file.close()
        print("Done receiving!")

    def get_internal_ip(self):
        return self.internal_ip

    def get_external_ip(self):
        return self.external_ip

    def get_port(self):
        return self.port

    def set_port(self, port):
        self.port = port

    def generate_ips(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(0)
        try:
            s.connect(('10.254.254.254', 1))
            ip = s.getsockname()[0]
        except Exception:
            ip = '127.0.0.1'
        finally:
            s.close()
        self.internal_ip = ip
        self.external_ip = urllib.request.urlopen('https://ident.me').read().decode('utf8')


def usage():
    print("Usage:\npyftp --action '<send/receive>' --file '/home/user/Downloads/document.txt' --port '65456'")


def pyftp(argv):
    action = ""
    file = ""
    port = 59630
    sender_ip_address = ""

    try:
        opts, args = getopt.getopt(argv, "ha:f:i:p:", ["help", "action=", "file=", "ip-address=", "port="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-a", "--action"):
            action = arg
        elif opt in ("-f", "--file"):
            file = arg
        elif opt in ("-i", "--ip-address"):
            sender_ip_address = arg
        elif opt in ("-p", "--port"):
            try:
                port = int(arg)
            except Exception as e:
                print(f"Port should be an integer value in the range of 0-65356\nError: {e}")
                usage()
                sys.exit(2)
            if 0 > port > 65356:
                print("Port must be between 0-65356")
                usage()
                sys.exit(2)

    if action == "send":
        if not os.path.exists(file):
            print("File not found")
            usage()
            sys.exit(2)
        sender = FTP(port=port)
        print(f"Sender Internal IP Address: {sender.get_internal_ip()}\n"
              f"Sender External IP Address: {sender.get_external_ip()}")
        sender.send(file)

    elif action == "receive":
        if sender_ip_address == "":
            print(f"Did not enter a valid IP Address: {sender_ip_address}")
            usage()
            sys.exit(2)
        receiver = FTP(sender_ip_address=sender_ip_address, port=port)
        print(f"Reciever Internal IP Address: {receiver.get_internal_ip()}\n"
              f"Reciever External IP Address: {receiver.get_external_ip()}")
        receiver.receive(file)


if __name__ == "__main__":
    if len(sys.argv) < 1:
        usage()
        sys.exit(2)
    pyftp(sys.argv[1:])
