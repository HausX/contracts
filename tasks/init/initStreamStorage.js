const { networks } = require("../../networks");
task("init-stream-storage", "Initializes Stream Storage")
  .addParam("contract", "Address of LiveTipping")
  .addParam("destination", "Address of Destination Address")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const { contract, destination } = taskArgs;

    try {
      const wallet = new ethers.Wallet(
        network.config.accounts[0],
        ethers.provider
      );
      const StreamStorage = await ethers.getContractFactory(
        "StreamStorage",
        wallet
      );
      const streamStorage = await StreamStorage.attach(contract);

      const transaction = await streamStorage.initialize(destination);
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  });
