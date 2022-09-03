// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "../Core/AbstractPlayer.sol";
import "./TicTacToeGame.sol";

contract TicTacToeSimplePlayer is AbstractPlayer {
    TicTacToeGame public game;

    constructor() AbstractPlayer() {}

    function init(address gameAddress, uint256 index_)
        public
        override(AbstractPlayer)
    {
        super.init(gameAddress, index_);
        game = TicTacToeGame(gameAddress);
    }

    function move()
        external
        view
        override(IPlayer)
        returns (bytes memory output)
    {
        if (game.useCurrentGrid()) {
            TicTacToeGame.Coords memory coords = game.getCurrentGridCoords();
            TicTacToeGame.Grid memory grid = game.getCurrentGrid();

            return abi.encode(_getMove(coords, grid));
        } else {
            TicTacToeGame.Grid memory globalGrid = game.getGlobalGrid();
            for (uint256 globalX = 0; globalX < 3; ++globalX) {
                for (uint256 globalY = 0; globalY < 3; ++globalY) {
                    if (globalGrid.cells[globalX][globalY] == 0) {
                        TicTacToeGame.Coords memory currentMove = _getMove(
                            TicTacToeGame.Coords(
                                uint128(globalX),
                                uint128(globalY)
                            ),
                            game.getLocalGrid(globalX, globalY)
                        );
                        return abi.encode(currentMove);
                    }
                }
            }
        }
        output = "";
    }

    function _getMove(
        TicTacToeGame.Coords memory coords,
        TicTacToeGame.Grid memory grid
    ) internal view returns (TicTacToeGame.Coords memory move_) {
        for (uint256 localX = 0; localX < 3; ++localX) {
            for (uint256 localY = 0; localY < 3; ++localY) {
                if (grid.cells[localX][localY] == 0) {
                    move_ = game.toGlobalCoords(
                        coords,
                        TicTacToeGame.Coords(uint128(localX), uint128(localY))
                    );

                    return move_;
                }
            }
        }
    }
}
