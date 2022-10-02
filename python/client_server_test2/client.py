import socket
import sys


def Main():
    #host = '10.0.0.140' #The host on your client needs to be the external-facing IP address of your router. Obtain it from here https://www.whatismyip.com/
    host = sys.argv[1]
    port = 42424
    s = socket.socket()
    s.connect((host,port))
    message = raw_input("->")
    while message != 'q':
        s.send(message)
        data = s.recv(1024)
        message = raw_input("->")
    s.close()


if __name__ == '__main__':
    Main()
