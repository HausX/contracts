const { networks } = require("../../networks");
task("init-stream-storage", "Initializes Stream Storage").setAction(
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
      const StreamStorage = await ethers.getContractFactory(
        "StreamStorage",
        wallet
      );
      const streamStorage = await StreamStorage.attach(
        "0xbe2914199fa40bc4a66e8a69d77ad778a84fab2f"
      );

      const transaction = await streamStorage.initialize(
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
