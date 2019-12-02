const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const { upgradeProxy, setAuthStorage, setTokenAddr } = require('../utils/settingContract.js');

const Event = artifacts.require('Event');
const Event_Proxy = fileReader('Event_Proxy');
const AuthStorage = fileReader('AuthStorage');

module.exports = function(deployer) {
  deployer.deploy(Event)
    .then(_ =>  upgradeProxy(Event_Proxy, Event, true))
    .then(_ => {
      const funcAddr = Event.address;
      Event.address = Event_Proxy.address
      return funcAddr
    })
    .then(funcAddr => deployedFileWriter(Event, null, funcAddr))
    .then(_ => setAuthStorage(Event, AuthStorage.address))
    .then(_ => setTokenAddr(Event))
  };

