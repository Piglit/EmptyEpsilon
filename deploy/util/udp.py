import socketserver
import struct
import socket
import threading
import time

port = 35666
magicNumber = 0x2fab3f0f
versionNumber = 20200708
header = struct.pack(">ii", magicNumber, versionNumber)
serverName = "test"
interval = 5

def sendDiscoveryPacket(sock, address):
    size = len(serverName)
    data = header + struct.pack(">i{}s".format(size), size, serverName.encode("ascii"))
    sock.sendto(data, address)

class UDPBroadcastHandler(socketserver.BaseRequestHandler):
    def handle(self):
        #print("rcv", self.client_address)
        #data = self.request[0]
        #a,b,c = struct.unpack_from(">iii",data)
        #print(a,b,c,data[12:])
        sock = self.request[1]
        sendDiscoveryPacket(sock, self.client_address)

def broadcast():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.setblocking(0)
    while(True):
        #print("snd")
        sendDiscoveryPacket(sock, ("<broadcast>", port+1))
        time.sleep(interval)
        
looper = threading.Thread(target=broadcast)
looper.start()

with socketserver.UDPServer(("", port), UDPBroadcastHandler) as server:
    server.serve_forever()

