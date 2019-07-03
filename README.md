# spin-protocol-dapp
Decentralized Application for SPIN Protocol ecosystem

### Preinstallation
1. Install truffle globally

```bash
  $ npm install truffle@4.1.15 -g
```

2. Then install project dependencies

```bash
  $ npm install
```

### Deploying whole system at once
! Check the migrate history '/deployed/migrate/'
```bash
# Deploy whole contracts
truffle migrate --network <network_name> --f <Start migrations number> --to <End migrations number>
```

### Contract initialization
```bash
NETWORK=<network_name> npm run initialize-contract
```
