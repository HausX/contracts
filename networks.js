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
    AXELAR_GATEWAY: "0x999117D44220F33e0441fbAb2A5aDB8FF485c54D",
    AXELAR_GAS_SERVICE: "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
  },
  calibrationTestnet: {
    chainId: 314159,
    gasPrice: undefined,
    url: "https://api.calibration.node.glif.io/rpc/v1",
    WAIT_BLOCK_CONFIRMATIONS: 5,
    nativeCurrencySymbol: "FIL",
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    AXELAR_GATEWAY: "0x999117D44220F33e0441fbAb2A5aDB8FF485c54D",
    AXELAR_GAS_SERVICE: "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
  },
};

module.exports = {
  networks,
};
