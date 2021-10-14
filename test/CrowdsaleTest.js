// const { expect } = require("chai");
// const { ethers } = require("hardhat");

// describe("Crowdsale contract", () => {
//   let NBCoinCrowdsale;
//   let nbcoinCrowdsale;
//   let owner;
//   let secondAddress;

//   beforeEach(async () => {
//     NBCoinCrowdsale = await ethers.getContractFactory("NBCoinCrowdsale");
//     nbcoinCrowdsale = await NBCoinCrowdsale.deploy();
//     await nbcoinCrowdsale.deployed();
//     [owner, secondAddress] = await ethers.getSigners();
//   })

//   describe("Rate", () => {
//     it("Should return the correct rate", async () => {
//       const rate = await nbcoinCrowdsale.getRate();
//       expect(rate.toNumber()).to.equal(4000);
//       console.log(owner.address);
//       console.log(secondAddress.address);
//     })  
//   })

//   describe("Token address", () => {
//     it("Should return the correct token which is NBCoin", async () => {
//       const nbcoinAddress = "0x80801BDC978efE99E01CBa129579aB178BfE191b";
//       const addressToCheck = await nbcoinCrowdsale.getToken();
//       expect(addressToCheck).to.equal(nbcoinAddress);
//     })
//   })

// })
