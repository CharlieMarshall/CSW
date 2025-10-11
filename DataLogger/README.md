# CSW - DataLogger

Read data from an Omron PLC and log it.
Generate analysis and visualisations of the data using Gnuplot.

## Description

This program uses NodeJS to read data from an Omron PLC.
The main script, bin/readPLC.js, was originally scheduled via a cron job every 15 minutes to record all monitoring data.

This data was written to two main log files:

    logs/load_log.txt
    logs/panel_log.txt

Other cron jobs monitored a mailbox for email attachments, parsed them for key data, and stored them in log files — for example:

    bin/getEmails.sh

This script then triggered additional parsers for each attachment type, generating logs such as:

    lab_log.txt
    orders.txt
    CostSummary.txt

A Bootstrap-based web interface (running on an Apache server) executed most of the scripts.
It read data from the PLC in real time using bin/cswJson.js.
Several scripts generated HTML tables and .dat files used by Gnuplot to produce graphs.

## Example Workflow

1. Load the webpage in a browser:
   - var/www/html/index.php (PLC read-only)
   - var/www/html/op.php (PLC read/write)

2. Loading these PHP pages triggered multiple nested scripts, for example:
   - bin/index.sh → launched other scripts that produced .dat files and .svg graphs via Gnuplot
   - dist/js/index.js → interacted with:
     - fins.php → read PLC data and populated HTML elements
       - bin/cswJson.js → fetched real-time PLC data and output JSON
     - getShellData.php
     - getForecast.php
     - getLoadsByDay.php
     - getTankGraph.php
     - getFlowRate.php

## Usage

This project is intended as a code sample and technical demonstration rather than a production-ready system.
These files are provided to showcase my work rather than form a complete working system.

To experiment with the scripts, add the bin directory to your $PATH and export the following variables
(replace install_Dir with the path to your installation):

    export LOGS_DIR=install_Dir/logs
    export WEB_SERVER_DIR=install_Dir/var/www/html

The logs directory contains sample data (sanitised of any sensitive information) so the shell scripts can still function fully.

When executed, the scripts will create:
- .dat files in $LOGS_DIR
- .svg files in ${WEB_SERVER_DIR}/Images

## Dependencies

Communication with the PLC (via the NodeJS scripts) requires the following library:

    https://github.com/ptrks/node-omron-fins

Note: I modified this library to enable reading individual bits from the PLC — this change has since been merged into the master branch.

## Web Interface Setup

To get the web interface running, update the following lines in
/var/www/html/header.php with the correct path:

    define('LOGS_DIR', 'CSW/DataLogger/logs');
    define('SCRIPTS_DIR', 'CSW/DataLogger/bin');

NodeJS scripts will also need updated paths, as hardcoded directories have been replaced with environment variables such as $LOGS_DIR.
