#!/usr/bin/env node
// Author Charlie Marshall

var LedMatrix = require("easybotics-rpi-rgb-led-matrix");
var fins = require('./node_modules/node-omron-fins/');      // for Omron FINS communication
var client;
var timer = null;

var matrix = new LedMatrix(32, 64 );	// init a 32 rows  by 64 cols led matrix
matrix.brightness(100);			// set at max brightness 0-100
//const font = "/home/pi/fonts/9x15B.bdf";

// end of global variables

/*
* Function to create make a UDP connection with the PLC and handle the responses
*/

function init(){
  // we need to use a timeout, the default timeout results in the following error being thrown on a timeout: throw new ERR_SOCKET_DGRAM_NOT_RUNNING();
  var options = {timeout:10000}; // 10 seconds
  client = fins.FinsClient(9600,'ip',options); // create a connection with a specified timeout

  client.on('open',function(error) {
    console.log(getTimestamp(), "opening client...");
  });

  client.on('close',function(error) {
    console.log(getTimestamp(), "Client closed. Attempting reconnection in 10 seconds");
    setTimeout(init, 10000); // wait 10 seconds and then attempt to reconnect
  });

  // this block is not needed as the pollPLC function is run straight away and it will timeout before this is reached
  client.on('timeout',function(error) {
    console.log(getTimestamp(), "timeout occured during connection, is the network down?");
    this.close();
  });

  client.on('error',function(error) {
    console.log(getTimestamp(), "An Error occured: ", error);
  });

  // Setting up the response listener
  // Showing properties of a response
  client.on('reply',function(msg) {
    clearTimeout(timer);
    var data = {};
    data.loadA = "A " + msg.values[0]; // Load in A H18
    data.loadB = "B " + msg.values[1]; // Load in A H18
    // if we are pumping we change the colour to red
    data.colourA = msg.values[2]<=0 ? 255 : 0;
    data.colourB = msg.values[3]<=0 ? 255 : 0;

    console.log(getTimestamp(), "LED display:");
    // console.log("SID: ", msg.sid)
    console.log(data.loadA, data.colourA==255 ? "yellow" : "red (filling)");
    console.log(data.loadB, data.colourB==255 ? "yellow" : "red (filling)");
    // end of debugging

    updateLED(data);
  });

  pollPLC();

}


/*
* Function to check if our UDP read command completes or times out. This is different to the timeout command build into the fins omron package, which detects timeout on connection
*/
function isTimeout(){
  // If no reply in 2 seconds close the client
  timer = setTimeout(() => {
    console.log(getTimestamp(), "A time out occured. No responce received");
    client.close();
  }, 4000)
}

// Function to get a date and timestamp
function getTimestamp(){
    var currentDate = new Date();
    return dateStamp =currentDate.getDate() + '/' + (currentDate.getMonth() + 1) + '/' + currentDate.getFullYear() + ' ' + currentDate.getHours() +
    ':' + currentDate.getMinutes() + ":" +  currentDate.getSeconds();
}

// Function to render the LED
function updateLED(data) {
  matrix.clear();

  matrix.drawText(5, 2,  data.loadA, "../fonts/9x15B.bdf", 255, data.colourA, 0);
  matrix.drawText(5, 16, data.loadB, "../fonts/9x15B.bdf", 255, data.colourB, 0);

  matrix.update();
  setTimeout(pollPLC, 20000); // wait 20 seconds update the LED display
}


// Function to read the load numbers and flowrates from the PLC
function pollPLC() {
  // console.log(getTimestamp(), "sending request to PLC, pollPLC()");
  client.header.SID = 0; // reset the SIDs to 0

  // H18 = A Load Number
  // H20 = B Load Number
  // D102 = A flowRate
  // D104 = B flowRate
  client.readMultiple('H18','H20','D102','D104');
  isTimeout();
}

init();
