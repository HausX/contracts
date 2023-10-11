const { networks } = require("../networks");
task("buy-ticket", "Purchases a ticket in the TicketFactory")
  .addParam("contract", "Address of TicketFactory")
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
      const TicketFactory = await ethers.getContractFactory(
        "TicketFactory",
        wallet
      );
      const ticketFactory = await TicketFactory.attach(taskArgs.contract);

      const transaction = await ticketFactory.purchaseTicket(
        0,
        "0x71B43a66324C7b80468F1eE676E7FCDaF63eB6Ac",
        {
          value: ethers.utils.parseEther("0.0001"),
        }
      );
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  });
