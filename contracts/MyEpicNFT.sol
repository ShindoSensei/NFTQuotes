// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0; // ensure to change the version in hardhat.config.js to the same 0.8.0

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

//We need to import helper functions from the contract (Base64.sol)
import { Base64 } from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
    //Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    event NewEpicNFTMinted(address sender, uint256 tokenId); 
    //events are messages our smart contracts throw out that we can capture on our client in real-time

    //We need to pass the name of our NFTs token and its symbol.
    constructor() ERC721 ("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract. Woah!");
    }

    //public functionc an be called anywhere, both internally and externally
    //view function promises not to modify the state but can read.
    //returns (type ) statement is required if want to return a value from function

    //private function means only callable from other functions inside the contract
    //external can only be called outside the contract
    //internal function is like private but can also be called by contracts that inherit from the current one
    //pure function promises not to modify or read from the state.
  function random(string memory input) internal pure returns (uint256) {
      //keccak256() method converts the input into a 256-bit hash
      //uint256() method converts the input into a uint256 integer, which in this case is converting a hash into a unit256 number
      return uint256(keccak256(abi.encodePacked(input))); //This returns a uin256 integer
  }

    // A function our user will hit to get their NFT.
    function makeAnEpicNFT(string memory quote) public {
        //Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvg, quote, "</text></svg>"));
        // console.log("\n--------------------");
        // console.log(finalSvg);
        // console.log("--------------------\n");

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the quote.
                        quote,
                        '", "description": "Immortalised quote on the Rinkeby Blockchain.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        //Actually mint the NFT to the sender using msg.sender . msg.sender is a variable Solidity provides to access public address of person calling this contract
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data. 2nd param is the metadata json that is encoded as a base-64 string. We'll be setting the metadata later!
        _setTokenURI(newItemId, finalTokenUri);

        //Set the NFTs data. 2nd param is the metadata json that is encoded as a base-64 string
        // _setTokenURI(newItemId, "data:application/json;base64,ewogICAgIm5hbWUiOiAiRXBpY0xvcmRIYW1idXJnZXIiLAogICAgImRlc2NyaXB0aW9uIjogIkFuIE5GVCBmcm9tIHRoZSBoaWdobHkgYWNjbGFpbWVkIHNxdWFyZSBjb2xsZWN0aW9uIiwKICAgICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0TkNpQWdJQ0E4YzNSNWJHVStMbUpoYzJVZ2V5Qm1hV3hzT2lCM2FHbDBaVHNnWm05dWRDMW1ZVzFwYkhrNklITmxjbWxtT3lCbWIyNTBMWE5wZW1VNklERTBjSGc3SUgwOEwzTjBlV3hsUGcwS0lDQWdJRHh5WldOMElIZHBaSFJvUFNJeE1EQWxJaUJvWldsbmFIUTlJakV3TUNVaUlHWnBiR3c5SW1Kc1lXTnJJaUF2UGcwS0lDQWdJRHgwWlhoMElIZzlJalV3SlNJZ2VUMGlOVEFsSWlCamJHRnpjejBpWW1GelpTSWdaRzl0YVc1aGJuUXRZbUZ6Wld4cGJtVTlJbTFwWkdSc1pTSWdkR1Y0ZEMxaGJtTm9iM0k5SW0xcFpHUnNaU0krUlhCcFkweHZjbVJJWVcxaWRYSm5aWEk4TDNSbGVIUStEUW84TDNOMlp6ND0iCn0=");

        console.log("An NFT with ID %s has been minted to %s", newItemId, msg.sender);

        //Increment the counter for when the next NFT is minted.
        _tokenIds.increment();
        emit NewEpicNFTMinted(msg.sender, newItemId); 
        //We only emit the NFT minted event here because even though this MyEpicNFT contract may be mined, it does not necessarily mean that the NFT was actually minted (because function makeAnEpicNFT needs to have properly been executed for minting to be complete)
        //This emitting is something like a webhook, and we're sending the newItemID to the frontend.
    }
}