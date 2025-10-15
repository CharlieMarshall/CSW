#!/usr/bin/env node
/*
  readPLC.js — A script to read multiple areas of the PLC. Check for any issues. Append data to the relevant log files
  Usage: node readPLC.js
  Author: Charlie Marshall
  License: MIT
*/

var Push = require('pushover-notifications') // for pushover notifications
var fins = require('omron-fins'); // to communicate with the PLC
/* Connecting to remote FINS client on port 9600 with default timeout value. */
var client = fins.FinsClient(9600, 'ip');
var fs = require('fs');
var tanks = [{}]; // we start at tank 1 so tank 0 is initialised to zero
var points = [];
var replyCounter = 0;
var alarmCounter = 0;
var knownPowerInterrupts = 0; // Number of known power interruptions as entered in H24
var powerInterrupts = 0;
var flowrateError = 0;
var flowComp = 0;

/* Pushover initiator */
var p = new Push({
  user: 'user',
  token: 'token',
  update_sounds: false,
  debug: true,
})

/*
  function to send a push notification alarm
*/

function sendAlarms(title, message) {
  var pushover_msg = {
    sound: 'echo',
    priority: 1,
    title: title,
    message: message
  }
  p.send(pushover_msg);
}

/*
  function to check if a loading tanker has a flowrate.
  Could indicate that a driver forgot to open the tanker valve OR
  Catch and handle, by re reading, the rare ocassion when we read the PLC as a load starts pumping and the flowrate and litres pumped are at 0 but the valve is open
*/

function validateLoadingFlow(callback) {
  var noflows = 0;
  console.log("Checking if a load is loading and its flowrate");

  // note this would not work if both A and B had no flow simutaneously
  for (i = 0; i < 2; i++) {
    if (points[i]['status'] == "LOADING" && points[i]['flowRate'] == 0) {
      console.log("No flow detected");

      if (++flowrateError == 1) { // 1st detection
        noflows++;
        sendAlarms('Flowrate Error', "Attemptying another PLC read to verify\nRemove once this is confirmed working\nError counter: " + flowrateError);
      } else { // We have read the PLC twice and there is still no flowrate
        sendAlarms('Flowrate Error', "Loading with no Flowrate, check tanker valve is open and storage tank levels\nChecked " + flowrateError + " times");
      }
    }
  }
  if (noflows == 1)
    callback("No flowrate detcted once. Issuing an error callback which will cause another PLC read", null);
  else
    callback(null, "Callback Success: Either no issues or we detected no flowrate twice but need to write the data to the log anyway");
}

/*
  function to check for out of spec product and also a power interruption
*/

function pushAlarms() {
  var message = '';

  // loop through both lines and check for out of Specification product
  for (i = 0; i < 2; i++) {
    if (points[i]['ph'] < 7 || points[i]['ph'] > 8) {
      message += points[i]['line'] + ': PH is ' + points[i]['ph'] + '\n';
      alarmCounter++;
    }
    if (points[i]['cond'] < 550 || points[i]['cond'] > 750) {
      message += points[i]['line'] + ': Conductivity is ' + points[i]['cond'] + '\n';
      alarmCounter++;
    }
    if (points[i]['temp'] < 4 || points[i]['temp'] > 22) {
      message += points[i]['line'] + ': Temperature is ' + points[i]['temp'];
      alarmCounter++;
    }
  }
  if (alarmCounter > 0) {
    sendAlarms('Product out of Specification', message);
    alarmCounter = 0;
    message = '';
  }
  // loop through all tanks and check for high and low air pressure
  for (i = 1; i < 4; i++) {
    if (tanks[i]['airPressure'] < -7.5 || tanks[i]['airPressure'] > 5) {
      message += "Tank " + i + ': Air Pressure is ' + tanks[i]['airPressure'] + '\n';
      alarmCounter++;
    }
  }
  if (alarmCounter > 0) {
    sendAlarms('Abnormal Air Pressure Detected', message);
    alarmCounter = 0;
    message = '';
  }

  // check if there has been a change in the number of recorded power intteruptions
  if (powerInterrupts != knownPowerInterrupts) {
    message = 'Action required: Update number of power interruptions\n\nKnown Power Interruptions: ' + knownPowerInterrupts + '\nActual Power Interruptions: ' + powerInterrupts + '\n\nAt the time of the power loss:';

    for (i = 0; i < 2; i++) {
      message += '\n' + points[i]['line'] + ': Load ' + points[i]['loadNo'] + ', lts pumped = ' + points[i]['litresPumped'];

      if (points[i]['litresPumped'] < 29500) {
        message += '\nSet ' + points[i]['line'] + ' fill level to: ' + (29500 - points[i]['litresPumped']);
      }
    }
    sendAlarms('Power Interruption Detected', message);
  }

  // check for a high tank level, fail safe in case the Ultrasonic sensor has failed!
  message = '';
  for (i = 1; i < 4; i++) {
    if (tanks[i]['level'] > 112) {
      message += "Tank " + i + ': Water level is dangerously high: ' + tanks[i]['level'] + 'm3\n';
      sendAlarms('High water level detected', message);
    }
  }

} // end of pushAlarms function


