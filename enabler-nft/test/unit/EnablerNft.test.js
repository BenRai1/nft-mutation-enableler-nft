const { expect, assert } = require("chai")

describe("EnablerNft", () => {
    let enablerNftContract, mockBaseNftContract, accounts, owner, txn

    beforeEach(async () => {
        //deploy mock contract Base Nft
        const nftContractFactory1 = await ethers.getContractFactory("MockBaseNft")
        mockBaseNftContract = await nftContractFactory1.deploy()
        await mockBaseNftContract.deployed()
        // console.log("mockBaseNftContract deployed to:", mockBaseNftContract.address)

        txn = await mockBaseNftContract.mintBaseNft()
        txn = await mockBaseNftContract.mintBaseNft()

        // Deploy Enabler NFT Contract

        const enablerNftContractFactory = await ethers.getContractFactory("EnablerNft")
        enablerNftContract = await enablerNftContractFactory.deploy()
        await enablerNftContract.deployed()
        accounts = await ethers.getSigners()
        owner = accounts[0].address
        // set the BaseNFT Contract Address
        await enablerNftContract.setBaseNftContractAddress(mockBaseNftContract.address)
    })
    context("Total supply", async () => {
        it("Should set the total supply propperly", async () => {
            await enablerNftContract.setTotalSupplyEnablerNft(30)
            assert.equal(await enablerNftContract.getTotalSupplyEnablerNft(), 30)
        })

        it("Fails if not Owner tries to set the total supply", async () => {
            await expect(enablerNftContract.connect(accounts[1]).setTotalSupplyEnablerNft(30)).to.be
                .reverted
        })
    })

    context("Setting Base NFT contract Address", async () => {
        it("Address of the Base NFt should be the one that was set", async () => {
            assert.equal(
                await enablerNftContract.getBaseNftContractAddress(),
                mockBaseNftContract.address
            )
        })
        it("Setting a new Base NFT Address should reset the mapping of the used Base NFT Ids", async () => {
            await enablerNftContract.mintEnablerNft(0)
            await enablerNftContract.setBaseNftContractAddress(
                "0x103A1AAda81BB8877017E04274ab5256e34cB048"
            )
            assert.equal(await enablerNftContract.checkIfBaseNftIdAlreadyUsed(0), false)
        })

        it("Mapping of used Base Nfts schould only be reste when BaseNft Address really changes", async () => {
            await enablerNftContract.mintEnablerNft(0)
            await expect(
                enablerNftContract.setBaseNftContractAddress(mockBaseNftContract.address)
            ).to.be.revertedWith("The new Base NFT Contract Address is the same as the old one")
        })
    })

    context("Minting Enabler NFT success", async () => {
        it("Minting should increase the minted Amount of nfts by 1", async () => {
            await enablerNftContract.mintEnablerNft(0)
            assert.equal(await enablerNftContract.getCurrentEnablerNftAmoundMinted(), 1)
        })

        it("The minted NFT should be owned by the minter", async () => {
            await enablerNftContract.mintEnablerNft(0)
            assert.equal(await enablerNftContract.getOwnerOfEnablerNft(0), owner)
        })

        it("Minting should increase the number of owned Nfts of the minter", async () => {
            await enablerNftContract.mintEnablerNft(0)
            assert.equal(await enablerNftContract.getNumberOfEnablerNftsOwned(owner), 1)
        })
    })

    context("Minting failing", async () => {
        it("Should fail if you want to use a base NFT that does not exist", async () => {
            await expect(enablerNftContract.mintEnablerNft(2)).to.be.revertedWith(
                "Token selected for mint does not belong to you"
            )
        })

        it("Should fail if you want to use a base NFT that does not belong to you", async () => {
            await expect(
                enablerNftContract.connect(accounts[1]).mintEnablerNft(0)
            ).to.be.revertedWith("Token selected for mint does not belong to you")
        })

        it("Minting should fail if Base Nft was already used for minting", async () => {
            await enablerNftContract.mintEnablerNft(0)
            await expect(enablerNftContract.mintEnablerNft(0)).to.be.revertedWith(
                "Token was already used for minting an Enabler Nft"
            )
        })
    })

    context("Burning Nfts", async () => {
        it("Burning NFT should reduce the supply of the Nft", async () => {
            await enablerNftContract.mintEnablerNft(0)
            await enablerNftContract.mintEnablerNft(1)
            await enablerNftContract.burnNft(0)
            assert.equal(await enablerNftContract.getAvaialableSupplyEnablerNfts(), 1)
        })
        it("Burning NFT should change the owner to 0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b", async () => {
            await enablerNftContract.mintEnablerNft(0)
            await enablerNftContract.burnNft(0)
            assert.equal(
                await enablerNftContract.getOwnerOfEnablerNft(0),
                "0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b"
            )
        })
    })

    context("Interacting with the BaseNFt contract", async () => {
        it("Owner should have 2 Base Nfts", async () => {
            assert.equal(await enablerNftContract.getNumberBaseNftsOwned(owner), 2)
        })

        it("If Base Nft was already used for minting the Id should be in the list", async () => {
            await enablerNftContract.mintEnablerNft(0)
            assert.equal(await enablerNftContract.checkIfBaseNftIdAlreadyUsed(0), true)
        })
    })
})
