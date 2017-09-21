module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            network_id: "*" // Match any network id
        },
        rinkeby: {
            host: "localhost", 
            port: 8545, 
            network_id: 4
        },
        mainnet: {
            host: "localhost", 
            port: 8545, 
            network_id: 1
        }
    }
};
