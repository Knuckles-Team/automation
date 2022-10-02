import socket
import sys
socket.setdefaulttimeout(20.0)

def Main():
    host = sys.argv[1]
    #host = '10.0.0.140'
    port = 5353
    print("Checking Ports")
    #check_socket(host, port)

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


def check_socket(host, port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        if sock.connect_ex((host, port)) == 0:
            print("Port is open")
        else:
            print("Port is not open")


if __name__ == '__main__':
    Main()
