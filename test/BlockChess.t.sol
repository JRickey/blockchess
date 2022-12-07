// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/BlockChess.sol";

contract CounterTest is Test {
    Game public game;
    Player public player1;
    Player public player2;
    Board public board;

    function setUp() public{
        game = new Game();
        board = new Board();
    }

    function testInit() public {
        player1 = new Player(true);
        player2 = new Player(false);
        game.initialize(player1, player2);

    }

     function testInitRevertbothWhite() public {
        player1 = new Player(true);
        player2 = new Player(true);
        vm.expectRevert();
        game.initialize(player1, player2);

    }

    function testInitRevertbothBlack() public{
        player1 = new Player(false);
        player2 = new Player(false);
        vm.expectRevert("YOU FUCKED UP!!");
        game.initialize(player1, player2);
    }
}
