// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

import {Base64} from "../libraries/Base64.sol";

contract MockBaseNft is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => uint256) numberOfNftsOwned;
    mapping(uint256 => address) ownerOfNft;
    mapping(uint256 => string) keyForNft;

    uint256 totalSupply = 50;

    string svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: ";
    string svgPartTwo =
        "; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartThree =
        "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string svgPartFour = "</text></svg>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever!
    string[] text = ["Fire ", "Water", "Air", "Earth"];
    string[] textColors = ["#DA291C", "#00AFD7", "#ffffff", "#97D700"];
    string[] bgColors = ["#000000", "#002554", "#005EB8", "#13322B"];

    event NewFirstNftMinted(address sender, uint256 tokenId);

    constructor() ERC721("FirstNftBb", "FNBB") {
        console.log("");
    }

    function pickRandomText(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("TEXT", Strings.toString(tokenId))));
        rand = rand % text.length;
        return text[rand];
    }

    function pickRandomTextColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("TEXT_COLOR", Strings.toString(tokenId))));
        rand = rand % textColors.length;
        return textColors[rand];
    }

    function pickRandomBgColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("BG_COLOT", Strings.toString(tokenId))));
        rand = rand % bgColors.length;
        return bgColors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function mintBaseNft() public {
        uint256 newItemId = _tokenIds.current();
        string memory randomText = pickRandomText(newItemId);
        string memory randomTextColor = pickRandomTextColor(newItemId);
        string memory randomBgColor = pickRandomBgColor(newItemId);

        string memory nftKey = string.concat(randomTextColor, randomBgColor, randomText);
        // console.log("nftKey", nftKey);

        keyForNft[newItemId] = nftKey;
        // console.log("keyForNft mapped", keyForNft[newItemId]);
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                randomTextColor,
                svgPartTwo,
                randomBgColor,
                svgPartThree,
                randomText,
                svgPartFour
            )
        );

        // console.log("\n--------------------");
        // console.log(finalSvg);
        // console.log("--------------------\n");

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        randomText,
                        '", "description": "',
                        randomTextColor,
                        " ",
                        randomBgColor,
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        // console.log("\n--------------------");
        // console.log(finalTokenUri);
        // console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        // console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        numberOfNftsOwned[msg.sender]++;
        // console.log("numberOfNftsOwned", numberOfNftsOwned[msg.sender]);
        ownerOfNft[newItemId] = msg.sender;
        // console.log("ownerOfNft", ownerOfNft[newItemId]);

        _tokenIds.increment();
        emit NewFirstNftMinted(msg.sender, newItemId);
    }

    function setTotalSupply(uint256 _newTotalSupply) external onlyOwner {
        totalSupply = _newTotalSupply;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getCurrtenBaseNftAmoundMinted() public view returns (uint256) {
        return _tokenIds.current();
    }

    function getNumberOfBaseNftsOwned(address _senderAddress) public view returns (uint256) {
        return numberOfNftsOwned[_senderAddress];
    }

    function getOwnerOfBaseNft(uint256 _tokenId) public view returns (address) {
        return ownerOfNft[_tokenId];
    }

    function getKeyForNft(uint256 _tokenId) public view returns (string memory) {
        return keyForNft[_tokenId];
    }
}
