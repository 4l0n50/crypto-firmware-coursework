#!/usr/bin/env python3
import serial
import sys
import platform

speed = 38400
speed = 9600
if platform.system() == "Darwin":
    dev = serial.Serial("/dev/tty.usbserial-0001", speed)
else:
    dev = serial.Serial("/dev/ttyUSB0", speed)

print("> Returned data:", file=sys.stderr)

while True:
    x = dev.read()
    sys.stdout.buffer.write(x)
    sys.stdout.flush()
