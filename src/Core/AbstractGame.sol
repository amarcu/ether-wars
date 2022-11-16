// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "./AbstractPlayer.sol";
import "../Interfaces/IGame.sol";

abstract contract AbstractGame is IGame {
    error AbstractGame__execute_gameNotActive();
    error AbstractGame__init_invalidState();

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
    uint256 public winner;

    uint256 public turnNr;

    constructor() {
        state = GameState.Invalid;
        winner = 0;
    }

    function init(address[] memory players_, uint256 playerGasLimit_)
        external
        virtual
        override(IGame)
    {
        turnNr = 0;
        state = GameState.Initialized;
        playerGasLimit = playerGasLimit_;
        uint256 len = players_.length;
        players = new AbstractPlayer[](len);
        activePlayers = new bool[](len);
        moves = new bytes[](len);

        for (uint256 idx = 0; idx < len; ++idx) {
            players[idx] = AbstractPlayer(players_[idx]);
            if(address(players[idx]) == address(0)){
                activePlayers[idx] = false;
                onInvalidMove(idx);
            } else {
                try players[idx].init(address(this), idx){
                    activePlayers[idx] = true;
                } catch {
                    activePlayers[idx] = false;
                    onInvalidMove(idx);
                }
            }
        }
    }

    function start() external override(IGame) {
        if(state != GameState.Initialized){
            revert AbstractGame__init_invalidState();
        }

        state = GameState.Active;
    }

    function onInvalidMove(uint256 playerIndex) internal virtual;

    function onPreTurn(
        uint256 /*playerIndex*/
    ) internal virtual returns (bytes memory output) {
        output = "";
    }

    function onPostTurn(
        uint256 /*playerIndex*/
    ) internal virtual returns (bytes memory output) {
        output = "";
    }

    function execute() external override(IGame) {
        uint256 len = players.length;

        for (uint256 idx = 0; idx < len; ++idx) {
            if (state != GameState.Active) break;

            if (!activePlayers[idx]) continue;

            bytes memory input = onPreTurn(idx);
            try players[idx].move{gas: playerGasLimit}(input) returns (
                bytes memory playerMove
            ) {
                try this.applyMove(playerMove) {
                    moves[idx] = playerMove;
                } catch {
                    activePlayers[idx] = false;
                    moves[idx] = "";
                    onInvalidMove(idx);
                }
            } catch {
                activePlayers[idx] = false;
                moves[idx] = "";
                onInvalidMove(idx);
            }
            onPostTurn(idx);
        }

        turnNr++;
    }
}
