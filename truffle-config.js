const path = require("path");

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "1337"
    },
    develop: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "5777",       // Any network (default: none)
    },

    // // Another network with more advanced options...
    advanced: {
      host: "127.0.0.1", 
      port: 8545,             // Custom port
      network_id: "*",       // Custom network
      // gas: 8500000,           // Gas sent with each transaction (default: ~6700000)
      // gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
      // from: <address>,     // Account to send txs from (default: accounts[0])
      websocket: true        // Enable EventEmitter interface for web3 (default: false)
    },
  },
  compilers: {
    solc: {
      version: "^0.8.0"
    }
  }
};
