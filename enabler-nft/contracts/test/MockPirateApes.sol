// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MockPirateApes is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 max_supply_pirate_ape_nfts = 50;
    uint256 MAX_MINT_PER_WALLET = 7;
    mapping(address => uint256) numberOfPirateApeNftsOwned;
    mapping(address => uint256) numberOfPirateApesMinted;
    string[] linksMetadata = [
        "ipfs://QmSRG9Y5RrBST1FVPf6p7qQgLz7YhkfwsS4gC3tSumXdM6",
        "ipfs://QmYk684YiRsuy2pZNBWHyBjVKrLbi1EtkLT9KM5TxgBygQ",
        "ipfs://QmTroXS431YiiN6WRzoHpMQ7iNU7sh7n7PdLYkmAWGE24m",
        "ipfs://QmQfQaDDDmABpJUXNPMKWQGpB9SbEj8i5EqLnUvZf4cQ44",
        "ipfs://QmdAupguVX6wtbSKDwXVACzt1VDnozZ2SDMixv7g5fMfqg",
        "ipfs://QmbrTzXgsHQ6qJ8iCuYxXA484ubnxiWJGtFbW91r2DFRWp"
    ];

    event NewPirateApeNftMinted(address sender, uint256 tokenId);

    constructor() ERC721("PirateApes", "PAP") ReentrancyGuard() {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _pickRandomApeNFT(uint256 tokenId) private view returns (string memory) {
        uint256 rand = _random(string(abi.encodePacked("APE_NFT", Strings.toString(tokenId))));
        rand = rand % linksMetadata.length;        
        return linksMetadata[rand];
    }

    function _random(string memory input) private pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function safeMintPirateApe() public nonReentrant whenNotPaused {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= max_supply_pirate_ape_nfts, "Sorry, all NFTs have been minted");
        uint256 numberPirateApesMinted = numberOfPirateApesMinted[msg.sender];
        require(
            numberPirateApesMinted < MAX_MINT_PER_WALLET,
            "Sorry, you already minted all NFTs you are allowed to mint"
        );
        _tokenIdCounter.increment();
        string memory uri = _pickRandomApeNFT(tokenId);
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        numberOfPirateApeNftsOwned[msg.sender]++;
        emit NewPirateApeNftMinted(msg.sender, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, amount);
    }

    // -----------setter and getter functions --------------

    function setTotalSupplyPirateApesNft(uint256 _newTotalSupply) external onlyOwner {
        max_supply_pirate_ape_nfts = _newTotalSupply;
    }

    function getTotalSupplyPirateApesNft() public view returns (uint256) {
        return max_supply_pirate_ape_nfts;
    }

    function getCurrtenPirateApeNftAmoundMinted() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function getNumberOfPirateApeNftsOwned(address _senderAddress) public view returns (uint256) {
        return numberOfPirateApeNftsOwned[_senderAddress];
    }
}
