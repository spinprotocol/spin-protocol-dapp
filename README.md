# spin-protocol-dapp
Decentralized Application for SPIN Protocol ecosystem

### Preinstallation
1. Install truffle globally

```bash
  $ npm install truffle@5.0.26 -g
```

2. Then install project dependencies

```bash
  $ npm install
```


## Deployment guide
! Check the migrate history '/deployed/migrate/'

### Initial Deploying whole system with Proxy
```bash
# Stage development
npm run dev-init
```

### Interlink to Proxy after all function update
```bash
# Stage development
npm run dev-update-All
```

### Interlink to Proxy after specific function update
```bash
# Stage development
# Contract name example : Campaign, RevenueLedger, Purchase, Event
npm run dev-update-<Contract name>
```


