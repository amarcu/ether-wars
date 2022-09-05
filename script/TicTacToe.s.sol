// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";

import "@openzeppelin/utils/Strings.sol";

import {AbstractGame} from "../src/Core/AbstractGame.sol";
import {TicTacToeGame, Grid, Coords} from "../src/TicTacToe/TicTacToeGame.sol";
import {TicTacToeSimplePlayer} from "../src/TicTacToe/TicTacToeSimplePlayer.sol";
import {TicTacToeLocalHeuristics} from "../src/TicTacToe/TicTacToeLocalHeuristics.sol";


contract TicTacToeScript is Script {

    event log_uint(uint256 len);
    event log_bytes(bytes);
    Vm public cheatCodes = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    
    struct MoveData{
        Coords move1;
        Coords move2;
    }

    TicTacToeGame public game;
    TicTacToeSimplePlayer public player1;
    TicTacToeLocalHeuristics public player2;
    MoveData[] public turnMoves;

    function run() public {
        
        player1 = new TicTacToeSimplePlayer();
        player2 = new TicTacToeLocalHeuristics();
        
        address[] memory players = new address[](2);
        players[0] = address(player1);
        players[1] = address(player2);

        try vm.removeFile("logs/game.txt") {} catch{}

        game = new TicTacToeGame();
        game.init(players, 2000000);
        game.start();

        while (game.state() == AbstractGame.GameState.Active){
            game.execute();

            bytes memory move1 =  game.moves(0);
            bytes memory move2 = game.moves(1);

            string memory lineLog = "";
            if (move1.length != 0){
                Coords memory coords = abi.decode(move1,(Coords));
                lineLog = string.concat("0 ",Strings.toString(coords.x));
                lineLog = string.concat(lineLog," ");
                lineLog = string.concat(lineLog,Strings.toString(coords.y));
                vm.writeLine("logs/game.txt",lineLog);
            }

            if (move2.length != 0){
                Coords memory coords = abi.decode(move2,(Coords));
                lineLog = string.concat("1 ",Strings.toString(coords.x));
                lineLog = string.concat(lineLog," ");
                lineLog = string.concat(lineLog,Strings.toString(coords.y));
                vm.writeLine("logs/game.txt",lineLog);
            }
        }
    }
}
