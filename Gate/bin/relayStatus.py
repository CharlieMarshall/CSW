#!/usr/bin/env python3
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(4,GPIO.IN)
GPIO.input(4)

relay = GPIO.input(4)  # Returns 0 if OFF or 1 if ON

if relay:
  print("Gate is opening or the relay is stuck"),
else:
  print("Gate is closed"),

GPIO.cleanup()
