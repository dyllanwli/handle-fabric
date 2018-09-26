var util = require('util');
var path = require('path');
var hfc = require('fabric-client');
let fs = require("fs")

var file = 'network-config.yaml';

function loadYamlOrg(configPath) {
    fs.readdirSync(configPath).forEach(file => {
        if (file.toUpperCase().indexOf("ORG") == 0) {
            orgName = file.split(".yaml")[0]
            orgYaml = file
            console.log("load ", orgName + '-connection-profile-path', "from", path.join(__dirname, 'artifacts', orgYaml))
            hfc.setConfigSetting(orgName + '-connection-profile-path', path.join(__dirname, 'artifacts', orgYaml))
            // config.orgYAML[orgName] = path.join(configPath, orgYaml);
        }
    })
}


// indicate to the application where the setup file is located so it able
// to have the hfc load it to initalize the fabric client instance
hfc.setConfigSetting('network-connection-profile-path', path.join(__dirname, 'artifacts', file));
loadYamlOrg(path.join(__dirname, 'artifacts'))
// hfc.setConfigSetting('Org1-connection-profile-path',path.join(__dirname, 'artifacts', 'org1.yaml'));
// hfc.setConfigSetting('Org2-connection-profile-path',path.join(__dirname, 'artifacts', 'org2.yaml'));
// some other settings the application might need to know
hfc.addConfigFile(path.join(__dirname, 'config.json'));