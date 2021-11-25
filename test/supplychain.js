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
  const firstItemName = "firstItemName";
  const firstPriceItem = web3.utils.toWei('1', 'ether');



  beforeEach(async () => {
    SupplyChainInstance = await SupplyChain.deployed();
    sku = 0
  })


  it("it should add a new Item", async () => {
    const balanceBeforeAddItem = await web3.eth.getBalance(sender)
    const addItemTx = await SupplyChainInstance.addItem(firstItemName, receiver, shipper, {from: sender, value:firstPriceItem }); 
    const balanceAfterAddItem = await web3.eth.getBalance(sender)
    const gasPr = await web3.eth.getGasPrice();

    
    expect(balanceAfterAddItem*1 ).to.equal((balanceBeforeAddItem - (addItemTx.receipt.gasUsed * gasPr) - firstPriceItem)*1);


    truffleAssert.eventEmitted(addItemTx, 'LogForShipment', event => {
      return event.sku.toNumber() === sku;
    });

    truffleAssert.eventEmitted(addItemTx, 'ItemChange', event => {
      const { item: {
        name, price, sender, receiver, shipper,
      } } = event;
      const isTrue = name === firstItemName &&
                    price*1 === firstPriceItem*1 &&
                    sender === sender &&
                    receiver === receiver &&
                    shipper === shipper

      return isTrue;
    });

    truffleAssert.eventEmitted(addItemTx, 'AddMoneyToAccount', event => {
      const { _address, payment } = event;
      return _address === shipper && BigInt(payment) ===  BigInt(firstPriceItem);
    });

    sku = sku + 1

  });


  it


});
