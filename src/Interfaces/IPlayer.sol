pragma solidity ^0.8.13;
import "forge-std/console.sol";

interface IPlayer {
    function move() external returns (bytes calldata output);
}
