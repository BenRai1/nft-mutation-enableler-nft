// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

abstract contract PirateApesInterface {
    function getNumberOfPirateApeNftsOwned(address _senderAddress) public view virtual returns (uint256);
    function ownerOf(uint256 tokenId) public view virtual returns (address);
}

contract RumToken is ERC1155, Ownable, Pausable, ERC1155Burnable, ReentrancyGuard {
    constructor() ERC1155("https://ipfs.filebase.io/ipfs/QmPUVyFrJYeJ7uFhC3zNFzm5DybkZfa4Nnd7U9ACt1F3Dn") {}

    address PIRATE_APES_NFT_CONTRACT_ADDRESS = 0xAb1b3DBcd5ba13348A20103664A8257D3Bc377D1;
    PirateApesInterface PirateApesContract = PirateApesInterface(PIRATE_APES_NFT_CONTRACT_ADDRESS);

    uint256 maxSupplyRumToken = 50;
    uint256 rumTokensMinted = 0;
    uint256 totalAvailableSupplyRumTokens = 0;
    uint256 rumToken = 0;
    mapping(uint256 => bool) alreadyUsedPirateApeIds;
    uint256[] arrayOfUsedPirateApesIds;

    event RumTokenMinted(address _mintedTo, uint256 tokenId);




    function mintRumToken(uint256 amount, uint256 pirateApeId )public nonReentrant whenNotPaused{
         // check if user ownes the Token that should be used for minting
        require (PirateApesContract.ownerOf(pirateApeId) == msg.sender, "You do not own the Pirate Ape you want to use for minting");
        
        //check if token that should be used for minting is still entitled for minting
        require(alreadyUsedPirateApeIds[pirateApeId] == false, "Pirate Ape was already used for minting a Rum Token");
        
        //check if there are still enough Rum Tokens that can be minted
        require(rumTokensMinted + amount <= maxSupplyRumToken, "You are trying to mint to much Tokens");
        rumTokensMinted += amount;
        alreadyUsedPirateApeIds[pirateApeId] = true;
        arrayOfUsedPirateApesIds.push(pirateApeId);
        totalAvailableSupplyRumTokens+= amount;
        _mint(msg.sender, rumToken, amount, "");
        emit RumTokenMinted(msg.sender, 0);

    }

    
   

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setMaxSupplyRumTokens (uint256 _newTotalSupply) external onlyOwner {
        maxSupplyRumToken = _newTotalSupply;
    }
    function getMaxSupplyRumTokens() public view returns (uint256) {
        return maxSupplyRumToken;
    }

    function getNumberRumTokensMinted() public view returns (uint256) {
        return rumTokensMinted;
    }


    function getNumberOfPirateApesOwned(address _owner) public view returns (uint256) {
        return PirateApesContract.getNumberOfPirateApeNftsOwned(_owner);
    }

    function setPirateApesContractAddress(address _newPirateApesContractAddress) public {
        require(
            _newPirateApesContractAddress != PIRATE_APES_NFT_CONTRACT_ADDRESS,
            "The new Pirate Apes Contract Address is the same as the old one"
        );
        PIRATE_APES_NFT_CONTRACT_ADDRESS = _newPirateApesContractAddress;
        PirateApesContract = PirateApesInterface(PIRATE_APES_NFT_CONTRACT_ADDRESS);
        for (uint256 i; i < arrayOfUsedPirateApesIds.length; i++) {
            alreadyUsedPirateApeIds[arrayOfUsedPirateApesIds[i]] = false;
        }
    }

    function getPirateApesContractAddress() public view returns (address) {
        return PIRATE_APES_NFT_CONTRACT_ADDRESS;
    }

    function checkIfPirateApeIdAlreadyUsed(uint256 _id) public view returns (bool) {
        return alreadyUsedPirateApeIds[_id];
    }

    function burnRumToken(uint256 _amount) public {
        require(balanceOf(msg.sender, rumToken) >0, "You do not have any Rumtokens to burn");
        safeTransferFrom(msg.sender,0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b, rumToken, _amount,"") ;
        totalAvailableSupplyRumTokens--;
    }

    function getAvaialableSupplyRumTokens() public view returns (uint256) {
        return totalAvailableSupplyRumTokens;
    }






}

