// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "./AbstractPlayer.sol";
import "../Interfaces/IGameManager.sol";

abstract contract AbstractGameManager is IGameManager {
    enum GameState {
        Invalid,
        Active,
        Finished
    }

    uint256 public immutable playerGasLimit;

    GameState public gameState;

    AbstractPlayer[] public players;

    uint256 public turnNr;

    bytes public gameLogs;

    constructor(address[] memory players_, uint256 playerGasLimit_) {
        gameState = GameState.Invalid;
        turnNr = 0;
        playerGasLimit = playerGasLimit_;
        gameLogs = "";
        uint256 len = players_.length;
        players = new AbstractPlayer[](len);
        for (uint256 idx = 0; idx < len; ++idx) {
            players[idx] = AbstractPlayer(players_[idx]);
        }
    }

    function execute() external override(IGameManager) {
        uint256 len = players.length;
        for (uint256 idx = 0; idx < len; ++idx) {
            try
                this.applyMove(players[idx].execute{gas: playerGasLimit}())
            {} catch {
                players[idx].setActive(false);
            }
        }

        turnNr++;
    }
}
