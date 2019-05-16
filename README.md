# spin-protocol-dapp
Decentralized Application for SPIN Protocol ecosystem


### Installing dependencies
* NodeJS >= 8

```bash
# Install node modules
npm install
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
