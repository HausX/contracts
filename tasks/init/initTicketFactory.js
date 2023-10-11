const { networks } = require("../../networks");
task("init-ticket-factory", "Initializes Ticket Factory")
  .addParam("contract", "Address of TicketFactory")
  .addParam("eventfactory", "Address of EventFactory")
  .addParam("livetipping", "Address of LiveTipping")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const { contract, eventfactory, livetipping } = taskArgs;
    try {
      const wallet = new ethers.Wallet(
        network.config.accounts[0],
        ethers.provider
      );
      const TicketFactory = await ethers.getContractFactory(
        "TicketFactory",
        wallet
      );
      const ticketFactory = await TicketFactory.attach(contract);

      const transaction = await ticketFactory.initialize(
        eventfactory,
        livetipping
      );
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  });
