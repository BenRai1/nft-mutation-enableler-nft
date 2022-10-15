const main = async () => {
    //deploy MOCK contracts
    const nftContractFactory1 = await hre.ethers.getContractFactory("MockBaseNft")
    const mockBaseNftContract = await nftContractFactory1.deploy()
    await mockBaseNftContract.deployed()
    console.log("mockBaseNftContract deployed to:", mockBaseNftContract.address)

    let txn, totalAvailableSupply

    txn = await mockBaseNftContract.mintBaseNft()
    // console.log("Txn result mint NFT", txn)
    // console.log("Txn result mint txn.gasPrice", txn.gasPrice)

    console.log("NFT 1 Minted")
    const mintingAddress = txn.from

    txn = await mockBaseNftContract.mintBaseNft()
    console.log("NFT 2 Minted")

    //deploy main contract

    const nftContractFactory = await hre.ethers.getContractFactory("EnablerNFT")
    const enablerNftContract = await nftContractFactory.deploy()
    await enablerNftContract.deployed()
    console.log("enablerNftContract deployed to:", enablerNftContract.address)

    enablerNftContract.setBaseNftAddress(mockBaseNftContract.address)

    txn = await enablerNftContract.mintEnablerNft(0)
    await txn.wait()
    totalAvailableSupply = await enablerNftContract.getAvaialableSupply()
    console.log("totalAvailableSupply", totalAvailableSupply)

    txn = await enablerNftContract.mintEnablerNft(1)
    await txn.wait()
    console.log("NFT 2 was minted")
    totalAvailableSupply = await enablerNftContract.getAvaialableSupply()
    console.log("totalAvailableSupply", totalAvailableSupply)

    txn = await enablerNftContract.burnNft(0)
    await txn.wait()
    console.log("NFT 2 was minted")
    totalAvailableSupply = await enablerNftContract.getAvaialableSupply()
    console.log("totalAvailableSupply", totalAvailableSupply)
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
