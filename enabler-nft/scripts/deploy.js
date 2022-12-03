const { ethers, run, network } = require("hardhat")

const main = async () => {
    const RumTokenFactory = await ethers.getContractFactory("RumToken")
    console.log("Deploying contract...")
    const rumTokenContract = await RumTokenFactory.deploy()
    console.log("Waiting for contract to finish deploying")
    await rumTokenContract.deployed()
    console.log("Rum Token Contract deployed to:", rumTokenContract.address)
    if (network.config.chainId === 5 && process.env.ETHERSCAN_API_KEY) {
        console.log("Waiting for 6 block to pass...")
        await rumTokenContract.deployTransaction.wait(6)
        console.log("verifying contract...")
        await verify(rumTokenContract.address, [])
    }
}

const verify = async (contractaddress, args) => {
    console.log("Varifying Contract...")
    try {
        await run("verify:verify", {
            address: contractaddress,
            constructorArguments: args,
        })
    } catch (error) {
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("Already varified")
        } else {
            console.log(error)
        }
    }
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
