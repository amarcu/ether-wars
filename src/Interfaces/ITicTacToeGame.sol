pragma solidity ^0.8.13;

struct Grid {
    // 0-> no winner yet, `1` for Player 1, `2` for Player 2 and `3` for a draw
    uint8 winner;
    // # of moves played in the grid;
    uint64 moves;
    // Cells containing each move. `0` -> Empty, `1` -> Player 1, `2` -> Player 2
    uint8[3][3] cells;
}

struct Coords {
    uint128 x;
    uint128 y;
}

interface ITicTacToeGame {
    /// @notice Returns the index of the player that is moving this turn
    function currentPlayer() external view returns (uint256);

    /// @notice Returns whether this turn is played in the current grid
    /// If `useCurrentGrid()` returns false any empty cell can be played this turn
    function useCurrentGrid() external view returns (bool);

    /// @notice Returns the winner
    /// 0 -> There is no winner yet, 1 -> Player 1 wins, 2 -> Player 2 wins, 3 -> Draw
    function gameWinner() external returns (uint256);

    /// @notice Returns the small grid at `x` and `y` coordinates in the main board
    function getLocalGrid(uint256 x, uint256 y)
        external
        view
        returns (Grid memory);

    /// @notice Returns the main board
    function getGlobalGrid() external view returns (Grid memory);

    /// @notice Returns the grid for the current move
    function getCurrentGrid() external view returns (Grid memory);

    /// @notice Returns the main grid coordinates of the current small grid
    function getCurrentGridCoords() external view returns (Coords memory);

    /// @notice Helper function that converts global coordinates to small grid coordinate and local coordinate.
    function toLocalCoords(Coords memory global)
        external
        pure
        returns (Coords memory gridCoords, Coords memory localCoords);

    /// @notice Helper function that converts local grid coordinates to global coordinates.
    function toGlobalCoords(Coords memory gridCoords, Coords memory localCoords)
        external
        pure
        returns (Coords memory globalCoords);

    /// @notice Returns the winner of a grid, same logic as `gameWinner()`
    function checkWinner(Grid memory grid) external pure returns (uint8 winner);
}
