// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./StoreFront.sol";

contract BookStore is ERC1155 {
    uint256 private _currentBookVersionId;

    // mapping(uint256 => uint256) private _bookVersionPrices;
    // mapping(uint256 => address) private _bookVersionCurrencies;

    mapping(uint256 => BookVersion) private _bookVersions;
    StoreFront private _storeFront;
    struct BookVersion {
        uint256 price;
        address currency;
        address author;
    }

    address private _owner;

    constructor() ERC1155("https://exapmple.com/api/{id}.json") {
        _currentBookVersionId = 1;
        _owner = msg.sender;
    }

    function setStoreFront(address _storeFrontAddress) public {
        require(
            msg.sender == _owner,
            "BookStore: Only contract owner can set storeFront"
        );
        _storeFront = StoreFront(_storeFrontAddress);
    }

    // NOTE: Account for number of decimals on various whitelisted currencies(!)
    function publish(
        uint256 _quantity,
        uint256 _price,
        address _currency
    ) public {
        _mint(msg.sender, _currentBookVersionId, _quantity, "");
        _bookVersions[_currentBookVersionId] = BookVersion(
            _price,
            _currency,
            msg.sender
        );
        _currentBookVersionId += 1;
    }

    function transferFromAuthor(address _buyer, uint256 _bookVersionId) public {
        require(
            msg.sender == address(_storeFront),
            "Method can only be called by Store Front contract."
        );
        BookVersion memory bookVersion = _bookVersions[_bookVersionId];
        safeTransferFrom(bookVersion.author, _buyer, _bookVersionId, 1, "");
    }

    function bookVersionPrice(uint256 _bookVersionId)
        public
        view
        returns (uint256)
    {
        return _bookVersions[_bookVersionId].price;
    }

    function bookVersionCurrency(uint256 _bookVersionId)
        public
        view
        returns (address)
    {
        return _bookVersions[_bookVersionId].currency;
    }

    function bookVersionAuthor(uint256 _bookVersionId)
        public
        view
        returns (address)
    {
        return _bookVersions[_bookVersionId].author;
    }

    // TODO: create setStoreFront method that's onlyOwner
}
