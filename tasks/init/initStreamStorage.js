const { networks } = require("../../networks");
task("init-stream-storage", "Initializes Stream Storage")
  .addParam("contract", "Address of StreamStorage")
  .addParam("eventfactory", "Address of EventFactory")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }

    try {
      const functionHash = ethers.utils.id("initialize(address)");
      console.log(functionHash.slice(0, 10));
      const data =
        functionHash.slice(0, 10) +
        ethers.utils.defaultAbiCoder
          .encode(["address"], [taskArgs.eventfactory])
          .slice(2);

      const initializeTx = await ethers.provider.sendTransaction({
        to: taskArgs.contract,
        data: data,
      });

      console.log(initializeTx);

      const initializeTxHash = await initializeTx.wait(3);
      console.log("Transaction Hash: " + initializeTxHash);
    } catch (error) {
      console.log(error);
    }
  });
