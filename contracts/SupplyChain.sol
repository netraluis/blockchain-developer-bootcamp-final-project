pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/PullPayment.sol";

contract SupplyChain is PullPayment {


  // <skuCount>
  uint public skuCount;

  // <items mapping>
  mapping(uint => Item) public items;

  mapping(address => uint[]) public pendingPayments;

  // <enum State: ForSale, Sold, Shipped, Received>
  // ForSale,
  // Sold,
  enum State {
    ForShipment,
    Shipped,
    Received, 
    ShipperPaid
  }

  // <struct Item: name, sku, price, state, sender, and receiver>
  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable sender;
    address payable receiver;
    address payable shipper; 
  }

  struct Balance {
    uint charged;
    uint toCollect;
  }

  // <logForShipment event: sku arg>
  event LogForShipment(uint sku);

  // <LogShipped event: sku arg>
  event LogShipped(uint sku);

  // <LogReceived event: sku arg>
  event LogReceived(uint sku);

  event AddMoneyToAccount(address _address, uint payment);  

  event ItemChange(Item item);

  event UpdatePendingPayments(address _address, uint[] skus);

  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract



  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier enoughMoney() { 
    require(msg.sender.balance > msg.value); 
    _;
  }

  // modifier checkValue(uint _sku) {
  //   //refund them after pay for item (why it is before, _ checks for logic before func)
  //   _;
  //   uint _price = items[_sku].price;
  //   uint amountToRefund = msg.value - _price;
  //   items[_sku].receiver.transfer(amountToRefund);
  // }

  // modifier forSale()
  //  modifier forSale(uint _sku) {
  //   require(items[_sku].state == State.ForSale); 
  //   require(items[_sku].sender != address(0)); 
  //   _;
  // }

  //  modifier sold(uint _sku) {
  //   require(items[_sku].state == State.Sold); 
  //   _;
  // }
  // modifier sold(uint _sku) 
  // modifier shipped(uint _sku) 

  modifier forShipment (uint _sku) {
    require(items[_sku].state == State.ForShipment); 
    _;
  }
   modifier shipped(uint _sku) {
    require(items[_sku].state == State.Shipped); 
    _;
  }
  // modifier received(uint _sku) 
   modifier received(uint _sku) {
    require(items[_sku].state == State.Received); 
    _;
  }

  function addItem(string memory _name, address payable _receiver, address payable _shipper) 
    enoughMoney() public payable returns (bool) {
    items[skuCount] = Item({
      name: _name, 
      sku: skuCount, 
      price: msg.value, 
      state: State.ForShipment, 
      sender: payable(msg.sender), 
      receiver: payable(_receiver),
      shipper: payable(_shipper)
    });
    emit ItemChange(items[skuCount]);
    
    if( msg.sender.balance > msg.value ){
      _asyncTransfer(_shipper, msg.value );
      emit AddMoneyToAccount(_shipper, msg.value);
      skuCount = skuCount + 1;
      return true;
    }else{
      return false;
    }
    
  }

  function shipItem(uint sku) public {
    items[sku].state = State.Shipped;
    emit ItemChange(items[sku]);
  }

  function receiveItem(uint sku) public shipped(sku) {
    items[sku].state = State.Received;
    emit ItemChange(items[sku]);

    pendingPayments[items[sku].shipper].push(skuCount);
    pendingPayments[items[sku].shipper].push(skuCount);
    emit UpdatePendingPayments(items[sku].shipper, pendingPayments[items[sku].shipper]);
  }

  function payShipper(uint sku) public received(sku) {
    require(items[sku].state != State.Received, "First you have to lend the package");
    require(items[sku].shipper != msg.sender, "The sender is the only one who can make the transaction");
    require(address(items[sku].sender).balance >= items[sku].price);
    // sendMoney(items[sku].shipper, items[sku].price);
    items[sku].state = State.ShipperPaid;
    emit ItemChange(items[sku]);
  }

   function fetchItem(uint _sku) public view 
     returns (string memory name, uint sku, uint price, uint state, address sender, address receiver, address shipper)
   {
     name = items[_sku].name; 
     sku = items[_sku].sku; 
     price = items[_sku].price; 
     state = uint(items[_sku].state); 
     sender = items[_sku].sender; 
     receiver = items[_sku].receiver; 
     shipper = items[_sku].shipper;
     return (name, sku, price, state, sender, receiver, shipper); 
  } 

   function getBalance() public view 
    returns (uint)
  {
    return (msg.sender.balance);
  }

  function withdrawPayments(address payable payee) public override{
    for (uint i = 0; i < pendingPayments[payee].length; i++) {
      items[i].state = State.ShipperPaid;
      emit ItemChange(items[i]);
    }
    super.withdrawPayments(payee);
    delete pendingPayments[payee];
    emit UpdatePendingPayments(payee, pendingPayments[payee]);
  }



  // https://docs.openzeppelin.com/contracts/4.x/api/security
  // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/README.md#installing-openzeppelin
}
