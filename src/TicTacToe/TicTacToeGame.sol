// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "../Core/AbstractGameManager.sol";

contract TicTacToeGame is AbstractGameManager {
    event Winner(uint8 winner, uint128 x, uint128 y);
    event Draw(uint128 x, uint128 y);

    struct Grid {
        uint8 winner;
        uint64 moves;
        uint8[3][3] cells;
    }

    struct Move {
        uint128 x;
        uint128 y;
    }

    error TicTacToeGame__invalidMove();

    Grid public masterGrid;
    Grid[3][3] public grids;

    uint256 public currentPlayer;
    Move public currentGridCoords;
    bool public useCurrentGrid;

    constructor(address[] memory players_, uint256 playerGasLimit_)
        AbstractGameManager(players_, playerGasLimit_)
    {
        currentPlayer = 0;
        currentGridCoords.x = 0;
        currentGridCoords.y = 0;
        useCurrentGrid = false;
    }

    function init() public override(IGameManager) {}

    function applyMove(bytes calldata input) public override(IGameManager) {
        Move memory move = abi.decode(input, (Move));
        if (move.x < 0 || move.x >= 3 || move.y < 0 || move.y >= 3) {
            revert TicTacToeGame__invalidMove();
        }

        Grid storage currentGrid = grids[uint256(currentGridCoords.x)][
            uint256(currentGridCoords.y)
        ];

        if (currentGrid.cells[uint256(move.x)][uint256(move.y)] != 0) {
            revert TicTacToeGame__invalidMove();
        }

        // update grid
        currentGrid.cells[uint256(move.x)][uint256(move.y)] = uint8(
            currentPlayer + 1
        );
        currentGrid.moves++;
        currentGridCoords = move;

        //emit Move(currentPlayer + 1, currentGridCoords.x, currentGridCoords.y, move.x, move.y);

        uint8 winner = _checkWinner(currentGrid);
        if (winner != 0) {
            if (winner == 3) {
                emit Draw(currentGridCoords.x, currentGridCoords.y);
            } else {
                emit Winner(winner, currentGridCoords.x, currentGridCoords.y);
            }
        }

        currentPlayer = (currentPlayer + 1) % 2;
    }

    function gameState()
        public
        override(IGameManager)
        returns (bytes memory gameState)
    {
        return abi.encode(masterGrid, grids);
    }

    function _toLocalCoords(uint256 globalX, uint256 globalY)
        internal
        pure
        returns (
            uint256 gridX,
            uint256 gridY,
            uint256 coordX,
            uint256 coordY
        )
    {


    }

    function _checkWinner(Grid memory grid) internal returns (uint8 winner) {
        // Stupid check, probably should go with O(1) -> update rows ,cols diag sums on move.
        for (uint256 x = 0; x < 3; ++x) {
            if (
                (grid.cells[x][0] + grid.cells[x][1] + grid.cells[x][2] != 0) &&
                (grid.cells[x][0] == grid.cells[x][1] &&
                    grid.cells[x][1] == grid.cells[x][2])
            ) {
                return grid.cells[x][0];
            }

            if (
                (grid.cells[0][x] + grid.cells[1][x] + grid.cells[2][x] != 0) &&
                (grid.cells[0][x] == grid.cells[1][x] &&
                    grid.cells[1][x] == grid.cells[2][x])
            ) {
                return grid.cells[0][x];
            }
        }

        if (
            (grid.cells[0][0] + grid.cells[1][1] + grid.cells[2][2] != 0) &&
            (grid.cells[0][0] == grid.cells[1][1] &&
                grid.cells[1][1] == grid.cells[2][2])
        ) {
            return grid.cells[0][0];
        }

        if (
            (grid.cells[0][2] + grid.cells[1][1] + grid.cells[2][0] != 0) &&
            (grid.cells[0][2] == grid.cells[1][1] &&
                grid.cells[1][1] == grid.cells[2][0])
        ) {
            return grid.cells[0][2];
        }

        if (grid.moves == 9) return 3;

        return 0;
    }
}
