const Migrations = artifacts.require("Migrations");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
    // deployer.then(function(){
    //   return Migrations.new();
    // })
