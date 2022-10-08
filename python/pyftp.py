#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket
import os
import urllib.request
import sys
import getopt
import time
import requests


class FTP:
    def __init__(self, sender_ip_address=None, type="local", port=9879, buffer_size=1024):
        self.sender_ip_address = sender_ip_address
        self.type = type
        self.port = port
        self.internal_ip = ""
        self.external_ipv4 = ""
        self.external_ipv6 = ""
        self.generate_ips()
        self.socket = None #socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.buffer_size = buffer_size

    def set_sender_socket_configuration(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        if self.type == "local":
            self.socket.bind((self.internal_ip, self.port))  # if the clients/server are on different network you shall bind to ('', port)
        else:
            self.socket.bind(("", self.port))
        self.socket.listen(5)

    def set_receiver_socket_configuration(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        attempts = 1
        while attempts <= 3:
            try:
                self.socket.connect((self.sender_ip_address, self.port))  # here you must past the public external ipaddress of the server machine, not that local address
                attempts = 4
            except Exception as e:
                if attempts == 3:
                    print(f"Unable to connect to Sender. Max Attempts Reached. \n\tError: {e} \n\tAttempts: ({attempts})")
                    sys.exit(2)
                else:
                    print(f"Unable to connect to Sender. Trying again... \n\tError: {e} \n\tAttempt: ({attempts})")
            time.sleep(6)
            attempts = attempts + 1

    def send_number_of_files(self, files):
        self.set_sender_socket_configuration()
        (connection, (ip,port)) = self.socket.accept()
        print(f'Sending Number of Files: {len(files)}')
        connection.send(f"{len(files)}".encode('utf-8'))
        self.socket.close()

    def receive_number_of_files(self):
        self.set_receiver_socket_configuration()
        total_files = self.socket.recv(self.buffer_size)
        total_files = total_files.decode('utf-8')
        self.socket.close()
        print(f'Receiving Number of Files: {total_files}')
        return int(total_files)

    def send_file_name(self, file):
        self.set_sender_socket_configuration()
        (connection, (ip,port)) = self.socket.accept()
        print(f'\tSending File Name: {file}')
        connection.send(f"{file}".encode('utf-8'))
        self.socket.close()

    def receive_file_name(self):
        self.set_receiver_socket_configuration()
        file = self.socket.recv(self.buffer_size)
        file = file.decode('utf-8')
        file = os.path.basename(file)
        original_file = file
        self.socket.close()
        copy = 1
        file_name, file_extension = os.path.splitext(file)
        while os.path.exists(file):
            file = file_name + f"({copy})" + file_extension
            copy = copy + 1
        return file, original_file

    def send(self, file):
        self.send_file_name(file)
        self.set_sender_socket_configuration()
        (connection, (ip,port)) = self.socket.accept()
        print(f'\tSending File Data')
        open_file = open(file, "rb")
        file_size = os.path.getsize(file)
        file_bytes = open_file.read(file_size)
        connection.sendall(file_bytes)
        open_file.close()
        print(f"\tSent: {file} to {ip}")
        self.socket.close()

    def receive(self):
        file, original_file = self.receive_file_name()
        print(f"\tReceiving: {original_file} from: {self.sender_ip_address}")
        self.set_receiver_socket_configuration()
        open_file = open(file, "wb")
        while True:
            file_bytes = self.socket.recv(self.buffer_size)
            data = file_bytes
            if file_bytes:
                while file_bytes:
                    file_bytes = self.socket.recv(self.buffer_size)
                    data += file_bytes
                else:
                    break
        open_file.write(data)
        open_file.close()
        print(f"\tReceived: {original_file}")
        self.socket.close()

    def get_internal_ip(self):
        return self.internal_ip

    def get_external_ip(self):
        return [self.external_ipv4, self.external_ipv6]

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
        self.external_ipv4 = urllib.request.urlopen('https://ident.me').read().decode('utf8')
        self.external_ipv6 = requests.get("https://ident.me", timeout=5).text
        #self.external_ipv6 = result[0][4][0]


def usage():
    print("Usage:\npyftp --action '<send/receive>' --file '/home/user/Downloads/document.txt' --port '65456'")


def pyftp(argv):
    action = ""
    files = []
    file = ""
    port = 59630
    sender_ip_address = ""
    type = "local"

    try:
        opts, args = getopt.getopt(argv, "ha:f:i:p:t:", ["help", "action=", "files=", "ip-address=", "port=", "type="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-a", "--action"):
            action = arg
        elif opt in ("-f", "--files"):
            files = arg.split(",")
            files = files + arg.split(", ")
            for file_index in range(0, len(files)):
                files[file_index] = files[file_index].strip()
            files = list(set(files))
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
        elif opt in ("-t", "--type"):
            type = arg
            if type != "local" and type != "internet":
                print("Type must be local or internet")
                usage()
                sys.exit(2)

    if action == "send":
        print(f"Files to Send: {files}")
        if not os.path.exists(files[0]):
            print("File not found")
            usage()
            sys.exit(2)
        sender = FTP(type=type, port=port)
        print(f"Sender Internal IP Address: {sender.get_internal_ip()}\n"
              f"Sender External IP Address: {sender.get_external_ip()[1]}")
        sender.send_number_of_files(files)
        file_index = 0
        for file in files:
            sender.send(file)
            print(f"\tSent file: {file_index+1} out of {len(files)}")
            file_index = file_index + 1
        print(f"{len(files)} Files Sent!")

    elif action == "receive":
        if sender_ip_address == "":
            print(f"Did not enter a valid IP Address: {sender_ip_address}")
            usage()
            sys.exit(2)
        receiver = FTP(sender_ip_address=sender_ip_address, port=port)
        total_files = receiver.receive_number_of_files()
        for file_index in range(0, total_files):
            receiver.receive()
            print(f"\tReceived file: {file_index+1} out of {total_files}")
        print(f"{total_files} Files Received!")

if __name__ == "__main__":
    if len(sys.argv) < 1:
        usage()
        sys.exit(2)
    pyftp(sys.argv[1:])
