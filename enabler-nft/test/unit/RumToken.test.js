const { expect, assert } = require("chai")

describe("RumToken", () => {
    let rumTokenContract, mockPirateApesContract, accounts, owner, txn

    beforeEach(async () => {
        //deploy mock contract Pirate Apes
        const nftContractFactory1 = await ethers.getContractFactory("MockPirateApes")
        const mockPirateApesContract = await nftContractFactory1.deploy()
        await mockPirateApesContract.deployed()
        // console.log("mockPirateApesContract deployed to:", mockPirateApesContract.address)

        txn = await mockPirateApesContract.safeMintPirateApe()
        txn = await mockPirateApesContract.safeMintPirateApe()

        // Deploy Rum Token Contract

        const RumTokenFactory = await ethers.getContractFactory("RumToken")
        rumTokenContract = await RumTokenFactory.deploy()
        await rumTokenContract.deployed()
        accounts = await ethers.getSigners()
        owner = accounts[0].address
        // set the BaseNFT Contract Address
        await rumTokenContract.setPirateApesContractAddress(mockPirateApesContract.address)
    })
    context("Max supply", async () => {
        it("Should set the max supply propperly", async () => {
            await rumTokenContract.setMaxSupplyRumTokens(30)
            assert.equal(await rumTokenContract.getMaxSupplyRumTokens(), 30)
        })

        it("Fails if not Owner tries to set the total supply", async () => {
            await expect(rumTokenContract.connect(accounts[1]).setMaxSupplyRumTokens(30)).to.be
                .reverted
        })
        it("Should not be able to mint more than max supply", async () => {
            await rumTokenContract.setMaxSupplyRumTokens(1)
            await rumTokenContract.mintRumToken(1, 0)
            await expect(rumTokenContract.mintRumToken(1, 1)).to.be.revertedWith(
                "You are trying to mint to much Tokens"
            )
        })
    })

    context("Setting Pirate Apes contract Address", async () => {
        it("Address of the Pirate Apes should be the one that was set", async () => {
            let currentAddress = await rumTokenContract.getPirateApesContractAddress()
            console.log("currentAddress", currentAddress)
            console.log("Mock Address", mockPirateApesContract.address)

            assert.equal(
                await rumTokenContract.getPirateApesContractAddress(),
                mockPirateApesContract.address
            )
        })
        it("Setting a new Pirate Apes Address should reset the mapping of the used Pirate Apes Ids", async () => {
            await rumTokenContract.mintRumToken(1, 0)
            await rumTokenContract.setPirateApesContractAddress(
                "0x103A1AAda81BB8877017E04274ab5256e34cB048"
            )
            assert.equal(await rumTokenContract.checkIfpirateApeIdAlreadyUsed(0), false)
        })

        it("Mapping of used Pirate Apes Ids schould only be reste when Pirate Apes Address really changes", async () => {
            await expect(
                rumTokenContract.setPirateApesContractAddress(mockPirateApesContract.address)
            ).to.be.revertedWith("The new Pirate Apes Contract Address is the same as the old one")
        })
    })

    context("Minting Pirate Ape success", async () => {
        it("Minting should increase the minted Amount of nfts by 1", async () => {
            await rumTokenContract.mintRumToken(1, 0)
            assert.equal(await rumTokenContract.getNumberRumTokensMinted(), 1)
        })

        it("Minting should increase the number of owned Nfts of the minter", async () => {
            await rumTokenContract.mintRumToken(1, 0)
            assert.equal(await rumTokenContract.balanceOf(owner, 0), 1)
        })
        it("Should be possible to mint after unpausing the contract", async () => {
            await rumTokenContract.pause()
            await rumTokenContract.unpause()
            await rumTokenContract.mintRumToken(1, 0)
            assert.equal(await rumTokenContract.getNumberRumTokensMinted(), 1)
        })
    })

    context("Minting failing", async () => {
        it("Should fail if you want to use a Pirate Ape that does not exist", async () => {
            await expect(rumTokenContract.mintRumToken(1, 2)).to.be.revertedWith(
                "ERC721: invalid token ID"
            )
        })

        it("Should fail if you want to use a Pirate Ape that does not belong to you", async () => {
            await expect(
                rumTokenContract.connect(accounts[1]).mintRumToken(1, 0)
            ).to.be.revertedWith("You do not own the Pirate Ape you want to use for minting")
        })

        it("Minting should fail if Pirate Ape was already used for minting", async () => {
            await rumTokenContract.mintRumToken(1, 0)
            await expect(rumTokenContract.mintRumToken(1, 0)).to.be.revertedWith(
                "Pirate Ape was already used for minting a Rum Token"
            )
        })

        it("Should not be possible to mint if contract is paused", async () => {
            await rumTokenContract.pause()
            await expect(rumTokenContract.mintRumToken(1, 0)).to.be.revertedWith("Pausable: paused")
        })
    })

    context("Burning Rum Tokens", async () => {
        it("Burning Rum Tokens should reduce the supply of Rum Tokens", async () => {
            await rumTokenContract.mintRumToken(1, 0)
            await rumTokenContract.mintRumToken(1, 1)
            const supply = await rumTokenContract.getAvaialableSupplyRumTokens()
            await rumTokenContract.burnRumToken(1)
            assert.equal(await rumTokenContract.getAvaialableSupplyRumTokens(), 1)
        })
        it("Burning should reduce the amount of tokens the burner has", async () => {
            await rumTokenContract.mintRumToken(1, 0)
            await rumTokenContract.mintRumToken(1, 1)
            await rumTokenContract.burnRumToken(1)
            assert.equal(await rumTokenContract.balanceOf(owner, 0), 1)
        })
    })

    context("Interacting with the Pirate Ape contract", async () => {
        it("Owner should have 2 Pirate Apes", async () => {
            console.log("Owner", owner)
            assert.equal(await rumTokenContract.getNumberOfPirateApesOwned(owner), 2)
        })

        it("If Base Nft was already used for minting the Id should be in the list", async () => {
            await rumTokenContract.mintRumToken(1, 0)
            assert.equal(await rumTokenContract.checkIfPirateApeIdAlreadyUsed(0), true)
        })
    })
})
