require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;

const networks = {
  sepolia: {
    url: "https://rpc.sepolia.org/",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.ETHERSCAN_API_KEY || "UNSET",
    chainId: 11155111,
    nativeCurrencySymbol: "ETH",
    WAIT_BLOCK_CONFIRMATIONS: 3,
  },
  polygonzkEVMTestnet: {
    url: "https://rpc.public.zkevm-test.net/",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.ZKEVM_VERIFY_API_KEY || "UNSET",
    chainId: 1442,
    nativeCurrencySymbol: "ETH",
    WAIT_BLOCK_CONFIRMATIONS: 3,
  },
  calibrationTestnet: {
    chainId: 314159,
    gasPrice: undefined,
    url: "https://api.calibration.node.glif.io/rpc/v1",
    WAIT_BLOCK_CONFIRMATIONS: 5,
    nativeCurrencySymbol: "FIL",
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
  },
};

module.exports = {
  networks,
};
