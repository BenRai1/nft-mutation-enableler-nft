// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import {Base64} from "./libraries/Base64.sol";

abstract contract BaseNftInterface {
    function getNumberOfBaseNftsOwned(address _senderAddress) public view virtual returns (uint256);

    function getOwnerOfBaseNft(uint256 _tokenId) public view virtual returns (address);

    function getCurrtenBaseNftAmoundMinted() public view virtual returns (uint256);
}

contract EnablerNft is ERC721URIStorage, Ownable {
    address BASE_NFT_CONTRACT_ADDRESS = 0xdf94318A713Af24b6D09E0513532e4e17a8c18C4;
    BaseNftInterface BaseNftContract = BaseNftInterface(BASE_NFT_CONTRACT_ADDRESS);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => uint256) numberOfEnablerNftsOwned;
    mapping(uint256 => address) ownerOfEnablerNft;
    mapping(uint256 => bool) alreadyUsedBaseNftIds;
    uint256[] usedBaseNftIdsArray;
    uint256 lengthBaseNftArray;

    uint256 totalSupplyEnablerNfts = 50;
    uint256 totalAvailableSupplyEnablerNfts;

    string svg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: #84cc16; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>ENABLER NFT</text></svg>";

    event EnablerNftMinted(address sender, uint256 tokenId);

    constructor() ERC721("EnablerNFT", "ENAB") {
        console.log("");
    }

    function mintEnablerNft(uint256 _baseNftID) public {
        // check if user ownes the Token that should be used for minting

        require(
            BaseNftContract.getOwnerOfBaseNft(_baseNftID) == msg.sender,
            "Token selected for mint does not belong to you"
        );

        //check if token that should be used for minting is still entitled for minting
        require(
            alreadyUsedBaseNftIds[_baseNftID] == false,
            "Token was already used for minting an Enabler Nft"
        );

        uint256 newItemId = _tokenIds.current();

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Enabler NFT", "description": "NFT needed to mutate the base NFT", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, finalTokenUri);

        numberOfEnablerNftsOwned[msg.sender]++;
        ownerOfEnablerNft[newItemId] = msg.sender;
        usedBaseNftIdsArray.push(_baseNftID);
        lengthBaseNftArray++;
        _tokenIds.increment();
        alreadyUsedBaseNftIds[_baseNftID] = true;
        totalAvailableSupplyEnablerNfts++;
        emit EnablerNftMinted(msg.sender, newItemId);
    }

    function setTotalSupplyEnablerNft(uint256 _newTotalSupply) external onlyOwner {
        totalSupplyEnablerNfts = _newTotalSupply;
    }

    function getTotalSupplyEnablerNft() public view returns (uint256) {
        return totalSupplyEnablerNfts;
    }

    function getCurrentEnablerNftAmoundMinted() public view returns (uint256) {
        return _tokenIds.current();
    }

    function getNumberOfEnablerNftsOwned(address _senderAddress) public view returns (uint256) {
        return numberOfEnablerNftsOwned[_senderAddress];
    }

    function getOwnerOfEnablerNft(uint256 _tokenId) public view returns (address) {
        return ownerOfEnablerNft[_tokenId];
    }

    function getNumberBaseNftsOwned(address _owner) public view returns (uint256) {
        return BaseNftContract.getNumberOfBaseNftsOwned(_owner);
    }

    function setBaseNftContractAddress(address _newBaseNftContractAddress) public {
        require(
            _newBaseNftContractAddress != getBaseNftContractAddress(),
            "The new Base NFT Contract Address is the same as the old one"
        );
        BASE_NFT_CONTRACT_ADDRESS = _newBaseNftContractAddress;
        BaseNftContract = BaseNftInterface(BASE_NFT_CONTRACT_ADDRESS);
        for (uint256 i; i < lengthBaseNftArray; i++) {
            alreadyUsedBaseNftIds[usedBaseNftIdsArray[i]] = false;
        }
    }

    function getBaseNftContractAddress() public view returns (address) {
        return BASE_NFT_CONTRACT_ADDRESS;
    }

    function checkIfBaseNftIdAlreadyUsed(uint256 _id) public view returns (bool) {
        return alreadyUsedBaseNftIds[_id];
    }

    function burnNft(uint256 _id) public {
        ownerOfEnablerNft[_id] = 0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b;
        totalAvailableSupplyEnablerNfts--;
    }

    function getAvaialableSupplyEnablerNfts() public view returns (uint256) {
        return totalAvailableSupplyEnablerNfts;
    }
    // function getNumberNftUsableForClaim
}
