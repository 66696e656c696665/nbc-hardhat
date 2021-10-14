const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NBCoin contract", () => {
  let NBCoin;
  let nbcoin;
  let owner;
  let secondAddress;

  beforeEach(async () => {
    NBCoin = await ethers.getContractFactory("NBCoin", owner);
    nbcoin = await NBCoin.deploy();
    await nbcoin.deployed();
    [owner, secondAddress] = await ethers.getSigners();
  })

    it("Should return NBCoin as the token name", async () => {
        expect(await nbcoin.name()).to.equal("NBCoin");
    })

    it("Should return 100 million as the supply", async () => {
        const totalSupplyToCheck = await ethers.utils.parseUnits("100000000");
        expect(await nbcoin.totalSupply()).to.equal(totalSupplyToCheck);
    })
    it("Should return owner as the signer", async () => {
        //admin is inherited from AddressControl
        expect(await nbcoin.admin()).to.equal(owner.address); 
    })
    it("Should return a balance of 100 million for the owner", async () => {
        const balanceToCheck = await ethers.utils.parseUnits("100000000");
        expect(await nbcoin.balanceOf(owner.address)).to.equal(balanceToCheck);
    })
    it("Should transfer the exact amount to the second address", async () => {
        const amountToTransfer = 1000;
        const secondAddressBalanceBefore = await nbcoin.balanceOf(secondAddress.address);
        await nbcoin.transfer(secondAddress.address, amountToTransfer);
        const secondAddressBalanceAfter = await nbcoin.balanceOf(secondAddress.address);
        let difference = secondAddressBalanceAfter - secondAddressBalanceBefore
        expect(difference).to.equal(amountToTransfer);
    })
    it("Minter and admin should be the same", async () => {
        expect(await nbcoin.admin()).to.equal(await nbcoin.minter());
    })
    it("Should mint the exact value", async () => {
        //10000 tokens to wei using parseUnits => returns bigNumber
        const amountToMint = ethers.utils.parseUnits("10000");
        //get tx details using owner address and current nonce
        const transactionCount = await owner.getTransactionCount();
        let transaction = {
            from: owner.address,
            nonce: transactionCount
        }
        const totalSupplyBefore = await nbcoin.totalSupply();
        //get contract address for minting
        const contractAddress = await ethers.utils.getContractAddress(transaction);
        await nbcoin.mint(contractAddress, amountToMint);
        const totalSupplyAfter = await nbcoin.totalSupply();
        let difference = (totalSupplyAfter.sub(totalSupplyBefore));
        expect(difference).to.equal(amountToMint);
    })

})
