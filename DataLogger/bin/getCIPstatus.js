#!/usr/bin/env node
/*
  getCIPstatus.js — A script to poll the PLC for the status of the 3 spray balls
  Usage: node getCIPstatus.js
  Author: Charlie Marshall
  License: MIT
*/

var fins = require('omron-fins')
var options = {timeout:10000};
var client = fins.FinsClient(9600,'ip');

// Setting up our error listener
client.on('error',function(error) {
  console.log("Error: ", error);
});

client.on('reply',function(msg) {
  // Handle spray balls
  for(i=0; i<3; i++){
    console.log("Spray Ball", i+1, valve(msg.values[i]));
  }

  client.close();
});

function valve(i){
  return i==0 ? "CLOSED" : "OPEN";
}

function pump(i){
  return i==0 ? "OFF" : "ON";
}

client.readMultiple("CB50:01","CB50:09","CB50:10");
