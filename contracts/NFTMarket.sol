//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter public _itemIds;
    Counters.Counter public _itemsSold;

    address payable owner;

    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itmeId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) public idToMarketItem;

    event MarketItemListed(
        uint256 indexed itmeId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool sold
    );

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "NFTMarket: Price should be at least 1 wei");
        require(msg.value == listingPrice,"NFTMarket: Price must be equal to listing price.");

        _itemIds.increment();
        uint newItemId = _itemIds.current();
        idToMarketItem[newItemId] = MarketItem(
            newItemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        
        emit MarketItemListed(
            newItemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }


    function buyNFT(address nftContract, uint256 itemId) public payable nonReentrant {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;

        require(msg.value == price, "NFTMarket: Asking price did not match.");

        idToMarketItem[itemId].owner.transfer(msg.value);
        
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;

        _itemsSold.increment();

        payable(address(owner)).transfer(listingPrice);
    }

    function fetchMarketItems() public view returns(MarketItem[] memory) {
        uint totalItems = _itemIds.current();
        uint soldItems = _itemsSold.current();
        
        uint unsoldItems = totalItems - soldItems;
        MarketItem[] memory items = new MarketItem[](unsoldItems);
        uint index;

        for(uint i=0; i < totalItems; i++) {
            if(idToMarketItem[i+1].owner == address(0)){
                MarketItem storage currentItem = idToMarketItem[i+1];
                items[index] = currentItem;
                index += 1; 
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns(MarketItem[] memory) {
        uint totalItems = _itemIds.current();
        uint itemCount = 0;
        uint index;
        
        for(uint i=0; i < totalItems; i++){
            itemCount += 1;
        }
        
        MarketItem[] memory items = new MarketItem[](itemCount);
      

        for(uint i=0; i < totalItems; i++) {
            if(idToMarketItem[i+1].owner == msg.sender){
                MarketItem storage currentItem = idToMarketItem[i+1];
                items[index] = currentItem;
                index += 1; 
            }
        }
        return items;
    }

    function fetchCreatedNFT() public view returns(MarketItem[] memory) {
        uint totalItems = _itemIds.current();
        uint itemCount = 0;
        uint index;
        
        for(uint i=0; i < totalItems; i++){
            itemCount += 1;
        }
        
        MarketItem[] memory items = new MarketItem[](itemCount);
      

        for(uint i=0; i < totalItems; i++) {
            if(idToMarketItem[i+1].seller == msg.sender){
                MarketItem storage currentItem = idToMarketItem[i+1];
                items[index] = currentItem;
                index += 1; 
            }
        }
        return items;
    }

}
