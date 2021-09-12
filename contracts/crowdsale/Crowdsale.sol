//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../security/Context.sol";
import "../security/ReentrancyGuard.sol";
import "../BEP/SafeBEP20.sol";
import "../BEP/IBEP20.sol";
import "../security/Pausable.sol";
abstract contract Crowdsale is Context, ReentrancyGuard, Pausable {
    using SafeBEP20 for IBEP20;

    /**
     * @dev The token being sold
     */
    IBEP20 private _token;

    /**
     * @dev `_wallet` is the address where all the funds will
     * be collected.
     */
    address payable private _wallet;

    /**
     * @dev `_rate` refers to the amount of token units the buyer gets PER WEI.
     * This refers to teh conversion between wei and the smallest and indivisible token unit.
     * Suppose you're using a rate of 1 with a token called TOKEN has 18 decimals:
     * 1 wei will give you 1 unit, or 1 * 10 ** -18 TOKEN.
     */
    uint256 private _rate;

    /**
     * @dev Amount of wei raised in total
     * Note Dividing it by the token decimals will give you the true amount of tokens
     */
    uint256 private _weiRaised;

    /**
     * Event for token purchase logging
     * @param buyer refers to who bought the tokens
     * @param beneficiary refers to who got the tokens
     * @param value refers to the weis paid for purchase
     * @param amount refers to the amount of tokens purchased
     */
    event TokensPurchased(address indexed buyer, address indexed beneficiary, uint256 value, uint256 amount);

    constructor(uint256 rate_, address payable wallet_, IBEP20 token_) {
        require(rate_ > 0, "Crowdsale: Rate is 0");
        require(wallet_ != address(0), "Crowdsale: Wallet is the zero address");
        require(address(token_) != address(0), "Crowdsale: Token is the zero address");

        _rate = rate_;
        _wallet = wallet_;
        _token = token_;
    }

     /**
     * @dev fallback function 
     * This function executes when a call to the contract when no data is supplied.
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
    fallback() external whenNotPaused payable {
        buyTokens(_msgSender());
    }

    /**
     * @dev Returns the token being sold.
     */
    function token() public view returns (IBEP20) {
        return _token;
     }

    /**
     * @dev Returns the wallet address where the funds are being collected.
     */
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    /**
     * @dev Returns the number of token units a buyer gets per wei.
     */
    function rate() public view returns (uint256) {
        return _rate;
    }

    /**
     * @dev Returns the amount of wei raised
     * Note: Divide by the token decimals to receive true amount of tokens.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary) public nonReentrant whenNotPaused payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        /**
         * @dev Calculates token amount to be created
         */
        uint256 tokens = _getTokenAmount(weiAmount);

        /**
         * @dev Updates `_weiRaised` by how much the user buys
         */
        _weiRaised += weiAmount;

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised() + weiAmount <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal virtual view {
        require(beneficiary != address(0), "Crowdsale: Beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid
     * conditions are not met.
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal virtual view {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions,
     * etc.)
     * @param beneficiary Address receiving the tokens
     * @param weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount * _rate;
    }

    /**
     * @dev Determines how BNB is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}

