const { networks } = require("../networks");
task("create-event", "Creates Event in the Event Factory").setAction(
  async (taskArgs, hre) => {
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
      const eventFactory = await EventFactory.attach(
        "0xeD7B819cde5C9aE1BC529268e9aebb370bc5B84a"
      );

      const transaction = await eventFactory.createEvent(
        "1697011735",
        "100000000000000",
        "35",
        "100000000000000"
      );
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  }
);
