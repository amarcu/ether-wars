// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {TicTacToeGame} from "../src/TicTacToe/TicTacToeGame.sol";

contract TicTacToeScript is Script {

    TicTacToeGame public game;
    function setUp() public {}

    function run() public {
        address[] memory players = new address[](2);
        game = new TicTacToeGame(players, 2000000);

        TicTacToeGame.Move memory move;
        move.x = 0;
        move.y = 0;
        game.applyMove(abi.encode(move));

        move.x = 1;
        move.y = 1;
        game.applyMove(abi.encode(move));

        move.x = 0;
        move.y = 1;
        game.applyMove(abi.encode(move));

        move.x = 2;
        move.y = 1;
        game.applyMove(abi.encode(move));

        move.x = 0;
        move.y = 2;
        game.applyMove(abi.encode(move));

        vm.broadcast();
    }

    function _printGrid() internal {

    }
}
