const SupplyChain = artifacts.require("./SupplyChain.sol");
const truffleAssert = require('truffle-assertions');

contract("SupplyChain", accounts => {
  const admin = accounts[0];
  const sender = accounts[1];
  const receiver = accounts[2];
  const shipper = accounts[3];
  const attacker = accounts[9];

  let SupplyChainInstance;
  let sku; 

  beforeEach(async () => {
    SupplyChainInstance = await SupplyChain.deployed();
    sku = 0
  })


  it("it should add a new Item", async () => {
    const tx = await SupplyChainInstance.addItem('firstItem', 10000, receiver, shipper); 
    sku = sku + 1

    truffleAssert.eventEmitted(tx, 'LogForShipment', event => {
      console.log('test1',event.sku.toNumber());

      // const skuCount = event.sku;
      // console.log('test', skuCount)
      return event.sku.toNumber() === 1;
    });

    truffleAssert.prettyPrintEmittedEvents(tx);
  });
});
