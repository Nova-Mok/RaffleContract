

pragma solidity ^0.8.11;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Lottery is VRFConsumerBaseV2 {
    address public owner;
    address payable[] public players;
    uint public lotteryId;
    mapping (uint => address payable) public lotteryHistory;

    bytes32 internal keyHash; // identifies which chainlink oracale to use
    uint internal fee; // fee to get random number
    uint public randomResult;

    constructor()
        VRFConsumerBaseV2(
            0x6168499c0cFfCaCD319c818142124B7A15E857ab, 
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709 
        ) 
        {
            keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
            fee = 0.25 * 10 ** 18; 

            owner = msg.sender;
            lotteryId = 1;
        }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
        return requestRandomness(keyHash, fee);
    }

    function fullfillRandomness(bytes32 requestId, uint randomness) internal override {
        randomResult = randomness;
        payWinner();
    } 

    function getWinnerByLottery (uint lottery) public view returns(address payable) {
        return lotteryHistory[lottery];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;


    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;

    }

    function enter() public payable {
        require(msg.value > 0.1 ether);


        // address of player entering lottery
        players.push(payable(msg.sender));
    }

    function pickWinner() public onlyOwner {
        getRandomNumber();

    }

    function payWinner() public {
        uint index = randomResult % players.length;
        players[index].transfer(address(this).balance);

        lotteryHistory[lotteryId] = players[index];
        lotteryId++;

        // reset the state of contract

        players = new address payable[](0);

    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}
