import socket
import sys


def Main():
    host = sys.argv[1]
    #host = '10.0.0.140'
    port = 5021
    print("Creating Server Socket")
    s = socket.socket()
    print(f"Binding Host: {host} Port: {port}")
    s.bind((host, port))

    print("Listening")
    s.listen(1)
    print("Accepting Connections")
    c, addr = s.accept()
    print(f"Accepted: {c} from {addr}")
    while True:
        data = c.recv(1024)
        if not data:
            break
        #data = str(data).upper()
        c.send(data)
        print(f"DATA: {data}")
    c.close()
    print("Closing Server Socket")


if __name__ == '__main__':
    Main()
