const { networks } = require("../../networks");

task("deploy-stream-storage", "Deploys StreamStorage contract").setAction(
  async (taskArgs, hre) => {
    console.log(`Deploying StreamStorage contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const streamStorage = await ethers.getContractFactory("StreamStorage");
    console.log("what");
    const streamStorageContract = await streamStorage.deploy(
      networks[network.name].AXELAR_GATEWAY,
      networks[network.name].AXELAR_GAS_SERVICE
    );
    console.log(
      `\nWaiting 3 blocks for transaction ${streamStorageContract.deployTransaction.hash} to be confirmed...`
    );

    await streamStorageContract.deployTransaction.wait(1);

    console.log(
      `StreamStorage deployed to ${streamStorageContract.address} on ${network.name}`
    );
    console.log(
      "\nUse CLI Command to verify contract:\n npx hardhat starboard-verify StreamStorage " +
        streamStorageContract.address
    );
    try {
      await run("verify:verify", {
        address: streamStorageContract.address,
        constructorArguments: [
          networks[network.name].AXELAR_GATEWAY,
          networks[network.name].AXELAR_GAS_SERVICE,
        ],
      });
      console.log("Contract verified");
    } catch (error) {
      if (!error.message.includes("Already Verified")) {
        console.log(
          "Error verifying contract.  Delete the build folder and try again."
        );
        console.log(error);
      } else {
        console.log("Contract already verified");
      }
    }
  }
);
