pragma solidity ^0.8.13;
import "forge-std/console.sol";
import "../Interfaces/IPlayer.sol";
import "./AbstractGame.sol";

abstract contract AbstractPlayer is IPlayer {
    uint256 public index;
    uint256 public score;

    bool public isInitialized;

    constructor() {
        isInitialized = false;
        score = 0;
    }

    function init(
        address, /*gameAddress*/
        uint256 index_
    ) public virtual {
        index = index_;
        isInitialized = true;
    }
}
