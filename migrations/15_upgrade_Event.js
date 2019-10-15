const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const upgradeProxy = require('../utils/proxyUpgrade.js');
const { setAuthStorage } = require('../utils/addAuth.js');


const Event = artifacts.require('Event');
const Event_Proxy = fileReader('Event_Proxy');

module.exports = function(deployer) {
  deployer.deploy(Event)
    .then(_ =>  upgradeProxy(Event_Proxy, Event, true))
    .then(_ => {
      const funcAddr = Event.address;
      Event.address = Event_Proxy.address
      return funcAddr
    })
    .then(funcAddr => deployedFileWriter(Event, null, funcAddr))
    .then(_ => setAuthStorage(Event))
  };

