import socket
import sys


def Main():
    #host = '10.0.0.140' #The host on your client needs to be the external-facing IP address of your router. Obtain it from here https://www.whatismyip.com/
    host = sys.argv[1]
    port = 5353
    print("Creating Socket")
    s = socket.socket()
    print(f"Connecting to host: {host} on port: {port}")
    s.connect((host,port))
    print("Sending Message")
    message = b"TEST MESSAGE SENDING"#.encode('utf-8')
    while message != b"q":
        s.send(message)
        data = s.recv(1024)
        message = b"q"
        print(f"Data: {data}")
    s.close()
    print("Closed socket")


if __name__ == '__main__':
    Main()
