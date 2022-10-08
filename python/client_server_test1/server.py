import socket

mysocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
buffer_size = 1024
text = "Hello, World!"
mysocket.bind(('127.0.0.1', 9879))
mysocket.listen(5)
(client, (ip,port)) = mysocket.accept()
print(client, port)
client.send(b"knock knock knock, I'm the server")
data = client.recv(buffer_size)
print("DATA", data.decode())
mysocket.close()
