const { networks } = require("../../networks");

task("deploy-event-factory", "Deploys EventFactory contract").setAction(
  async (taskArgs, hre) => {
    console.log(`Deploying EventFactory contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const eventFactory = await ethers.getContractFactory("EventFactory");
    const eventFactoryContract = await eventFactory.deploy(
      "0x8d4d773dF48cd3f827B5F1d3269bd5B057012631",
      "0xb65B773d773c7a7f2F378C71787Db7d7c32f687c",
      "0xbe2914199fa40bc4a66e8a69d77ad778a84fab2f",
      networks[network.name].AXELAR_GATEWAY,
      networks[network.name].AXELAR_GAS_SERVICE
    );
    console.log(
      `\nWaiting 3 blocks for transaction ${eventFactoryContract.deployTransaction.hash} to be confirmed...`
    );

    await eventFactoryContract.deployTransaction.wait(
      networks[network.name].WAIT_BLOCK_CONFIRMATIONS
    );
    console.log("\nVerifying contract...");
    try {
      await run("verify:verify", {
        address: eventFactoryContract.address,
        constructorArguments: [
          "0x8d4d773dF48cd3f827B5F1d3269bd5B057012631",
          "0xb65B773d773c7a7f2F378C71787Db7d7c32f687c",
          "0xbe2914199fa40bc4a66e8a69d77ad778a84fab2f",
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
    console.log(
      `EventFactory deployed to ${eventFactoryContract.address} on ${network.name}`
    );
  }
);
