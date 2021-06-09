pragma solidity 0.8.0;
import "../../node_modules/openzeppelin-solidity/contracts/access/Roles.sol";
//import "../../node_modules/openzeppelin-solidity/contracts/access/Ownable.sol";
import "./CallerContractInterface.sol";
contract EthPriceOracle  {
  using Roles for Roles.Role;
  Roles.Role private owners;
  Roles.Role private oracles;
  uint private randNonce = 0;
  uint private modulus = 1000;
  mapping(uint256=>bool) pendingRequests;
  event GetLatestEthPriceEvent(address callerAddress, uint id);
  event SetLatestEthPriceEvent(uint256 ethPrice, address callerAddress);
  constructor (address _owner) public {
    owners.add(_owner);
  }
  function getLatestEthPrice() public returns (uint256) {
    randNonce++;
    uint id = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % modulus;
    pendingRequests[id] = true;
    emit GetLatestEthPriceEvent(msg.sender, id);
    return id;
  }
  function setLatestEthPrice(uint256 _ethPrice, address _callerAddress, uint256 _id) public onlyOwner {
    require(pendingRequests[_id], "This request is not in my pending list.");
    delete pendingRequests[_id];
    CallerContracInterface callerContractInstance;
    callerContractInstance = CallerContracInterface(_callerAddress);
    callerContractInstance.callback(_ethPrice, _id);
    emit SetLatestEthPriceEvent(_ethPrice, _callerAddress);
  }
}
