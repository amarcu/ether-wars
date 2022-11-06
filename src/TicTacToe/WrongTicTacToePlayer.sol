// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "forge-std/console.sol";
import "../Core/AbstractPlayer.sol";
import {TicTacToeGame, Grid, Coords} from "./TicTacToeGame.sol";

contract WrongTicTacToePlayer is AbstractPlayer {
    TicTacToeGame public game;

    constructor() AbstractPlayer() {}

    function init(address gameAddress, uint256 index_)
        public
        override(AbstractPlayer)
    {
        super.init(gameAddress, index_);
        game = TicTacToeGame(gameAddress);
    }

    function move(
        bytes calldata /*input*/
    ) external pure override(IPlayer) returns (bytes memory output) {
        Coords memory coords;
        coords.x = 2;
        coords.y = 0;

        return abi.encode(coords);
    }
}
