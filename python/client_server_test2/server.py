import socket
import sys


def Main():
    host = sys.argv[1]
    #host = '10.0.0.140'
    port = 80
    print("Creating Server Socket")
    s = socket.socket()
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex((host,port))
    if result == 0:
        print("Port is open")
    else:
        print(f"Port is not open: {str(result)}")
        sys.exit(2)
    sock.close()
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
