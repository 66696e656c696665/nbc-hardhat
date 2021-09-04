//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../BEP/BEP20.sol";
import "../BEP/BEP20Capped.sol";

/**
 * @dev Total supply starts at 100,000,000 (100 million)
 *      Supply will have a maximum cap of 130,000,000 (130 million)
 *      through yield farming methods
 * 
 */
contract NBCoin is BEP20("NBCoin Test Alpha", "NBCa"), BEP20Capped(130000000 * 10 ** 18) {
    uint256 private totalTokens;

    constructor() payable {
        totalTokens = 100000000 * 10 ** 18;
        _transfer(address(0), _msgSender(), totalTokens);
        emit Transfer(address(0), _msgSender(), totalTokens);
    }
}