/*
  function to pad out the date with zeros. ONLY works on NUMBERS
*/
function pad(n) {
  return n < 10 ? '0' + n : n
}

/*
  function to write the scraped data to our log files
*/

function writeData(callback) {
  console.log("WritingData");
  var currentDate = new Date();
  // note we use toString(). If we didn't we need another function which would check if n<10 as it would be an int
  var dateStamp = pad(currentDate.getDate().toString(), 2) + '/' + pad((currentDate.getMonth() + 1).toString(), 2) + '/' + currentDate.getFullYear() + ' ' + pad(currentDate.getHours().toString(), 2) + ':' + pad(currentDate.getMinutes().toString(), 2);

  var panelString = "";
  var tankString = "";

  for (i = 0; i < 2; i++) {
    panelString +=
      points[i]['loadNo'] + '\t' +
      dateStamp + '\t' +
      points[i]['line'] + '\t' +
      points[i]['tankNo'] + '\t' +
      points[i]['ph'] + '\t' +
      points[i]['cond'] + '\t' +
      points[i]['temp'] + '\t' +
      points[i]['status'] + '\t' +
      points[i]['pumpSetLevel'] + '\t' +
      points[i]['litresPumped'] + '\t' +
      points[i]['flowRate'] + '\t' +
      points[i]['minsRemain'] + '\t' +
      points[i]['setFlowRate'] + '\n';
  }

  for (i = 0; i < 3; i++) { // loop through lines[i]; A, B, & Offline
    //    var tankNo = i+1;	// this will print the tank log file in tank number order: 1,2,3. Neater but we have scripts which work on Point order: A,B,Offline
    // Instead we print in line order: A, B & OFFLINE
    var tankNo = (i == 2) ? (6 - (points[0].tankNo + points[1].tankNo)) : points[i].tankNo; // find the number of the tank which is not connected to a line (OFFLINE)
    tankString +=
      tankNo + '\t' +
      dateStamp + '\t' +
      tanks[tankNo]['line'] + '\t' +
      tanks[tankNo]['level'] + '\t' +
      tanks[tankNo]['autoFill'] + '\t' +
      tanks[tankNo]['setLevel'] + '\t' +
      tanks[tankNo]['inlet'] + '\t' +
      tanks[tankNo]['airPressure'] + '\n';
  }

  /*
    // Asynchronously write data to files
    fs.appendFile('../../panel/panel_log.txt', panelString, function (err) {
      if (err) {
        throw err;
        console.log("there was an error writing to panel_log.txt " + err);
      }
    });

    fs.appendFile('../../panel/tank_log.txt', tankString, function (err) {
  //    if (err) throw err;
      if (err) {
        throw err;
        console.log("there was an error writing to tank_log.txt " + err);
      }
    });
  */

  // Synchronously write data to files
  // We use blocking to ensure the data is written otherwise the app could exit before writing
  fs.appendFileSync('$LOGS_DIR/tank_log.txt', tankString);
  fs.appendFileSync('$LOGS_DIR/panel_log.txt', panelString);
  callback("", "success");
}



