# spin-protocol-dapp
Decentralized Application for SPIN Protocol ecosystem


### Installing dependencies
* NodeJS >= 8

```bash
# Install browserify
npm install -g browserify

# Install node modules
npm install

# Clone the modified version of `ethers.js` project to your local 
git clone https://github.com/spinprotocol/ethers.js.git

# Install `ethers.js` project as a local npm module
npm link <path_to_ethers_js_project>

```

### Deploying whole system at once
```bash
# Deploy whole contracts
truffle migrate --network <network_name>

```

### Initialize system after successful deployment
```bash
# Initialize the system
NETWORK=<network_name> npm run sys-init

```
