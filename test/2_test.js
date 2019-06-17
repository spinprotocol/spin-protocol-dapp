const Proxy = artifacts.require('./Proxy.sol');
const { METADATA } = require('../utils/metadata');
const { CONTRACT } = require('../utils/generic-caver');

const admin = '0x1Ea4C58b01c9934D6D9e7D736f072f6F3e3c44a5';
const campaignDB = CONTRACT.get(METADATA.ABI.CAMPAIGN_DB,METADATA.ADDRESS.CAMPAIGN_DB);
const revenueLedgerDB = CONTRACT.get(METADATA.ABI.REVENUE_LEDGER_DB,METADATA.ADDRESS.REVENUE_LEDGER_DB);

let getCampaign = async (id) => {
  return await CONTRACT.read(campaignDB,"getCampaign(uint256)",{campaignId:id});
}

let getRevenueLedger = async (id) => {
  return await CONTRACT.read(revenueLedgerDB,"getRevenueLedger(uint256)",{revenueLedgerId:id});
}

contract('CampaignDB', () => {
  let proxyInstance;

  it("Create test data", () => {
    return Proxy.deployed().then(_instance => {
        proxyInstance = _instance
        let time = + Math.floor(+ new Date() / 1000) + 86400; //현재시간+1일(86400)
        return proxyInstance.createCampaign(1,1,30,10000,time,time+3600);
    }).then(async receipt => {
        assert.equal(receipt.receipt.status,'0x1',"create revert")
        console.log(` - create Data : ` + await getCampaign(1));
    });
  });

  it("Update test data", async () => {
    let time = + Math.floor(+ new Date() / 1000) + 3600;//현재시간 + 1시간 (3600)
    let receipt = await proxyInstance.updateCampaign(1,99,30,10000, time, time+3600);
    assert.equal(receipt.receipt.status,"0x1","Update fail");

    console.log(` - update Data : ` + await getCampaign(1))
  })

  it("attend Campaign", async () => {
    await proxyInstance.attendCampaign(1,1);
    let data = await getCampaign(1);
    assert.equal(data[3].length,1,"not attend campaign");
  })

  it("cancel Campaign", async () => {
    await proxyInstance.cancelCampaign(1,1);
    let data = await getCampaign(1);
    assert.equal(data[3].length,0,"not attend campaign");
  })

  it("Delete Campaign", async () => {
    let receipt = await proxyInstance.deleteCampaign(1);
    assert.equal(receipt.receipt.status,"0x1","Delete Fail")
  })
})


contract('RevenueLedgerDB', () => {
  let proxyInstance;

  it("Create test data", () => {
    return Proxy.deployed().then(_instance => {
        proxyInstance = _instance
        return proxyInstance.createRevenueLedger(1,1,1,1,1,1,1,1,1);
    }).then(async receipt => {
        assert.equal(receipt.receipt.status,'0x1',"create revert")
        console.log(` - create Data : ` + await getRevenueLedger(1));
    });
  });

  it("Update isAccount", async () => {
    await proxyInstance.updateIsAccount(1,true);
    let data = await getRevenueLedger(1);
    assert.equal(data[8],true,"isAccount not change");
  })
})