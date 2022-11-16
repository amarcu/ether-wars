// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";

import "@openzeppelin/utils/Strings.sol";

import {AbstractGame} from "../src/Core/AbstractGame.sol";
import {TicTacToeGame, Grid, Coords} from "../src/TicTacToe/TicTacToeGame.sol";
import {TicTacToeSimplePlayer} from "../src/TicTacToe/TicTacToeSimplePlayer.sol";
import {TicTacToeLocalHeuristics} from "../src/TicTacToe/TicTacToeLocalHeuristics.sol";


struct GameParams{
    string p1;
    bytes b1;
    string p2;
    bytes b2;
}

contract TicTacToeScript is Script {

    event log_uint(uint256 len);
    event log_bytes(bytes);
    event log_string(string);
    event log_gameParams(string p1 ,bytes b1,string p2,bytes b2);
    event log_error(uint);
    Vm public cheatCodes = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    
    struct MoveData{
        Coords move1;
        Coords move2;
    }

    TicTacToeGame public game;
    MoveData[] public turnMoves;

    function run() public {

        GameParams memory params;
        try vm.readFile("logs/game_params.txt") returns (string memory paramsJson){
            bytes memory jsonBytes = vm.parseJson(paramsJson);
            params = abi.decode(jsonBytes,(GameParams));
            //emit log_gameParams(params.p1, params.b1, params.p2, params.b2);
        } catch {
            // no game params, do something here
            return;
        }

        address[] memory players = new address[](2);
        players[0] = _deployBytecode(params.b1);
        players[1] = _deployBytecode(params.b2);

        try vm.removeFile("logs/game.txt") {} catch{}

        game = new TicTacToeGame();
        game.init(players, 2000000);
        try game.start() {
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
                } else {
                    emit log_error(0);
                }

                if (move2.length != 0){
                    Coords memory coords = abi.decode(move2,(Coords));
                    lineLog = string.concat("1 ",Strings.toString(coords.x));
                    lineLog = string.concat(lineLog," ");
                    lineLog = string.concat(lineLog,Strings.toString(coords.y));
                    vm.writeLine("logs/game.txt",lineLog);
                } else {
                    emit log_error(1);
                }
            }
        }catch{}

        try vm.removeFile("logs/winner.txt") {} catch{}
        string memory lineWinner = Strings.toString(game.gameWinner());
        vm.writeLine("logs/winner.txt",lineWinner);
    }

        
    /// @notice Deploys the `bytecode`
    /// @param bytecode The byte code that will be deployed
    /// @return deployedAddress The address of the newly deployed contract
    function _deployBytecode(bytes memory bytecode)
        internal
        returns (address deployedAddress)
    {
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }
    }
}