/*
  Setting up our error listener
*/
client.on('error', function(error) {
  console.log("Error: ", error);
});

/*
 Setting up the response listener
 Showing properties of a response
*/

client.on('reply', function(msg) {
  console.log("Data SID: ", msg.sid);
  // console.log("Data returned: ", msg.values);

  // SID 1 is tank data reply
  if (msg.sid == 1) {
    for (var i = 1, z = 0; i < 4; i++, z += 5) {
      tanks.push({
        tank: i,
        level: (msg.values[z + 0] < 0) ? 0 : (msg.values[z + 0] / 10),
        setLevel: (msg.values[z + 1] / 10),
        airPressure: (msg.values[z + 2] / 10),
        autoFill: (msg.values[z + 3] == 0) ? "OFF" : "ON",
        inlet: (msg.values[z + 4] == 0) ? "CLOSED" : "OPEN",
        line: "Offline",
        lineNo: "3"
      });
    }
  }
  // SID 2 is the point data reply
  else if (msg.sid == 2) {
    /*
    H18     A load No
    H10     A tank number
    D506    A PH
    D508    A Cond
    D510    A Temp
    CB80:03 A pumping: 0=OFF, 1=PUMPING
    CB80:05 A 0=NOT PAUSED, 1=PAUSED
    D1004   A set litres pumped
    D1002   A litres pumped
    W36     A set flowrate
    D102    A actual flowrate
    D1026   A mins remaining

    'H18','H10','D506','D508','D510','CB80:03','CB80:05','D1004','D1002','W36','D102','D1026'
    */
    for (var i = 0, z = 0; i < 2; i++, z += 13) {
      points.push({
        line: (i == 0) ? 'A' : 'B',
        loadNo: msg.values[z + 0],
        tankNo: msg.values[z + 1],
        ph: msg.values[z + 2] / 100,
        cond: msg.values[z + 3] / 10,
        temp: msg.values[z + 4] / 10,
        status: msg.values[z + 6] == 1 ? 'PAUSED' : msg.values[z + 5] == 0 ? 'OFFLINE' : 'LOADING',
        pumpSetLevel: msg.values[z + 7],
        litresPumped: (i == 0) ? (msg.values[z + 8] * 2.5) : (msg.values[z + 8] * 5), // get the number of pulses from the flowmeter
        setFlowRate: msg.values[z + 9],
        flowRate: msg.values[z + 10] < 0 ? 0 : msg.values[z + 10],
        minsRemain: msg.values[z + 11] < 0 ? 0 : msg.values[z + 11],
        BRloadNo: msg.values[z + 12]
      });
    }
    // outside the for loop we add the line (A,B,OFFLINE) to the tank objects
    tanks[points[0]['tankNo']].line = 'A';
    tanks[points[0]['tankNo']].lineNo = '1';
    tanks[points[1]['tankNo']].line = 'B';
    tanks[points[1]['tankNo']].lineNo = '2';
  }
  // SID 3 is misc data
  else if (msg.sid == 3) {
    powerInterrupts = msg.values[0]; // A514
    knownPowerInterrupts = msg.values[1]; // H24

    // We are not doing anything with the value of the flowComp. Left in for now but we cannot fully automate this as the tank drain valve needs to be manually opened
    // Currently we have to manually uncomment the crontab line for flow compensation to be enabled
    flowComp = msg.values[2]; // HB31:0
    if (flowComp == 1) {
      // sendAlarms("Flow Compenstation", "ON");
    }
  } else if (msg.sid > 3) {
    console.log("ERROR invalid SID: " + msg.sid);
    client.close();
    console.log("Exiting with exit code 10");
    return process.exit(10);
  }


  // Once we have all our data (3 replies), they may not turn up in order, we can process our data
  // Hopefully we are using callbacks successfully and that we close the clients once we are ready to!
  if (++replyCounter == 3) {
    validateLoadingFlow(function(err, res) {
      if (err) {
        console.log("Error with flowrate, Not writing: ", err)

        // reset everything
        tanks = [{}];
        points = [];
        replyCounter = 0;
        client.header.SID = 0; // reset the SIDs to 0

        console.log("starting 5sec timeout");
        setTimeout(getPLCData, 5000);
        // getPLCData();

        console.log("finished in callback, just asked to re read");
      } else {
        console.log("Response: ", res);

        pushAlarms();

        writeData(function(err, res) {
          if (err) {
            console.log("Error writing to file: ", err)
            return 50;
          }
          console.log("safe to close clients ", res);
          client.close();
        });
      }

    });
  }
});

