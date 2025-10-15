# CSW Gate

Access control for our electric gate

## Description

This program ran on a Raspberry Pi with a GSM Hat. The GPIO pins of the Pi were connected to a 5v relay which allowed us to open and close our electric sliding gate. 
Mgetty was used to handle the phone calls and caller ID. We then used scripts to handle logging and notifications of access

## Dependencies

The GMS pi HAT required the IteadSim800 library: https://github.com/lamondlab/IteadSIM800
mgetty - for the caller ID

## Author

Me: Charlie Marshall
