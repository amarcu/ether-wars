pragma solidity ^0.8.13;

interface IPlayer {
    function move() external returns (bytes calldata output);
}
