const SupplyChain = artifacts.require("./SupplyChain.sol");
const truffleAssert = require("truffle-assertions");
const { toBN } = web3.utils;

contract("SupplyChain", (accounts) => {
  const admin = accounts[0];
  const sender = accounts[1];
  const receiver = accounts[2];
  const shipper = accounts[3];
  const attacker = accounts[9];

  let SupplyChainInstance;
  let skuCount;
  const firstItemName = "firstItemName";
  const firstPriceItem = web3.utils.toWei("1", "ether");
  const states = {
    FOR_SHIPMENT: 0,
    SHIPPED: 1,
    RECEIVED: 2,
    SHIPPER_PAID: "ShipperPaid",
  };

  before(async () => {
    SupplyChainInstance = await SupplyChain.deployed();
    skuCount = 0;
  });

  it("it should add a new Item", async () => {
    const balanceBeforeAddItem = toBN(await web3.eth.getBalance(sender));
    const addItemTx = await SupplyChainInstance.addItem(
      firstItemName,
      receiver,
      shipper,
      { from: sender, value: firstPriceItem }
    );
    const gasUsed = toBN(addItemTx.receipt.gasUsed);
    const gasPrice = toBN(await web3.eth.getGasPrice());
    const balanceAfterAddItem = toBN(await web3.eth.getBalance(sender));

    expect(balanceBeforeAddItem.toString()).to.equal(
      balanceAfterAddItem
        .add(gasPrice.mul(gasUsed))
        .add(toBN(firstPriceItem))
        .toString()
    );

    truffleAssert.eventEmitted(addItemTx, "ItemChange", (event) => {
      const {
        item: { name, sku, price, state, sender, receiver, shipper },
      } = event;

      const isTrue =
        name === firstItemName &&
        sku * 1 === skuCount * 1 &&
        price * 1 === firstPriceItem * 1 &&
        state * 1 === states.FOR_SHIPMENT &&
        sender === sender &&
        receiver === receiver &&
        shipper === shipper;

      return isTrue;
    });

    truffleAssert.eventEmitted(
      addItemTx,
      "AddMoneyToAccount",
      async (event) => {
        const { _address, payment } = event;
        return (
          _address === shipper && BigInt(payment) === BigInt(firstPriceItem)
        );
      }
    );
  });

  it("it should change the state to Shipped", async () => {
    // https://ethereum.stackexchange.com/questions/41858/transaction-gas-cost-in-truffle-test-case

    const balanceBeforeShipItem = toBN(await web3.eth.getBalance(shipper));
    const shipItemTx = await SupplyChainInstance.shipItem(skuCount, {
      from: shipper,
    });
    const gasUsed = toBN(shipItemTx.receipt.gasUsed);
    const gasPrice = toBN(
      (await web3.eth.getTransaction(shipItemTx.tx)).gasPrice
    );
    const balanceAfterShipItem = toBN(await web3.eth.getBalance(shipper));

    expect(balanceBeforeShipItem.toString()).to.equal(
      balanceAfterShipItem.add(gasPrice.mul(gasUsed)).toString()
    );

    truffleAssert.eventEmitted(shipItemTx, "ItemChange", async (event) => {
      const {
        item: { state },
      } = event;

      return state * 1, states.SHIPPED;
    });
  });

  it("it should change the state to received", async () => {
    const balanceBeforeReceiveItem = toBN(await web3.eth.getBalance(receiver));
    const receiveItemTx = await SupplyChainInstance.receiveItem(skuCount, {
      from: receiver,
    });
    const gasUsed = toBN(receiveItemTx.receipt.gasUsed);
    const gasPrice = toBN(
      (await web3.eth.getTransaction(receiveItemTx.tx)).gasPrice
    );
    const balanceAfterReceiveItem = toBN(await web3.eth.getBalance(receiver));

    expect(balanceBeforeReceiveItem.toString()).to.equal(
      balanceAfterReceiveItem.add(gasPrice.mul(gasUsed)).toString()
    );

    truffleAssert.eventEmitted(receiveItemTx, "ItemChange", async (event) => {
      const {
        item: { state },
      } = event;
      return state * 1, states.RECEIVED;
    });
  });

  it("it should change the state to payShipper", async () => {

    const balanceBeforePayingShipper = toBN(await web3.eth.getBalance(shipper));
    const payShipperTx = await SupplyChainInstance.withdrawPayments(shipper, {from: shipper});
    const gasUsed = toBN(payShipperTx.receipt.gasUsed);
    const gasPrice = toBN(
      (await web3.eth.getTransaction(payShipperTx.tx)).gasPrice
    );

    const balanceAfterPayingShipper = toBN(await web3.eth.getBalance(shipper));

    expect(balanceBeforePayingShipper.add(toBN(firstPriceItem)).toString()).to.equal(
      balanceAfterPayingShipper.add(gasPrice.mul(gasUsed)).toString()
    );

  });
});
