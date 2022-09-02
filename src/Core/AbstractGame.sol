// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "./AbstractPlayer.sol";
import "../Interfaces/IGame.sol";

abstract contract AbstractGame is IGame {
    enum GameState {
        Invalid,
        Initialized,
        Active,
        Finished
    }

    uint256 public playerGasLimit;

    GameState public state;

    AbstractPlayer[] public players;
    bytes[] public moves;
    bool[] public activePlayers;

    uint256 public turnNr;

    constructor() {
        state = GameState.Invalid;
    }

    function init(address[] memory players_, uint256 playerGasLimit_)
        external
        virtual
        override(IGame)
    {
        state = GameState.Initialized;
        turnNr = 0;
        playerGasLimit = playerGasLimit_;
        uint256 len = players_.length;
        players = new AbstractPlayer[](len);
        activePlayers = new bool[](len);
        moves = new bytes[](len);

        for (uint256 idx = 0; idx < len; ++idx) {
            players[idx] = AbstractPlayer(players_[idx]);
            players[idx].init(address(this), idx);
            activePlayers[idx] = true;
        }
    }

    function start() external override(IGame) {
        state = GameState.Active;
    }

    function execute() external override(IGame) {
        uint256 len = players.length;
        for (uint256 idx = 0; idx < len; ++idx) {
            try players[idx].move{gas: playerGasLimit}() returns (
                bytes memory playerMove
            ) {
                try this.applyMove(playerMove) {
                    moves[idx] = playerMove;
                } catch {
                    activePlayers[idx] = false;
                    moves[idx] = "";
                }
            } catch {
                activePlayers[idx] = false;
                moves[idx] = "";
            }
        }

        turnNr++;
    }
}
