#!/usr/bin/env python3
import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(17,GPIO.OUT)
print("Changing power state of GSM modem")
GPIO.output(17,GPIO.HIGH)
time.sleep(3)
GPIO.output(17,GPIO.LOW)
GPIO.cleanup()
