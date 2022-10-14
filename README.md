# Puzzle-NFT
ERC1155 Collection that awards the address that collects all puzzle parts an special NFT that cant be minted by any address

## Objective 

The Puzzle contract creates a collection of parts that can be minted to different addresses. As an ERC1155, there is a supply for each NFT part and once the user collects all of them they get automatically burned while an special NFT gets minted.
There are many applications for this contract like ticker albums or upgradable characters in a game.

## Testing

The project uses Foundry framework. You can clone the repository and install dependencies

```
forge install
```

and test by running

```
forge test -vvv
```
