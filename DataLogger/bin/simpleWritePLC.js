#!/usr/bin/env node
/*
*  A script to set the tank level via command argument
*  Author: Charlie Marshall
*  Usage: node simpleWritePLC D202 110
*/

if(process.argv.length !=4) {
  console.log("Invalid number of command arguments. Received: " + process.argv.length);
  return 1; // exit if we do not have 3 command line arguments
}
var fins = require('omron-fins')
var options = {timeout:10000};
var client = fins.FinsClient(9600,'ip');

// Setting up our error listener
client.on('error',function(error) {
  console.log("Error: ", error);
});

// Setting up the response listener
// Showing properties of a response
client.on('reply',function(msg) {
    client.close();
});

// Fetch the tank level from the command line. Multiply the level by 10 as the PLC requires a decimal value. Ensure it is an int and write the value to the PLC
console.log("Write Address: ", process.argv[2], " Data: ", parseInt(process.argv[3]*10) );
client.write(process.argv[2], parseInt(process.argv[3]) );
