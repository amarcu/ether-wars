// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "../Core/AbstractGame.sol";
import "@openzeppelin/utils/math/SafeMath.sol";

struct Grid {
    uint8 winner;
    uint64 moves;
    uint8[3][3] cells;
}

struct Coords {
    uint128 x;
    uint128 y;
}

contract TicTacToeGame is AbstractGame {
    using SafeMath for uint128;
    using SafeMath for uint256;

    error TicTacToeGame__gameNotActive();
    error TicTacToeGame__invalidMove();

    event Move(
        uint8 player,
        uint128 gridX,
        uint128 gridY,
        uint128 localX,
        uint128 localY
    );

    event LocalWinner(uint8 winner, uint128 x, uint128 y);
    event GlobalWinner(uint8 winner);
    event LocalDraw(uint128 x, uint128 y);
    event PlayerEliminated(uint256 index);


    Grid internal masterGrid;
    Grid[3][3] internal grids;

    uint256 public currentPlayer;
    bool public useCurrentGrid;

    Coords internal currentGridCoords;

    function getLocalGrid(uint256 x, uint256 y)
        public
        view
        returns (Grid memory)
    {
        return grids[x][y];
    }

    function getGlobalGrid() public view returns (Grid memory) {
        return masterGrid;
    }

    function getCurrentGrid() public view returns (Grid memory) {
        return grids[currentGridCoords.x][currentGridCoords.y];
    }

    function getCurrentGridCoords() public view returns (Coords memory) {
        return currentGridCoords;
    }

    function onInvalidMove(uint256 playerIndex)
        internal
        override(AbstractGame)
    {
        winner = (playerIndex + 1) % 2;
        state = GameState.Finished;
        emit PlayerEliminated(playerIndex);
    }

    function applyMove(bytes calldata input) public override(IGame) {
        if (state != GameState.Active) {
            revert TicTacToeGame__gameNotActive();
        }

        Coords memory globalCoords = abi.decode(input, (Coords));

        (Coords memory gridCoords, Coords memory localCoords) = toLocalCoords(
            globalCoords
        );
        if (gridCoords.x >= 3 || gridCoords.y >= 3) {
            revert TicTacToeGame__invalidMove();
        }

        if (useCurrentGrid) {
            if (
                gridCoords.x != currentGridCoords.x ||
                gridCoords.y != currentGridCoords.y
            ) revert TicTacToeGame__invalidMove();
        } else {
            currentGridCoords = gridCoords;
        }

        Grid storage currentGrid = grids[uint256(currentGridCoords.x)][
            uint256(currentGridCoords.y)
        ];

        if (
            currentGrid.cells[uint256(localCoords.x)][uint256(localCoords.y)] !=
            0
        ) {
            revert TicTacToeGame__invalidMove();
        }

        // update grid
        currentGrid.cells[uint256(localCoords.x)][
            uint256(localCoords.y)
        ] = uint8(currentPlayer + 1);
        currentGrid.moves++;

        emit Move(
            uint8(currentPlayer + 1),
            currentGridCoords.x,
            currentGridCoords.y,
            localCoords.x,
            localCoords.y
        );

        uint8 winner = checkWinner(currentGrid);
        if (winner != 0) {
            if (winner == 3) {
                emit LocalDraw(currentGridCoords.x, currentGridCoords.y);
            } else {
                emit LocalWinner(
                    winner,
                    currentGridCoords.x,
                    currentGridCoords.y
                );
            }

            masterGrid.cells[currentGridCoords.x][currentGridCoords.y] = winner;
            masterGrid.moves++;
        }

        uint8 gameWinner = checkWinner(masterGrid);
        if (gameWinner != 0) {
            state = GameState.Finished;
            winner = gameWinner;
            emit GlobalWinner(gameWinner);
        }

        currentGridCoords = localCoords;
        useCurrentGrid =
            masterGrid.cells[currentGridCoords.x][currentGridCoords.y] == 0;
        currentPlayer = (currentPlayer + 1) % 2;
    }

    function toLocalCoords(Coords memory global)
        public
        pure
        returns (Coords memory gridCoords, Coords memory localCoords)
    {
        gridCoords.x = global.x / 3;
        gridCoords.y = global.y / 3;
        localCoords.x = global.x % 3;
        localCoords.y = global.y % 3;
    }

    function toGlobalCoords(Coords memory gridCoords, Coords memory localCoords)
        public
        pure
        returns (Coords memory globalCoords)
    {
        globalCoords.x = gridCoords.x * 3 + localCoords.x;
        globalCoords.y = gridCoords.y * 3 + localCoords.y;
    }

    function getValidMoves(uint256 playerIndex)
        public
        view
        returns (uint128[] memory x, uint128[] memory y)
    {}

    function checkWinner(Grid memory grid) public pure returns (uint8 winner) {
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
