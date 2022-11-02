#!/usr/bin/env python3
"""Receives PETG intel and prints it to command line."""
import pyrohelper
import Pyro4

@Pyro4.expose
class Receiver:
    def ping(self):
        return True

    def recv(self, msg):
        print(msg)

rcv = Receiver()
pyrohelper.host_named_server(rcv, "petgReceiver")
