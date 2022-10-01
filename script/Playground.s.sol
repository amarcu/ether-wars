// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/StdJson.sol";
import "forge-std/Script.sol";
import "forge-std/Vm.sol";

import "@openzeppelin/utils/Strings.sol";

import {AbstractGame} from "../src/Core/AbstractGame.sol";
import {TicTacToeGame, Grid, Coords} from "../src/TicTacToe/TicTacToeGame.sol";
import {TicTacToeSimplePlayer} from "../src/TicTacToe/TicTacToeSimplePlayer.sol";
import {TicTacToeLocalHeuristics} from "../src/TicTacToe/TicTacToeLocalHeuristics.sol";


struct TestParams{
    string p1;
    bytes b1;
    string p2;
    bytes b2;
}

contract Playground is Script {
    event log_uint(uint256 len);
    event log_bytes(bytes);
    event log_string(string);
    Vm public cheatCodes = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    
   
    function run() public {

        TestParams memory params;
        try vm.readFile("logs/game_params.txt") returns (string memory paramsJson){
            bytes memory jsonBytes = vm.parseJson(paramsJson);
            
            params = abi.decode(jsonBytes,(TestParams));
            emit log_string(params.p1);
            emit log_bytes(params.b1);
            emit log_string(params.p2);
            emit log_bytes(params.b2);
        } catch {
            // no game params, do something here
            return;
        }
    }
}
