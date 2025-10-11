#!/usr/bin/env python3
import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(27,GPIO.OUT)
GPIO.output(27,GPIO.HIGH)
time.sleep(1)
GPIO.output(27,GPIO.LOW)
GPIO.cleanup()
