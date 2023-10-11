const { networks } = require("../../networks");
task("init-live-tipping", "Initializes LiveTipping")
  .addParam("contract", "Address of LiveTipping")
  .addParam("eventfactory", "Address of EventFactory")
  .addParam("distributor", "Address of Distributor")
  .addParam("ticketfactory", "Address of TicketFactory")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const { contract, eventfactory, distributor, ticketfactory } = taskArgs;
    try {
      const wallet = new ethers.Wallet(
        network.config.accounts[0],
        ethers.provider
      );
      const LiveTipping = await ethers.getContractFactory(
        "LiveTipping",
        wallet
      );
      const liveTipping = await LiveTipping.attach(contract);

      const transaction = await liveTipping.initialize(
        eventfactory,
        distributor,
        ticketfactory
      );
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  });
