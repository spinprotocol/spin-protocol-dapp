const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();
const { getCurrentTimestamp } = require('./utils/evm');

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const CampaignDB = artifacts.require('CampaignDB');
const CONTRACT_NAME_CAMPAIGN_DB = 'CampaignDB';

// Error messages from CampaignDB contract
const ERROR_ONLY_CONTRACT = 'Only specific contract';
const ERROR_CAMPAIGN_ALREADY_EXIST = 'Campaign already exists';
const ERROR_CAMPAIGN_DOES_NOT_EXIST = 'Campaign does not exist';
const ERROR_SUPPLY_DEPLETED = "Campaign supply depleted";

  
contract('CampaignDB', ([creator, addr1, addr2, unauthorizedAddr, randomAddr]) => {

  beforeEach(async () => {
    this.proxy = await Proxy.new();

    this.universalDB = await UniversalDB.new();
    this.universalDB.setProxy(this.proxy.address).should.be.fulfilled;

    this.campaignDB = await CampaignDB.new(this.universalDB.address);
    this.campaignDB.setProxy(this.proxy.address).should.be.fulfilled;

    await this.proxy.addContract(CONTRACT_NAME_CAMPAIGN_DB, this.campaignDB.address).should.be.fulfilled;
    // Add creator address as if it is SpinProtocol contracts who is a client for CampaginDB contract
    // In this way, we can call CampaignDB functions directly.
    await this.proxy.addContract('SpinProtocol', creator).should.be.fulfilled;
  });

  describe('CampaignDB::Authority', () => {
    it('does not allow an unauthorized address to set proxy', async () => {
      await this.campaignDB.setProxy(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to set db pointer', async () => {
      await this.campaignDB.setUniversalDB(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to create a new campaign item', async () => {
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.create(1, 1, 1, 1, finishAt, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });

    it('does not allow an unauthorized address to update a campaign item', async () => {
      let campaignId = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;
      let newFinishAt = (await getCurrentTimestamp()) + 200;
      let newSupply = 20;

      await this.campaignDB.create(campaignId, 1, 1, 1, finishAt).should.be.fulfilled;
      await this.campaignDB.update(campaignId, newSupply, newFinishAt, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });

    it('does not allow an unauthorized address to add a deal for a campaign item', async () => {
      let campaignId = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;
      let totalSupply = 10;
      let dealId = 5;
      await this.campaignDB.create(campaignId, 1, 1, totalSupply, finishAt).should.be.fulfilled;
      await this.campaignDB.addDeal(campaignId, dealId, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });

    it('does not allow an unauthorized address to decrement current supply of the campaign item', async () => {
      let campaignId = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;
      let totalSupply = 10;
      await this.campaignDB.create(campaignId, 1, 1, totalSupply, finishAt).should.be.fulfilled;
      await this.campaignDB.decrementSupply(campaignId, 1, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });
  });

  describe('CampaignDB::Features', () => {
    it('sets proxy', async () => {
      await this.campaignDB.setProxy(randomAddr).should.be.fulfilled;
      let proxy = await this.campaignDB.proxy();
      proxy.should.be.equal(randomAddr);
    });

    it('sets db pointer', async () => {
      await this.campaignDB.setUniversalDB(randomAddr).should.be.fulfilled;
      let universalDB = await this.campaignDB.universalDB();
      universalDB.should.be.equal(randomAddr);
    });

    it('creates a new campaign item', async () => {
      let campaignId = 124;
      let supplierId = 45662;
      let productId = 2345462;
      let totalSupply = 20;
      let finishAt = (await getCurrentTimestamp()) + 100;

      await this.campaignDB.create(
        campaignId,
        supplierId,
        productId,
        totalSupply,
        finishAt
      ).should.be.fulfilled;

      let res = await this.campaignDB.get(campaignId);
      res['supplierId'].toNumber().should.be.equal(supplierId);
      res['productId'].toNumber().should.be.equal(productId);
      res['finishAt'].toNumber().should.be.equal(finishAt);
      res['totalSupply'].toNumber().should.be.equal(totalSupply);
    });

    it('updates a campaign item', async () => {
      let campaignId = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;
      let newFinishAt = (await getCurrentTimestamp()) + 200;
      let newSupply = 20;

      await this.campaignDB.create(campaignId, 1, 1, 1, finishAt).should.be.fulfilled;
      await this.campaignDB.update(campaignId, newSupply, newFinishAt).should.be.fulfilled;

      let res = await this.campaignDB.get(campaignId);
      res['finishAt'].toNumber().should.be.equal(newFinishAt);
      res['totalSupply'].toNumber().should.be.equal(newSupply);
    });

    it('adds a deal for the campaign item', async () => {
      let campaignId = 1;
      let dealId = 3;
      let supply = 10;
      let finishAt = (await getCurrentTimestamp()) + 100;

      await this.campaignDB.create(campaignId, 1, 1, supply, finishAt).should.be.fulfilled;
      await this.campaignDB.addDeal(campaignId, dealId).should.be.fulfilled;

      let deals = await this.campaignDB.getDeals(campaignId);
      deals = deals.map(deal => deal.toNumber());
      deals.should.include(dealId);
    });

    it('decrements current supply of the campaign item', async () => {
      let campaignId = 1;
      let supply = 10;
      let amount = 2;
      let finishAt = (await getCurrentTimestamp()) + 100;

      await this.campaignDB.create(campaignId, 1, 1, supply, finishAt).should.be.fulfilled;
      await this.campaignDB.decrementSupply(campaignId, amount).should.be.fulfilled;

      let currentSupply = await this.campaignDB.getCurrentSupply(campaignId);
      currentSupply.toNumber().should.be.equal(supply - amount);
    });
  });

  describe('CampaignDB::Features::Negatives', () => {
    it('does not allow to create a campaign item with invalid parameters', async () => {
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.create(0, 1, 2, 3, finishAt).should.be.rejected;
      await this.campaignDB.create(1, 0, 2, 3, finishAt).should.be.rejected;
      await this.campaignDB.create(2, 1, 0, 3, finishAt).should.be.rejected;
      await this.campaignDB.create(3, 1, 2, 0, finishAt).should.be.rejected;
      await this.campaignDB.create(4, 1, 2, 3, finishAt - 100).should.be.rejected;
    });

    it('does not allow to create a duplicate item(with the same id)', async () => {
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.create(1, 2, 3, 4, finishAt).should.be.fulfilled;
      await this.campaignDB.create(1, 123, 452, 134, finishAt).should.be.rejectedWith(ERROR_CAMPAIGN_ALREADY_EXIST);
    });

    it('does not allow to update a non-existent campaign item', async () => {
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.update(123, 1334, finishAt).should.be.rejectedWith(ERROR_CAMPAIGN_DOES_NOT_EXIST);
    });

    it('does not allow to add a deal for a non-existent campaign item', async () => {
      await this.campaignDB.addDeal(3, 123).should.be.rejectedWith(ERROR_CAMPAIGN_DOES_NOT_EXIST);
    });

    it('does not allow to decrement current supply of a non-existent campaign item', async () => {
      await this.campaignDB.decrementSupply(1, 5).should.be.rejectedWith(ERROR_CAMPAIGN_DOES_NOT_EXIST);
    });

    it('does not allow to decrement current supply if the total supply is depleted', async () => {
      let campaignId = 1;
      let supply = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;

      await this.campaignDB.create(campaignId, 1, 1, supply, finishAt).should.be.fulfilled;
      await this.campaignDB.decrementSupply(campaignId, 1).should.be.fulfilled;
      // The supply is depleted now, therefore this transaction should be rejected
      await this.campaignDB.decrementSupply(campaignId, 1).should.be.rejectedWith(ERROR_SUPPLY_DEPLETED);
    });
  });
});
