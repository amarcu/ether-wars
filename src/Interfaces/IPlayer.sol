pragma solidity ^0.8.13;
import "forge-std/console.sol";

interface IPlayer {
    function execute() external returns (bytes calldata output);

    function getScore() external returns (uint256);
}
