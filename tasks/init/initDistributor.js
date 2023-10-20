const { networks } = require("../../networks");
task("init-distributor", "Initializes Distributor")
  .addParam("contract", "Address of Distributor")
  .addParam("dao", "Address of DAO (owner)")
  .addParam("livetipping", "Address of LiveTipping")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const { contract, dao, livetipping } = taskArgs;
    try {
      const wallet = new ethers.Wallet(
        network.config.accounts[0],
        ethers.provider
      );
      const Distributor = await ethers.getContractFactory(
        "Distributor",
        wallet
      );
      const distributor = await Distributor.attach(contract);

      const transaction = await distributor.initialize(dao, livetipping);
      transactionReceipt = await transaction.wait();

      console.log("Transaction: " + JSON.stringify(transactionReceipt));
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  });
