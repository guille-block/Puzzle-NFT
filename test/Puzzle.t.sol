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

}
