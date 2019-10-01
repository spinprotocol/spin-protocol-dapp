const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const upgradeProxy = require('../utils/proxyUpgrade.js');

const Event = artifacts.require('Event');
const Event_Proxy = fileReader('Event_Proxy');

module.exports = function(deployer) {
  deployer.deploy(Event)
    .then(_ =>  upgradeProxy(Event_Proxy, Event))
    .then(_ => Event.address = Event_Proxy.address)
    .then(_ => deployedFileWriter(Event))
};

