const { networks } = require("../../networks");

task("deploy-event-factory", "Deploys EventFactory contract")
  .addParam("livetipping", "Address of LiveTipping")
  .addParam("ticketfactory", "Address of TicketFactory")
  .addParam("streamstorage", "Address of StreamStorage")
  .setAction(async (taskArgs, hre) => {
    console.log(`Deploying EventFactory contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const { livetipping, ticketfactory, streamstorage } = taskArgs;

    const eventFactory = await ethers.getContractFactory("EventFactory");
    const eventFactoryContract = await eventFactory.deploy(
      livetipping,
      ticketfactory,
      streamstorage,
      networks[network.name].AXELAR_GATEWAY,
      networks[network.name].AXELAR_GAS_SERVICE
    );
    console.log(
      `\nWaiting 1 blocks for transaction ${eventFactoryContract.deployTransaction.hash} to be confirmed...`
    );

    await eventFactoryContract.deployTransaction.wait(1);
    console.log("\nVerifying contract...");
    try {
      await run("verify:verify", {
        address: eventFactoryContract.address,
        constructorArguments: [
          livetipping,
          ticketfactory,
          streamstorage,
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
  });
