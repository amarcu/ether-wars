// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";

interface IGame {
    function init(address[] memory players_, uint256 playerGasLimit_) external;

    function start() external;

    function execute() external;

    function applyMove(bytes calldata input) external;
}
