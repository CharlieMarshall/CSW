#!/usr/bin/env python3
import RPi.GPIO as GPIO
import time

# GPIO PIN 18 should be the reset PIN according to the schematic
# https://www.itead.cc/wiki/images/4/47/IM150720001-Raspberry_PI_GSM_Add-on_V2.0-schematic.pdf

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(18,GPIO.OUT)
print("Changing power state of GSM modem")
GPIO.output(18,GPIO.HIGH)
time.sleep(3)
GPIO.output(18,GPIO.LOW)
GPIO.cleanup()
