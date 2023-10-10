const { networks } = require("../../networks");

task("deploy-ticket-factory", "Deploys TicketFactory contract").setAction(
  async (taskArgs, hre) => {
    console.log(`Deploying TicketFactory contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const ticketFactory = await ethers.getContractFactory("TicketFactory");
    const ticketContract = await ticketFactory.deploy();
    console.log(
      `\nWaiting 3 blocks for transaction ${ticketContract.deployTransaction.hash} to be confirmed...`
    );

    await ticketContract.deployTransaction.wait(
      networks[network.name].WAIT_BLOCK_CONFIRMATIONS
    );
    console.log("\nVerifying contract...");
    try {
      await run("verify:verify", {
        address: ticketContract.address,
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
      `TicketFactory deployed to ${ticketContract.address} on ${network.name}`
    );
  }
);
