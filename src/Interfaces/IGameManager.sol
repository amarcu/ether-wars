// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";

interface IGameManager {
    function init() external;

    function execute() external;

    function applyMove(bytes calldata input) external;

    function gameState() external returns (bytes memory gameState);
}
