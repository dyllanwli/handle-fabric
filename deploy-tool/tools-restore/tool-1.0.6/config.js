var util = require('util');
var path = require('path');
var hfc = require('fabric-client');

var file = 'network-config.json';
hfc.addConfigFile(path.join(__dirname, 'app', file));
hfc.addConfigFile(path.join(__dirname, 'config.json'));