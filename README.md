# CSW Automation Project

Collection of my scripting work for CSW

## Description

This project has now been mothballed and therefore I have uploaded it to GitHub as a personal reference (backup) and to showcase my work. All sensitive information has been removed. 

The project comprised of 3 devices (see the readme within in project for more details):

### Gate: An access control system for our electric sliding gate.
  It comprised of a Raspberry Pi with a GSM Hat. The GPIO pins of the Pi were connected to a 5v relay which allowed us to open and close our electric sliding gate.
  Mgetty was used to handle the phone calls and caller ID. We then used scripts to handle logging and notifications of access

### LED: An rgb-LED connected to a Raspberry Pi via its GPIO pins
  The LED displayed Load numbers and parking instructions to the lorry drivers to inform them which loading bay to park in on site.
  It read the memory locations, via a nodeJS script, of the onsite PLC to retrieve this data

### DataLogger: The bulk of this project.
  This device read from the PLC every 15 minutes and recording critical data into log files. It was running a PHP server with an Intranet to allow us to 
  read / write to the PLC. Some of its functions were:

* Check product specification
* Parse log files into HTML table and dat files for gnuplot
* Scan incoming emails and parse attachments into logs
* Send out daily snapshots and product release via email

## Dependencies

There were dependencies when in production, for example for the rgb-led and the GSM Pi Hat and gnuplot to name a few, but for testing the log scripts there are sample log files in each project

## Author

Me: Charlie Marshall
