const { ethers } = require("hardhat")

const main = async () => {
    //deploy MOCK contracts
    const nftContractFactory1 = await ethers.getContractFactory("MockPirateApes")
    const mockPirateApesContract = await nftContractFactory1.deploy()
    await mockPirateApesContract.deployed()
    console.log("MockPirateApesContract deployed to:", mockPirateApesContract.address)

    let txn, totalRumTokensMinted

    txn = await mockPirateApesContract.safeMintPirateApe()
    console.log("NFT 1 Minted ")

    txn = await mockPirateApesContract.safeMintPirateApe()
    console.log("NFT 2 Minted")

    //------------deploy Rum Token contract----------

    const RumTokenFactory = await ethers.getContractFactory("RumToken")
    const rumTokenContract = await RumTokenFactory.deploy()
    await rumTokenContract.deployed()
    console.log("Rum Token Contract was deployed to: ", rumTokenContract.address)

    // set the Pirate Apes Contract Address

    await rumTokenContract.setPirateApesContractAddress(mockPirateApesContract.address)

    const pirateApesAddress = await rumTokenContract.getPirateApesContractAddress()
    console.log("pirateApesAddress set to", pirateApesAddress)

    // mint 3 Enabler NFTs

    txn = await rumTokenContract.mintRumToken(1, 0)
    totalRumTokensMinted = await rumTokenContract.getNumberRumTokensMinted()
    console.log("totalRumTokensMinted", totalRumTokensMinted)

    txn = await rumTokenContract.mintRumToken(1, 1)
    totalRumTokensMinted = await rumTokenContract.getNumberRumTokensMinted()
    console.log("totalRumTokensMinted", totalRumTokensMinted)

    //Testing burn
    totalAvailableSupply = await rumTokenContract.getAvaialableSupplyRumTokens()
    console.log("Available Rum Tokens before burn ", totalAvailableSupply)

    txn = await rumTokenContract.burnNft(1)
    console.log("1 Rum Token was burned")
    totalAvailableSupply = await rumTokenContract.getAvaialableSupplyRumTokens()
    console.log("Available Rum Tokens after burn ", totalAvailableSupply)
}

const runMain = async () => {
    try {
        await main()
        process.exit(0)
    } catch (error) {
        console.log(error)
        process.exit(1)
    }
}

runMain()
