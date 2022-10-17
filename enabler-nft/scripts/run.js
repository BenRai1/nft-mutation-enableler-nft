const main = async () => {
    //deploy MOCK contracts
    const nftContractFactory1 = await ethers.getContractFactory("MockBaseNft")
    const mockBaseNftContract = await nftContractFactory1.deploy()
    await mockBaseNftContract.deployed()
    console.log("mockBaseNftContract deployed to:", mockBaseNftContract.address)

    let txn, totalAvailableSupply

    txn = await mockBaseNftContract.mintBaseNft()
    console.log("NFT 1 Minted ")

    txn = await mockBaseNftContract.mintBaseNft()
    console.log("NFT 2 Minted")

    //------------deploy Enabler contract----------

    const nftContractFactory = await ethers.getContractFactory("EnablerNft")
    const enablerNftContract = await nftContractFactory.deploy()
    await enablerNftContract.deployed()
    console.log("enablerNftContract deployed to:", enablerNftContract.address)

    // set the BaseNFT Contract Address

    await enablerNftContract.setBaseNftAddress(mockBaseNftContract.address)

    // console.log("BaseNftContract", txn)
    const baseNftAddress = await enablerNftContract.getBaseNftAddress()
    console.log("getBaseNftAddress", baseNftAddress)

    // mint 3 Enabler NFTs

    txn = await enablerNftContract.mintEnablerNft(0)
    await txn.wait()
    totalAvailableSupply = await enablerNftContract.getAvaialableSupplyEnablerNfts()
    console.log("totalAvailableSupply", totalAvailableSupply)

    // txn = await enablerNftContract.mintEnablerNft(3)
    // await txn.wait()
    // console.log("Should not be mintable because does not own ")
    // totalAvailableSupply = await enablerNftContract.getAvaialableSupplyEnablerNfts()
    // console.log("totalAvailableSupply", totalAvailableSupply)

    //     //Testing burn

    //     txn = await enablerNftContract.burnNft(0)
    //     await txn.wait()
    //     console.log("NFT 2 was minted")
    //     totalAvailableSupply = await enablerNftContract.getAvaialableSupplyEnablerNfts()
    //     console.log("totalAvailableSupply", totalAvailableSupply)
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
