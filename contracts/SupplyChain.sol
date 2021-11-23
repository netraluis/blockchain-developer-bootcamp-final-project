pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/PullPayment.sol";

contract SupplyChain is PullPayment {

  // <owner>
  address public owner;

  // <skuCount>
  uint public skuCount;

  // <items mapping>
  mapping(uint => Item) public items;

  mapping(address => uint)  public balances;

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
    uint256 price;
    State state;
    address payable sender;
    address payable receiver;
    address payable shipper; 
  }

  struct Balance {
    uint charged;
    uint toCollect;
  }
  /* 
   * Events
   */

  // // <LogForSale event: sku arg>
  // event LogForSale(uint sku);

  // // <LogSold event: sku arg>
  // event LogSold(uint sku);

  // <logForShipment event: sku arg>
  event LogForShipment(uint sku);

  // <LogShipped event: sku arg>
  event LogShipped(uint sku);

  // <LogReceived event: sku arg>
  event LogReceived(uint sku);

  event AddMoneyToAccount(address _address, uint balance);  

  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner
  modifier isOwner (address _address) { 
    require (msg.sender == owner); 
    _;
  }

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
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
     //   require(items[_sku].sender != address(0)); 
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

  // constructor()  PullPayment()public{
  //   // 1. Set the owner to the transaction sender
  //   owner = msg.sender;
  //   // 2. Initialize the sku count to 0. Question, is this necessary?
  //   skuCount = 0;
  // }

  function addItem(string memory _name, uint256 _price, address payable _receiver, address payable _shipper) public payable returns (bool) {
    items[skuCount] = Item({
      name: _name, 
      sku: skuCount, 
      price: _price, 
      state: State.ForShipment, 
      sender: payable(msg.sender), 
      receiver: payable(_receiver),
      shipper: payable(_shipper)
    });

    
    skuCount = skuCount + 1;
    emit LogForShipment(skuCount);
    emit AddMoneyToAccount(_shipper, _price);
    if(address(this).balance > _price ){
      // _asyncTransfer(_shipper, _price );
      return true;
    }else{
      return false;
    }
    
  }

  // function _asyncTransfer(address dest, uint256 amount) internal override{
  //   emit AddMoneyToAccount(dest, amount);
  //   super._asyncTransfer(dest, amount);
  // }

  function shipItem(uint sku) public forShipment(sku) {
    items[sku].shipper = payable(msg.sender);
    items[sku].state = State.Shipped;
    emit LogShipped(sku);
  }

  function receiveItem(uint sku) public shipped(sku) verifyCaller(items[sku].receiver){
    items[sku].state = State.Received;
    emit LogReceived(sku);
  }

  function payShipper(uint sku) public received(sku) {
    require(items[sku].state != State.Received, "First you have to lend the package");
    require(items[sku].shipper != msg.sender, "The sender is the only one who can make the transaction");
    require(address(items[sku].sender).balance >= items[sku].price);
    // sendMoney(items[sku].shipper, items[sku].price);
    items[sku].state = State.ShipperPaid;
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

  // function sendMoney(address payable _to, uint ethValue) public payable{
  //   // Call returns a boolean value indicating success or failure.
  //   // This is the current recommended method to use.
  //   (bool sent, bytes memory data) = _to.call{value: ethValue}("");
  //   require(sent, "Failed to send Ether");
  // }


  // https://docs.openzeppelin.com/contracts/4.x/api/security
  // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/README.md#installing-openzeppelin
}
