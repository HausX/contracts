const { networks } = require("../../networks");
task("init-ticket-factory", "Initializes Ticket Factory").setAction(
  async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }

    try {
      // const functionHash = ethers.utils.id("initialize(address)");
      // console.log(functionHash.slice(0, 10));
      // const data =
      //   functionHash.slice(0, 10) +
      //   ethers.utils.defaultAbiCoder
      //     .encode(["string"], ["0xeD7B819cde5C9aE1BC529268e9aebb370bc5B84a"])
      //     .slice(2);
      // console.log(data);
      // console.log("Sending Transaction");
      // const initializeTx = await ethers.provider.sendTransaction({
      //   from: "0x71B43a66324C7b80468F1eE676E7FCDaF63eB6Ac",
      //   to: "0xbe2914199fa40bc4a66e8a69d77ad778a84fab2f",
      //   data: data,
      // });
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

      console.log("Transaction: " + transactionReceipt);
    } catch (error) {
      console.log("ERror");
      console.log(error);
    }
  }
);
