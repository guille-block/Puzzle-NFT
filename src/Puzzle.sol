pragma solidity >=0.8.13;

import "solmate/tokens/ERC1155.sol";

interface IStructPuzzle {
    struct Mint {
        address to;
        uint256 piece;
    }

    struct Pieces {
        uint256 partsId;
        uint256 supply;
    }
}

contract Puzzle is ERC1155, IStructPuzzle {

    uint256 public totalIdRef;
    address public owner;
    string public name;
    string public tokenUri;

    event MintedPuzzle(address indexed to, uint256 amount);

    mapping(uint256 => uint256) public idToAmountsReserve;
    mapping(address => mapping(uint256 => uint256)) public userToPartsToAmounts;

    modifier onlyOwner {
        require(msg.sender == owner, "Not Owner");
      _;
    }

    constructor(
        string memory _name,
        string memory _uri,
        Pieces memory pieces
        ) ERC1155() {
            
            totalIdRef = pieces.partsId;
            name = _name;
            owner = msg.sender;
            tokenUri = _uri;

            for(uint256 i = 1; i <= pieces.partsId;) {
                idToAmountsReserve[i] = pieces.supply;
                unchecked {
                    i++;
                }
            }

        }


    function mintPartsBatch(Mint[] calldata piecesToMint) external onlyOwner{
        for(uint256 i =0; i< piecesToMint.length;) {
            mintParts(piecesToMint[i].to, piecesToMint[i].piece);
            unchecked {
                ++i;
            }
        } 
    }

    function mintParts(address to, uint256 partId) public onlyOwner {
        require(idToAmountsReserve[partId] > 0, "NO MORE PARTS TO MINT");
        unchecked {
            idToAmountsReserve[partId]--;
            userToPartsToAmounts[to][partId]++;
        }
        _mint(to, partId, 1, "");
        afterTokenTransfer(to);
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        return tokenUri;
    }

    
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual override {
        super.safeTransferFrom(from, to, id, amount, data);
        unchecked {
            userToPartsToAmounts[from][id] -= amount;
            userToPartsToAmounts[to][id] += amount;
        }
        afterTokenTransfer(to);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual override {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
        for(uint256 i =0; i< ids.length;) {
            unchecked {
                userToPartsToAmounts[from][ids[i]]-= amounts[i];
                userToPartsToAmounts[to][ids[i]] += amounts[i];
                i++;
            }
        }
        afterTokenTransfer(to);
    }

    function mintPuzzle(address _to, uint256 counter) private {
        uint256 totalId = totalIdRef;
        unchecked {
            userToPartsToAmounts[_to][totalId]++;
        }
        _mint(_to, totalId, counter, "");
    }

    function burtParts(address from, uint256 amountOfParts, uint256 counter) private {
        for(uint256 i = 1; i <= amountOfParts;) { 
            unchecked {
                _burn(from, i, counter);
                userToPartsToAmounts[from][i] -= counter;
               i++;  
            }
        }
    }

    function verifyPartsToPuzzle(address _to) private returns(bool, uint256, uint256) {
        uint256 amountOfParts = totalIdRef - 1;
        uint256 counter = amountOfParts;
        for(uint256 i =1; i<= amountOfParts;) {

             if(userToPartsToAmounts[_to][i] < counter) {
                 counter = userToPartsToAmounts[_to][i];
             }

             unchecked {
                  i++;
             }
        }

        if(counter > 0) {
            return (true, amountOfParts, counter);
        } else {
            return (false, amountOfParts, counter);
        }
    }


    function afterTokenTransfer(address _to) private {
        (bool checked, uint256 amountOfParts, uint256 counter) = verifyPartsToPuzzle(_to);
        if(checked) {
            burtParts(_to, amountOfParts, counter);
            mintPuzzle(_to, counter); 
            emit MintedPuzzle(_to, counter);
        }
    }
}