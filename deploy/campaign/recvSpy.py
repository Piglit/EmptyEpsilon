#!/usr/bin/env python3
"""Receives SpySat intel and prints it."""
import pyrohelper
import Pyro4

@Pyro4.expose
class Receiver:
    def ping(self):
        return True

    def recv(self, msg):
        print(msg)  # TODO

rcv = Receiver()
pyrohelper.host_named_server(rcv, "spysatReceiver")
