// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.10;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/Puzzle.sol";


abstract contract HelperContract {
    struct Pieces {
        uint256 partsId;
        uint256 supply;
    }
}

contract NFTTest is DSTest, IStructPuzzle {

    Vm private vm = Vm(HEVM_ADDRESS);
    Puzzle private puzzle;
    StdStorage private stdstore;
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    function setUp() public {
        // Deploy NFT contract
        Pieces memory pieces = Pieces(5, 5);
        puzzle = new Puzzle("TEST_PUZZLE", "https://URI/", pieces);
    }

    
    function testFailMaxMint() public {
        for(uint8 i; i < 10; i++) {
            puzzle.mintParts(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 1);
        }
    }
    function testFailMintNotOwner() public {
        vm.startPrank(address(1));
        puzzle.mintParts(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 1);
    }

    function testFailBatchMintNotOwner() public {
        Mint[] memory minta = new Mint[](4);
        for(uint160 i = 0; i < minta.length; ++i) {
            uint160 num = i++;
            minta[i] = Mint(address(1), num);
        }
        vm.startPrank(address(1));
        puzzle.mintPartsBatch(minta);
    }

    function testFailMintPartsBatchOverId() public {
        Mint[] memory minti = new Mint[](6);
        for(uint160 i = 0; i < minti.length; ++i) {
            uint160 num = i+1;
            minti[i] = Mint(address(num), num);
        }
        puzzle.mintPartsBatch(minti);
    }

    function testMintUserPartsAndLeft() public {
        for(uint8 i; i < 5; i++) {
            puzzle.mintParts(address(1), 1);
        }
        
         assertEq(puzzle.userToPartsToAmounts(address(1), 1), 5);
         assertEq(puzzle.idToAmountsReserve(1), 0);
    }
    
    function testMinted4Parts() public {
        address to = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 3; i++) {
            puzzle.mintParts(to, i);
            assertEq(puzzle.balanceOf(to, i), 1);
        }
    }

    function testPuzzleMint () public {
        address to = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 4; i++) {
            puzzle.mintParts(to, i);
        }
        assertEq(puzzle.balanceOf(to, 5), 1);
        assertEq(puzzle.balanceOf(to, 1), 0);
        assertEq(puzzle.balanceOf(to, 2), 0);
        assertEq(puzzle.balanceOf(to, 3), 0);
        assertEq(puzzle.balanceOf(to, 4), 0);
    }

    function testMintPartsBatch() public {
        Mint[] memory minta = new Mint[](4);
        for(uint160 i = 0; i < minta.length; ++i) {
            uint160 num = i+1;
            minta[i] = Mint(address(num), num);
        }
        puzzle.mintPartsBatch(minta);
        assertEq(puzzle.balanceOf(address(1), 1), 1);
        assertEq(puzzle.balanceOf(address(2), 2), 1);
        assertEq(puzzle.balanceOf(address(3), 3), 1);
        assertEq(puzzle.balanceOf(address(4), 4), 1);
    }
    
    function testMintPartsBatchWinningPuzzle() public {
        address to2 = address(4);
        for(uint8 i=1; i <= 3; i++) {
            puzzle.mintParts(to2, i);
        }
        assertEq(puzzle.balanceOf(address(4), 1), 1);
        assertEq(puzzle.balanceOf(address(4), 2), 1);
        assertEq(puzzle.balanceOf(address(4), 3), 1);

        Mint[] memory minta = new Mint[](4);
        for(uint160 i = 0; i < minta.length; ++i) {
            uint160 num = i+1;
            minta[i] = Mint(address(num), num);
        }
        puzzle.mintPartsBatch(minta);
        assertEq(puzzle.balanceOf(address(1), 1), 1);
        assertEq(puzzle.balanceOf(address(2), 2), 1);
        assertEq(puzzle.balanceOf(address(3), 3), 1);
        assertEq(puzzle.balanceOf(address(4), 1), 0);
        assertEq(puzzle.balanceOf(address(4), 2), 0);
        assertEq(puzzle.balanceOf(address(4), 3), 0);
        assertEq(puzzle.balanceOf(address(4), 4), 0);
        assertEq(puzzle.balanceOf(address(4), 5), 1);
    }
}
