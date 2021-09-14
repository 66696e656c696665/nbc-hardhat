//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../crowdsale/Crowdsale.sol";

contract NBCoinCrowdsale is Crowdsale {
    constructor() Crowdsale(
        4000, 
        payable(0x213D2806B07fB2BFCd51fCbC7503755784C72F09), 
        IBEP20(0x80801BDC978efE99E01CBa129579aB178BfE191b),
        0.1 * 10 ** 18,
        2 * 10 ** 18
        ) {
        }
}

