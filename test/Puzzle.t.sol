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

    function testPuzzle1BatchTransfer () public {
        address to1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 2; i++) {
            puzzle.mintParts(to1, i);
        }

        address to2 = address(1);
        for(uint8 i=3; i <= 4; i++) {
            puzzle.mintParts(to2, i);
        }

        
        uint256[] memory ids = new uint256[](2);
        ids[0] = 3;
        ids[1] = 4;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1;
        amounts[1] = 1;
        vm.prank(to2);
        puzzle.safeBatchTransferFrom(
            to2,
            to1,
            ids,
            amounts,
            "0x"
        );
        assertEq(puzzle.balanceOf(to1, 5), 1);
        assertEq(puzzle.balanceOf(to1, 4), 0);
        assertEq(puzzle.balanceOf(to1, 3), 0);
        assertEq(puzzle.balanceOf(to1, 2), 0);
        assertEq(puzzle.balanceOf(to1, 1), 0);
    }

    function testPuzzle1Transfer () public {
        address to1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 3; i++) {
            puzzle.mintParts(to1, i);
        }

        address to2 = address(1);
        for(uint8 i=4; i <= 4; i++) {
            puzzle.mintParts(to2, i);
        }
        vm.prank(to2);
        puzzle.safeTransferFrom(
            to2,
            to1,
            uint256(4),
            uint256(1),
            "0x"
        );
        assertEq(puzzle.balanceOf(to1, 5), 1);
        assertEq(puzzle.balanceOf(to1, 4), 0);
        assertEq(puzzle.balanceOf(to1, 3), 0);
        assertEq(puzzle.balanceOf(to1, 2), 0);
        assertEq(puzzle.balanceOf(to1, 1), 0);
    }

    function testPuzzle3BatchTransfer () public {
        address to1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 2; i++) {
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
        }

        address to2 = address(1);
        for(uint8 i=3; i <= 4; i++) {
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
        }

        
        uint256[] memory ids = new uint256[](2);
        ids[0] = 3;
        ids[1] = 4;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 3;
        amounts[1] = 3;
        vm.prank(to2);
        puzzle.safeBatchTransferFrom(
            to2,
            to1,
            ids,
            amounts,
            "0x"
        );
        assertEq(puzzle.balanceOf(to1, 5), 3);
        assertEq(puzzle.balanceOf(to1, 4), 0);
        assertEq(puzzle.balanceOf(to1, 3), 0);
        assertEq(puzzle.balanceOf(to1, 2), 0);
        assertEq(puzzle.balanceOf(to1, 1), 0);
    }

    // @notice Test safeTransferFrom for 3 transfered parts to user that has other 3 parts
    // @dev Check assertions on minted different than 3 puzzles, and pieces to go down to 0
    function testPuzzle3Transfer () public {
        address to1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 3; i++) {
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
        }

        address to2 = address(1);
        for(uint8 i=4; i <= 4; i++) {
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
        }
        vm.prank(to2);
        puzzle.safeTransferFrom(
            to2,
            to1,
            uint256(4),
            uint256(3),
            "0x"
        );
        assertEq(puzzle.balanceOf(to1, 5), 3);
        assertEq(puzzle.balanceOf(to1, 4), 0);
        assertEq(puzzle.balanceOf(to1, 3), 0);
        assertEq(puzzle.balanceOf(to1, 2), 0);
        assertEq(puzzle.balanceOf(to1, 1), 0);
    }

    function testPuzzle2BatchTransfer1Id4Remaining () public {
        address to1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 2; i++) {
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
        }

        address to2 = address(1);
        for(uint8 i=3; i <= 4; i++) {
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
        }

        
        uint256[] memory ids = new uint256[](2);
        ids[0] = 3;
        ids[1] = 4;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 3;
        amounts[1] = 2;
        vm.prank(to2);
        puzzle.safeBatchTransferFrom(
            to2,
            to1,
            ids,
            amounts,
            "0x"
        );
        assertEq(puzzle.balanceOf(to1, 5), 2);
        assertEq(puzzle.balanceOf(to1, 4), 0);
        assertEq(puzzle.balanceOf(to2, 4), 1);
        assertEq(puzzle.balanceOf(to1, 3), 1);
        assertEq(puzzle.balanceOf(to1, 2), 1);
        assertEq(puzzle.balanceOf(to1, 1), 1);
    }

    function testPuzzle2Transfer1Remining () public {
        address to1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 3; i++) {
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
        }

        address to2 = address(1);
        for(uint8 i=4; i <= 4; i++) {
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
        }
        vm.prank(to2);
        puzzle.safeTransferFrom(
            to2,
            to1,
            uint256(4),
            uint256(2),
            "0x"
        );
        assertEq(puzzle.balanceOf(to1, 5), 2);
        assertEq(puzzle.balanceOf(to1, 4), 0);
        assertEq(puzzle.balanceOf(to2, 4), 1);
        assertEq(puzzle.balanceOf(to1, 3), 1);
        assertEq(puzzle.balanceOf(to1, 2), 1);
        assertEq(puzzle.balanceOf(to1, 1), 1);
    }

    function testPuzzle1EachBatchTransfer1Remining () public {
        address to1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        for(uint8 i=1; i <= 2; i++) {
            puzzle.mintParts(to1, i);
            puzzle.mintParts(to1, i);
        }

        address to2 = address(1);
        for(uint8 i=3; i <= 4; i++) {
            puzzle.mintParts(to2, i);
            puzzle.mintParts(to2, i);
        }

        
        uint256[] memory ids = new uint256[](2);
        ids[0] = 3;
        ids[1] = 4;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1;
        amounts[1] = 1;
        vm.prank(to2);
        puzzle.safeBatchTransferFrom(
            to2,
            to1,
            ids,
            amounts,
            "0x"
        );
        assertEq(puzzle.balanceOf(to1, 5), 1);
        assertEq(puzzle.balanceOf(to2, 4), 1);
        assertEq(puzzle.balanceOf(to2, 3), 1);
        assertEq(puzzle.balanceOf(to1, 2), 1);
        assertEq(puzzle.balanceOf(to1, 1), 1);
    }

}
