const UniversalDB = artifacts.require('./UniversalDB.sol');

Contract('UniversalDB', function(accounts) {
  let UniversalDBInstance;

  it("Contract instance init", function() {
    return UniversalDB.deployed().then(function(instance) {
      UniversalDBInstance = instance;
      return UniversalDBInstance.owner.call();
    }).then(function(owner) {
      assert.equal(owner.toUpperCase(), account[0].toUpperCase, "TTT");
    })
  })
})