client.on('timeout', function(host) {
  console.log("Received timeout from: ", host);
  client.close();
  console.log("Exiting with exit code 1");
  return process.exit(1);
});

function getPLCData() {
  console.log("getData");

  /*
    NOW THE MAIN FUNCTION, firing all the FINs reads
  */

  /*
  D200		tank1 level
  D202		tank1 setLevel
  D212		tank1 air pressure
  CB50:04	AutoFill tank 1, 1=ON, 2=CLOSED
  CB0:06	tank1 inlet 1=0PEN, 0=CLOSED

  D204		tank2 level
  D206		tank2 setLevel
  D214		tank1 air pressure
  CB50:07	AutoFill tank 2, 1=ON, 2=CLOSED
  CB0:08	tank2 inlet 1=0PEN, 0=CLOSED

  D208		tank3 level
  D210		tank3 setLevel
  D216		tank3 air pressure
  CB50:08	AutoFill tank 3, 1=ON, 2=CLOSED
  CB0:10	tank3 inlet 1=0PEN, 0=CLOSED
  */
  client.readMultiple('D200', 'D202', 'D212', 'CB50:04', 'CB0:06', 'D204', 'D206', 'D214', 'CB50:07', 'CB0:08', 'D208', 'D210', 'D216', 'CB50:08', 'CB0:10');

  /*
  H18	A load No
  H10	A tank number
  D506	A PH
  D508	A Cond
  D510	A Temp
  CB80:03	A pumping: 0=OFF, 1=PUMPING
  CB80:05	A 0=NOT PAUSED, 1=PAUSED
  D1004	A set litres pumped
  D1002	A litres pumped
  D1026	A mins remaining
  W32	A set flowrate
  D102	A actual flowrate

  H20	B load No
  H12	B tank Number
  D500	B PH
  D502	B Cond
  D504	B Temp
  CB80:01	B pumping: 0=OFF, 1=PUMPING
  CB80:04	B 0=NOT PAUSED, 1=PAUSED
  D1014	B set litres pumped
  D1016	B litres pumped
  D1020	B mins remaining
  W36	B set flowrate
  D104	B actual flowrate
  */
  client.readMultiple('H18', 'H10', 'D506', 'D508', 'D510', 'CB80:03', 'CB80:05', 'D1004', 'D1000', 'W32', 'D102', 'D1026', 'H40', 'H20', 'H12', 'D500', 'D502', 'D504', 'CB80:01', 'CB80:04', 'D1014', 'D1010', 'W36', 'D104', 'D1020', 'H41');

  /*
  A514	number of power interruptions
  H24	set interrupts
  H10	tank on A
  H12	tank on B
  HB31:0	Flow Compensation on or off
  */
  client.readMultiple('A514', 'H24', 'HB31:0');
}

getPLCData();
