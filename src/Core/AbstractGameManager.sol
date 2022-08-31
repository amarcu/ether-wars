// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "./AbstractPlayer.sol";
import "../Interfaces/IGameManager.sol";

abstract contract AbstractGameManager is IGameManager {

    uint256 immutable public playerGasLimit;

    AbstractPlayer[] public players;

    uint256 public turnNr;

    bytes public gameLogs;

    constructor( uint256 playerGasLimit_){
        turnNr = 0;
        playerGasLimit = playerGasLimit_;
        gameLogs = "";
    }

    function execute() external{
        uint256 len = players.length;
        bytes memory gameState = this.gameState();
        for(uint256 idx=0; idx < len; ++idx){
            try this.applyMove(players[idx].execute{gas: playerGasLimit}(gameState)) returns (bytes memory gameState_) {
                gameState = gameState_;
            } catch {
                players[idx].setActive(false);
            }
        }

        turnNr++;
    }
}