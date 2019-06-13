const Proxy = artifacts.require('./Proxy.sol');
const SpinProtocol = artifacts.require("./SpinProtocol.sol");
const UniversalDB = artifacts.require('./UniversalDB.sol');
const CampaignDB = artifacts.require('./CampaignDB.sol');
const RevenueLedgerDB = artifacts.require('./RevenueLedgerDB.sol');

const { METADATA } = require('../utils/metadata');
const admin = '0x1Ea4C58b01c9934D6D9e7D736f072f6F3e3c44a5';

contract('Setting-Proxy', () => {
  let instance;

  it("Admin check", () => {
    return Proxy.deployed().then(_instance => {
        instance = _instance
        return instance.isAdmin.call(admin);
    }).then(adminBool => {
        assert.equal(adminBool, true, "Abnormal Admin ")
    });
  });

  it("addContract", async () => {
      await instance.addContract(METADATA.NAME.SPIN_PROTOCOL,METADATA.ADDRESS.SPIN_PROTOCOL,{from:admin});
      await instance.addContract(METADATA.NAME.UNIVERSAL_DB,METADATA.ADDRESS.UNIVERSAL_DB,{from:admin});
      await instance.addContract(METADATA.NAME.CAMPAIGN_DB,METADATA.ADDRESS.CAMPAIGN_DB,{from:admin});
      await instance.addContract(METADATA.NAME.REVENUE_LEDGER_DB,METADATA.ADDRESS.REVENUE_LEDGER_DB,{from:admin});

      assert.equal(await instance.getContract(METADATA.NAME.SPIN_PROTOCOL),METADATA.ADDRESS.SPIN_PROTOCOL," Not equal SpinProtocol");
      assert.equal(await instance.getContract(METADATA.NAME.UNIVERSAL_DB),METADATA.ADDRESS.UNIVERSAL_DB," Not equal UniversalDB");
      assert.equal(await instance.getContract(METADATA.NAME.CAMPAIGN_DB),METADATA.ADDRESS.CAMPAIGN_DB," Not equal CampaignDB");
      assert.equal(await instance.getContract(METADATA.NAME.REVENUE_LEDGER_DB),METADATA.ADDRESS.REVENUE_LEDGER_DB," Not equal revenueLedgerDB");
  })
})

contract('Setting',() => {
    let spinProtocolInstance;
    let universalInstance;
    let revenueLedgerInstance;
    let campaignInstance;
    
    //SpinProtocol
    it("Admin check", () => {
        console.log("     => SpinProtocol")
        return SpinProtocol.deployed().then(instance => {
            spinProtocolInstance = instance
            return spinProtocolInstance.isAdmin.call(admin);
        }).then(adminBool => {
            assert.equal(adminBool, true, "Abnormal Admin ")
        });
    });

    it("setProxy", async () => {
        await spinProtocolInstance.setProxy(METADATA.ADDRESS.PROXY,{from : admin});
        let proxy = await spinProtocolInstance.proxy.call();
        assert.equal(proxy,METADATA.ADDRESS.PROXY, "Abnormal Proxy Address");
    })

    it("setDataStore", async () => {
        await spinProtocolInstance.setDataStore(METADATA.ADDRESS.CAMPAIGN_DB,METADATA.ADDRESS.REVENUE_LEDGER_DB)
        let campaignDB = await spinProtocolInstance.campaignDB.call();
        let revenueLedgerDB = await spinProtocolInstance.revenueLedgerDB.call();

        assert.equal(campaignDB,METADATA.ADDRESS.CAMPAIGN_DB, "Abnormal Campaign Address");
        assert.equal(revenueLedgerDB,METADATA.ADDRESS.REVENUE_LEDGER_DB, "Abnormal RevenueLedger Address");
    })

    //UniversalDB
    it("Admin check", () => {
        console.log("     => UniversalDB")
        return UniversalDB.deployed().then(instance => {
            universalInstance = instance
            return universalInstance.isAdmin.call(admin);
        }).then(adminBool => {
            assert.equal(adminBool, true, "Abnormal Admin ")
        });
    });

    it("setProxy", async () => {
        await universalInstance.setProxy(METADATA.ADDRESS.PROXY,{from : admin});
        let proxy = await universalInstance.proxy.call();
        assert.equal(proxy,METADATA.ADDRESS.PROXY, "Abnormal Proxy Address");
    })

    //RevenueLedgerDB
    it("Admin check", () => {
        console.log("     => RevenueLedgerDB")
        return RevenueLedgerDB.deployed().then(instance => {
            revenueLedgerInstance = instance
            return revenueLedgerInstance.isAdmin.call(admin);
        }).then(adminBool => {
            assert.equal(adminBool, true, "Abnormal Admin ")
        });
    });

    it("setProxy", async () => {
        await revenueLedgerInstance.setProxy(METADATA.ADDRESS.PROXY,{from : admin});
        let proxy = await revenueLedgerInstance.proxy.call();
        assert.equal(proxy,METADATA.ADDRESS.PROXY, "Abnormal Proxy Address");
    })

    //CampaignDB
    it("Admin check", () => {
        console.log("     => CampaignDB")
        return CampaignDB.deployed().then(instance => {
            campaignInstance = instance
            return campaignInstance.isAdmin.call(admin);
        }).then(adminBool => {
            assert.equal(adminBool, true, "Abnormal Admin ")
        });
    });

    it("setProxy", async () => {
        await campaignInstance.setProxy(METADATA.ADDRESS.PROXY,{from : admin});
        let proxy = await campaignInstance.proxy.call();
        assert.equal(proxy,METADATA.ADDRESS.PROXY, "Abnormal Proxy Address");
    })
})