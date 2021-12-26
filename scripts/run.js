const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT'); //hre is Hardhat runtime environment. It is an object containing all Hardhat functionality and is built on fly when running npx hardhat, hence why we don't see hre imported from anywhere.
    const nftContract = await nftContractFactory.deploy(); // Everytime contract is run,  Hardhat creates local ETH network with fresh blockchain for just this conract, and after the script completes will destroy it. 
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);

    //Call the function
    let txn = await nftContract.makeAnEpicNFT()
    // Wait for it to be mined.
    await txn.wait()

    //Mint another NFT for fun
    txn = await nftContract.makeAnEpicNFT()
    //wait for it to be mined.
    await txn.wait()
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();