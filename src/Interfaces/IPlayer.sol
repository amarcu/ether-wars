pragma solidity ^0.8.13;

interface IPlayer {
    function move(bytes calldata input) external returns (bytes calldata output);
}
