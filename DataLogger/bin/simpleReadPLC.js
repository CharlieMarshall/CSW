#!/usr/bin/env node
/*
  read.js — A testing script to read from the PLC
  Usage: node read.js
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
    console.log("Data SID: ", msg.sid);
    console.log("Data returned: ", msg.values);
    client.close();
});

client.read("H40", 10);
//client.read("CB50:10", 1);
