//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IBEP721Receiver.sol";

contract BEP721Receiver is IBEP721Receiver {
    function onBEP721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return bytes4(keccak256("onBEP721Received(address,address,uint256,bytes)"));
    }
}