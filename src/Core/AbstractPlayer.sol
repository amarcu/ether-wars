pragma solidity ^0.8.13;
import "forge-std/console.sol";
import "../Interfaces/IPlayer.sol";

abstract contract AbstractPlayer is IPlayer {

    uint256 public index;
    uint256 public score;

    bool public isActive;
    bool public hasExecuted;
    bool public isInitialized;

    bytes internal input;
    bytes internal output;

    constructor(uint256 index_){
        index = index_;
        isInitialized = false;
        hasExecuted = false;
        score = 0;
    }

    function setScore(uint256 score_) public {
        score = score_;
    }

    function setActive(bool isActive_) public {
        isActive = isActive_;
    }

    function resetInput() public {
        input = "";
    }

    function resetOutput() public {
        output = "";
    }

}