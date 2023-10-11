const { networks } = require("../networks");
task("tip-event", "Tips an event in the LiveTipping")
  .addParam("contract", "Address of LiveTipping")
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
      const LiveTipping = await ethers.getContractFactory(
        "LiveTipping",
        wallet
      );
      const liveTipping = await LiveTipping.attach(taskArgs.contract);

      const transaction = await liveTipping.tipEvent(0, {
        value: ethers.utils.parseEther("0.0001"),
      });
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  });
