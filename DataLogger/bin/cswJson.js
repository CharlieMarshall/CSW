#!/usr/bin/env node
/*
  cswJson.js — 	A script to read multiple areas of the PLC solely for retrieving realtime data to display on the webserver.
		Once we have read the memory areas we output the results to the console using JSON.stringify, which we can later parse with JS
  Usage: node cswJson.js
  Author: Charlie Marshall
  License: MIT
*/

var fins = require('omron-fins');
var client = fins.FinsClient(9600,'ip_address_removed');
var tanks = []; // we start at tank 1 so tank 0 is initialised to zero
var points = [];
var misc = {};
var replyCounter = 0;

// error listener
client.on('error',function(error) {
  console.log("Error: ", error);
});

// response listener
client.on('reply',function(msg) {
    // SID 1 is tank data reply
    if(msg.sid==1) {
      for(var i=1,z=0; i<4;i++,z+=6){
        tanks.push({
		"Tank No": i,
		"Line": "SPARE",
		"Level (m3)": (msg.values[z+0]<0) ? 0 : (msg.values[z+0] /10),
		"Set Level (m3)": [ (msg.values[z+1]/10), "D" + ( 202 + ((i-1)*4) ), 10 ],
		"Air Pressure": (msg.values[z+2]/10),
		"Auto Fill": [ (msg.values[z+3]==0) ? "OFF" : "ON", "CB" + ( (i==1) ? "50:04" : (i==2) ? "50:07" : "50:08") ],
		"Eco Fill": [ (msg.values[z+4]==0) ? "OFF" : "ON", "HB30:0" + (i-1)],
		"Inlet Valve": (msg.values[z+5]==0) ? "CLOSED" : "OPEN"
	});
      }
    }
    // SID 2 is the point data reply
    if(msg.sid==2) {
      for(var i=0,z=0; i<2;i++,z+=12){
        points.push({
		"Line": (i==0) ? 'A' : 'B',
        	"Load No": [ msg.values[z+0], "H" + (18+(i*2)) ],
          	"Tank No": [ msg.values[z+1], "H" + (10+(i*2)) ],
          	"PH": msg.values[z+2] /100,
          	"Cond": msg.values[z+3] /10,
          	"Temp": msg.values[z+4]  /10,
          	"Status": msg.values[z+6] ==1 ? [ 'PAUSED', ("CB80:0" + (5-i) ) ] : msg.values[z+5]==0 ? 'OFFLINE' : [ 'LOADING', ("CB80:0" + (5-i) ) ],
                "Litres To Pump": [ msg.values[z+7], "D" + (1004 + (i*10)) ],
	  	"Litres Pumped": (i==0) ? (msg.values[z+8]*2.5) : (msg.values[z+8]*5), // get the number of pulses from the flowmeter
          	"Set Flow Rate": [ msg.values[z+9], "W" + (32+(i*4)) ],
          	"Actual Flow Rate": msg.values[z+10]<0 ? 0 : msg.values[z+10],
          	"Mins Remaining": msg.values[z+11]<0 ? 0 : msg.values[z+11]
	});
      }
    }
    // SID 3 is the misc data reply
    else if(msg.sid==3) {
/*
      // for use when using an array
      misc.push({
        	"Eco Fill From (hrs)": [ msg.values[0], "H14" ],
        	"Eco Fill To (hrs)": [ msg.values[1], "H16" ],
        	"Next Load": [ msg.values[2], "H22" ],
        	"Flow Compensation Tank No": [ msg.values[3], "H26" ],
        	"Power Interrupts": msg.values[4],
                "Set Power Interrupts": [ msg.values[5], "H24" ]
      });
*/
      // for use when using an object
      misc["Eco Fill From (hrs)"] = [ msg.values[0], "H14" ],
      misc["Eco Fill To (hrs)"] = [ msg.values[1], "H16" ],
      misc["Next Load"] = [ msg.values[2], "H22" ],
      misc["Flow Compensation Tank No"] = [ msg.values[3], "H26" ],
      misc["Power Interrupts"] = msg.values[4],
      misc["Set Power Interrupts"] = [ msg.values[5], "H24" ]
    }

    else if(msg.sid > 3){
      console.log("ERROR invalid SID: " + msg.sid);
      client.close();
      console.log("Return 10");
      return process.exit(10);
    }

    // Once we have all our data (3 replies), they may not turn up in order, we can process our data
    if(++replyCounter==3){
      // we add the tank numbers here in case the SIDs arrived in the wrong order
      tanks[ points[0]['Tank No'][0]-1  ].Line = 'A';
      tanks[ points[1]['Tank No'][0]-1  ].Line = 'B';
      console.log(JSON.stringify( [points,tanks,misc] )); // note we send these in a different order to the SIDs
      client.close();
    }

});

// 1st readMultiple(): Tanks, 2nd readMultiple(): Points, 3rd readMultiple(): Misc
client.readMultiple('D200','D202','D212','CB50:04','HB30:00','CB0:06','D204','D206','D214','CB50:07','HB30:01','CB0:08','D208','D210','D216','CB50:08','HB30:02','CB0:10');
client.readMultiple('H18','H10','D506','D508','D510','CB80:03','CB80:05','D1004','D1000','W32','D102','D1026','H20','H12','D500','D502','D504','CB80:01','CB80:04','D1014','D1010','W36','D104','D1020');
client.readMultiple('H14','H16','H22','H26','A514','H24');
