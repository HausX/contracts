const { networks } = require("../../networks");
task("init-live-tipping", "Initializes LiveTipping").setAction(
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
      const LiveTipping = await ethers.getContractFactory(
        "LiveTipping",
        wallet
      );
      const liveTipping = await LiveTipping.attach(
        "0x8d4d773dF48cd3f827B5F1d3269bd5B057012631"
      );

      const transaction = await liveTipping.initialize(
        "0xeD7B819cde5C9aE1BC529268e9aebb370bc5B84a",
        "0xfb0a6b925d503d0a2c3dc9890d77adf1767ee3f6"
      );
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  }
);
