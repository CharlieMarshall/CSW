#!/bin/bash

echo -e "Please select an option:\n1: Reboot\n2: Shutdown"
read -r option

if [[ $option -eq 1 ]]
then
  echo "Rebooting..."
  powerOnGSM.py && sudo reboot
elif [[ $option -eq 2 ]]
then
  echo "Shutting down..."
  powerOnGSM.py && sudo halt
else
  echo "Unrecognised option, exiting"
  exit 10;
fi
