import socket
import sys


def Main():
    #host = '10.0.0.140' #The host on your client needs to be the external-facing IP address of your router. Obtain it from here https://www.whatismyip.com/
    host = sys.argv[1]
    port = 80
    print("Creating Socket")
    s = socket.socket()
    # sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # result = sock.connect_ex((host,port))
    # if result == 0:
    #     print("Port is open")
    # else:
    #     print(f"Port is not open: {str(result)}")
    #     sys.exit(2)
    # sock.close()
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
