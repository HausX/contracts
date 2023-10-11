const { networks } = require("../networks");
task("create-event", "Creates Event in the Event Factory")
  .addParam("contract", "Address of EventFactory")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }

    try {
      const wallet = new ethers.Wallet(
        network.config.accounts[0],
        ethers.provider
      );
      const EventFactory = await ethers.getContractFactory(
        "EventFactory",
        wallet
      );
      const eventFactory = await EventFactory.attach(taskArgs.contract);

      const transaction = await eventFactory.createEvent(
        "16967014864",
        "90000000000000",
        "100",
        "90000000000000",
        "1",
        "Hola Amigos! I am composing my own music!"
      );
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  });
