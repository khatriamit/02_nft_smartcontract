// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./BookStore.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StoreFront {
    BookStore private _bookstore;

    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    // TODO: restict access to only the owner
    function setBookStore(address _bookStoreAddress) public {
        require(
            msg.sender == _owner,
            "StoreFront: Only contract owner can set bookStore"
        );
        _bookstore = BookStore(_bookStoreAddress);
    }

    function purchaseFromAuthor(uint256 _bookVersionId) public {
        ERC20 purchaseToken = ERC20(
            _bookstore.bookVersionCurrency(_bookVersionId)
        );

        address author = _bookstore.bookVersionAuthor(_bookVersionId);
        uint256 price = _bookstore.bookVersionPrice(_bookVersionId);

        purchaseToken.transferFrom(msg.sender, author, price);

        _bookstore.transferFromAuthor(msg.sender, _bookVersionId);
    }
}
