#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket
import os
import urllib.request
import sys
import getopt

class Sender:
    def __init__(self, port=12345):
        self.port = port
        self.external_ip = urllib.request.urlopen('https://ident.me').read().decode('utf8')
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.bind(("", self.port)) #if the clients/server are on different network you shall bind to ('', port)
        self.socket.listen(10)

    def send(self, file):
        print("Initiating file sending")
        connection, address = self.socket.accept()
        print(f'{address} connected.')
        open_file = open(file, "rb")
        file_size = os.path.getsize(file)
        file_bytes = open_file.read(file_size)
        connection.send_all(file_bytes)
        open_file.close()
        print("Done sending!")

    def get_external_ip(self):
        return self.external_ip

    def get_port(self):
        return self.port

    def set_port(self, port):
        self.port = port


class Receiver:
    def __init__(self, port=12345):
        self.port = port
        self.external_ip = urllib.request.urlopen('https://ident.me').read().decode('utf8')
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            self.socket.connect((self.external_ip, self.port)) # here you must past the public external ipaddress of the server machine, not that local address
        except Exception as e:
            print(f"Unable to connect to Sender. \nError: {e}")

    def receive(self, file):
        open_file = open(file, "wb")
        print("Initiating file download")
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

    def get_external_ip(self):
        return self.external_ip

    def get_port(self):
        return self.port

    def set_port(self, port):
        self.port = port


def usage():
    print("Usage:\npyftp --action '<send/receive>' --file '/home/user/Downloads/document.txt' --port '65456'")


def pyftp(argv):
    action = ""
    file = ""
    port = 59630

    try:
        opts, args = getopt.getopt(argv, "ha:f:p:", ["help", "action=", "file=", "port="])
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
        sender = Sender(port=port)
        print(f"Sender IP Address: {sender.get_external_ip()}")
        sender.send(file)

    elif action == "receive":
        receiver = Receiver(port=port)
        print(f"Reciever IP Address: {receiver.get_external_ip()}")
        receiver.receive(file)


if __name__ == "__main__":
    if len(sys.argv) < 1:
        usage()
        sys.exit(2)
    pyftp(sys.argv[1:])
