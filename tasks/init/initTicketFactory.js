const { networks } = require("../../networks");
task("init-ticket-factory", "Initializes Ticket Factory").setAction(
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
      const TicketFactory = await ethers.getContractFactory(
        "TicketFactory",
        wallet
      );
      const ticketFactory = await TicketFactory.attach(
        "0xb65B773d773c7a7f2F378C71787Db7d7c32f687c"
      );

      const transaction = await ticketFactory.initialize(
        "0xeD7B819cde5C9aE1BC529268e9aebb370bc5B84a"
      );
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  }
);
