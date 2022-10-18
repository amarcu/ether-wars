pragma solidity ^0.8.13;
import "../Interfaces/IPlayer.sol";

abstract contract AbstractPlayer is IPlayer {
    uint256 public index;

    bool public isInitialized;

    constructor() {
        isInitialized = false;
    }

    function init(
        address, /*gameAddress*/
        uint256 index_
    ) public virtual {
        index = index_;
        isInitialized = true;
    }
}
