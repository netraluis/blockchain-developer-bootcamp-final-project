var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");
var Prueba = artifacts.require("./Prueba.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(SupplyChain);
  deployer.deploy(Prueba);
};
