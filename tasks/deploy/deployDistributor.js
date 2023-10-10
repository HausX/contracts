const { networks } = require("../../networks");

task("deploy-distributor", "Deploys Distributor contract").setAction(
  async (taskArgs, hre) => {
    console.log(`Deploying Distributor contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const distributor = await ethers.getContractFactory("Distributor");
    const distributorContract = await distributor.deploy();
    console.log(
      `\nWaiting 3 blocks for transaction ${distributorContract.deployTransaction.hash} to be confirmed...`
    );

    await distributorContract.deployTransaction.wait(
      networks[network.name].WAIT_BLOCK_CONFIRMATIONS
    );
    console.log("\nVerifying contract...");
    try {
      await run("verify:verify", {
        address: distributorContract.address,
        constructorArguments: [],
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
      `Distributor deployed to ${distributorContract.address} on ${network.name}`
    );
  }
);
