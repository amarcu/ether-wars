// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "../Core/AbstractPlayer.sol";
import {TicTacToeGame, Grid, Coords} from "./TicTacToeGame.sol";

contract TicTacToeLocalHeuristics is AbstractPlayer {
    TicTacToeGame public game;

    uint256 constant WIN_LINE_COUNT = 8;
    //8 lines we need to check, each with 3 points, each point with 2 coordinates
    uint8[WIN_LINE_COUNT * 3 * 2] internal winLines;

    /* solhint-disable */
    constructor() AbstractPlayer() {
        winLines = [
            0,0,0,1,0,2,
            1,0,1,1,1,2,
            2,0,2,1,2,2,
            0,0,1,0,2,0,
            0,1,1,1,2,1,
            0,2,1,2,2,2,
            0,0,1,1,2,2,
            2,0,1,1,0,2
        ];
    }
    /* solhint-enable */

    function init(address gameAddress, uint256 index_)
        public
        override(AbstractPlayer)
    {
        super.init(gameAddress, index_);
        game = TicTacToeGame(gameAddress);
    }

    function move() external override(IPlayer) returns (bytes memory output) {
        if (game.useCurrentGrid()) {
            (Coords memory localCoords, uint256 score_) = _findBestMove(
                game.getCurrentGrid()
            );
            Coords memory globalCoords = game.toGlobalCoords(
                game.getCurrentGridCoords(),
                localCoords
            );
            //emit MoveDebug(globalCoords.x, globalCoords.y, score_);
            return abi.encode(globalCoords);
        } else {
            Coords memory moveGrid;
            Coords memory bestMove;
            uint256 bestScore = 0;
            for (uint256 gridX = 0; gridX < 3; ++gridX) {
                for (uint256 gridY = 0; gridY < 3; ++gridY) {
                    if (game.getGlobalGrid().cells[gridX][gridY] != 0) continue;

                    (Coords memory move_, uint256 score_) = _findBestMove(
                        game.getLocalGrid(gridX, gridY)
                    );
                    if (score_ > bestScore) {
                        bestMove = move_;
                        bestScore = score_;
                        moveGrid.x = uint128(gridX);
                        moveGrid.y = uint128(gridY);
                    }
                }
            }

            Coords memory globalCoords = game.toGlobalCoords(
                moveGrid,
                bestMove
            );
            //emit MoveDebug(globalCoords.x, globalCoords.y, bestScore);
            return abi.encode(globalCoords);
        }
    }

    function _findBestMove(Grid memory grid)
        internal
        returns (Coords memory move, uint256 score)
    {
        uint256 otherPlayer = (index + 1) % 2;
        uint256 bestScore = 0;
        uint256 meCount = 0;
        uint256 enemyCount = 0;
        uint256 emptyCount = 0;
        uint128 emptyX = 0;
        uint128 emptyY = 0;

        for (uint256 lineIdx = 0; lineIdx < WIN_LINE_COUNT; ++lineIdx) {
            meCount = 0;
            enemyCount = 0;
            emptyCount = 0;
            emptyX = 0;
            emptyY = 0;
            for (uint256 pIdx = 0; pIdx < 3; ++pIdx) {
                uint256 x = winLines[lineIdx * 3 * 2 + pIdx * 2];
                uint256 y = winLines[lineIdx * 3 * 2 + pIdx * 2 + 1];
                //emit DebugPoint(x,y);

                if (grid.cells[x][y] == index + 1) {
                    meCount++;
                } else if (grid.cells[x][y] == otherPlayer + 1) {
                    enemyCount++;
                } else if (grid.cells[x][y] == 0){
                    emptyCount++;
                    emptyX = uint128(x);
                    emptyY = uint128(y);
                }

                if (meCount == 2 && emptyCount == 1) {
                    return (Coords(emptyX, emptyY), 2000);
                }

                if (enemyCount == 2 && emptyCount == 1) {
                    move.x = emptyX;
                    move.y = emptyY;
                    bestScore = 500;
                }

                if (meCount == 1 && emptyCount > 0) {
                    if (bestScore < 500) {
                        move.x = emptyX;
                        move.y = emptyY;
                        bestScore = 100;
                    }
                }

                if (bestScore < 10 && emptyCount > 0) {
                    move.x = emptyX;
                    move.y = emptyY;
                    bestScore = 10;
                }
            }
        }

        return (move, bestScore);
    }
}
