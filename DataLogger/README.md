# CSW - DataLogger

Read from an Omron PLC and log its data

## Description

This program uses nodeJS to reads data from an Omron PLC.
The nodeJS script bin/readPLC.js was originally used in a cron job set to run every 15 minutes to record all monitoring data.
This Data was written to 2 main log files:

	logs/load_log.txt
	logs/panel_log.txt

There were other cron job which checked our Mailbox for email attachements and then parsed them for key data and stored them in log files, such as:

	bin/getEmails.sh

This script then called independent scripts based on the attachments and generated the following logs: lab_log.txt, orders.txt, CostSummary.txt

There was a Bootstrap based web interface running on an Apache server, which executed most of the scripts. Nearly all the scripts use awk to parse the log files
and produce HTML table and .dat files for gnuplot to create graphs

## Usage

The logs directory has sample log data to allow the shell script to still fully function, they have been sanitised of sensitive information.

You will need the following environmental variables:
	export LOGS_DIR=logs
	export WEB_SERVER_DIR=var/www/html

Obviously communicating with the PLC will no longer work and would also require the following git repositories to be installed:

	https://github.com/ptrks/node-omron-fins

I had to modify this library and issue a Pull Request to enable reading bits from the PLC. This has now been merged into master

All the gnuplot commands have been commented out to allow the shell scripts to complete safely in a non production enviromment

Execute a script from the bin directory according to its usage within the file

## Misc

For reference here are the lines per file for the shell scripts:

   242 volumes.sh
   222 tableLabCostsYr.sh
   184 screenshots.sh
   151 json.sh
   137 volumesHomePage.sh
   124 loadSummary.sh
   118 wessexCostSummary.sh
   116 averageFlowRate.sh
   112 tableLabCosts.sh
   107 invoice.sh
   104 emailCofc.sh
    99 intelligentPlanning.sh
    94 wessexExceptionArray.sh
    94 getForecastDataDaily.sh
    91 certSummary.sh
    88 getLabCertsLocal.sh
    84 getEmails.sh
    82 checkBoreholeFlowRate.sh
    81 fillingMode.sh
    79 ecoPlanning.sh
    73 getCallOffLocal.sh
    61 emailSnapshot.sh
    56 storageToJson.sh
    52 getForecastData.sh
    49 monthlyForecast.sh
    48 writeVolShift.sh
    48 writeVolDaily.sh
    47 tableLabResults.sh
    46 weatherAlert.sh
    44 overviewCalloff.sh
    44 loadsByWeek.sh
    41 boreholeElec.sh
    40 systemInfo.sh
    39 openWeather.sh
    38 backup.sh
    38 annualForecast.sh
    35 checkForNewLoad.sh
    32 updateTanker.sh
    31 tableLoads.sh
    31 numLabFailures.sh
    29 overviewCIP.sh
    27 backupWeekly.sh
    26 updateLoad.sh
    24 storageToTable.sh
    23 flowComp.sh
    22 tableTankers.sh
    22 monthlyLabReport.sh
    22 invoiceDetails.sh
    21 restartServer.sh
    20 wessexDeleteException.sh
    17 backupImages.sh
    16 updateOverheads.sh
    16 pushAlarm.sh
    14 push.sh
    14 missingLab.sh
    14 cipdates.sh
    13 releaseLoads.sh
    12 backupDaily.sh
    11 overviewStorage.sh
    11 getCCTVweb.sh
    11 findDuplicateLabSU.sh
    10 getLoad.sh
    10 findLabRetests.sh
     9 solar.sh
     9 overviewLoads.sh
     8 findMissingLoads.sh
     7 overviewPanel.sh
     7 overviewGate.sh
     7 openGate.sh
     7 getTanker.sh
     7 findDuplicateTankers.sh
  3768 total
