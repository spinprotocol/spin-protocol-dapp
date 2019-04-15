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

    it('does not allow an unauthorized address to create a new campaign item in db', async () => {
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.create(1, 1, 1, 1, finishAt, 1, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });

    it('does not allow an unauthorized address to update a campaign item in db', async () => {
      let campaignId = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;
      let newFinishAt = (await getCurrentTimestamp()) + 200;
      let newRatio = 20;

      await this.campaignDB.create(campaignId, 1, 1, 1, finishAt, 1).should.be.fulfilled;
      await this.campaignDB.update(campaignId, newFinishAt, newRatio, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });

    it('does not allow an unauthorized address to increment sale count of a campaign item in db', async () => {
      let campaignId = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.create(campaignId, 1, 1, 1, finishAt, 1).should.be.fulfilled;
      await this.campaignDB.incrementSaleCount(campaignId, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
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

    it('creates a new campaign item in db', async () => {
      let campaignId = 124;
      let supplierId = 45662;
      let influencerId = 346452;
      let productId = 2345462;
      let finishAt = (await getCurrentTimestamp()) + 100;
      let ratio = 20;

      await this.campaignDB.create(
        campaignId,
        supplierId,
        influencerId,
        productId,
        finishAt,
        ratio
      ).should.be.fulfilled;

      let res = await this.campaignDB.get(campaignId);
      res['supplierId'].toNumber().should.be.equal(supplierId);
      res['influencerId'].toNumber().should.be.equal(influencerId);
      res['productId'].toNumber().should.be.equal(productId);
      res['finishAt'].toNumber().should.be.equal(finishAt);
      res['ratio'].toNumber().should.be.equal(ratio);
    });

    it('updates a campaign item in db', async () => {
      let campaignId = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;
      let newFinishAt = (await getCurrentTimestamp()) + 200;
      let newRatio = 20;

      await this.campaignDB.create(campaignId, 1, 1, 1, finishAt, 1).should.be.fulfilled;
      await this.campaignDB.update(campaignId, newFinishAt, newRatio).should.be.fulfilled;

      let res = await this.campaignDB.get(campaignId);
      res['finishAt'].toNumber().should.be.equal(newFinishAt);
      res['ratio'].toNumber().should.be.equal(newRatio);
    });

    it('increments sale count of a campaign item in db', async () => {
      let campaignId = 1;
      let finishAt = (await getCurrentTimestamp()) + 100;

      await this.campaignDB.create(campaignId, 1, 1, 1, finishAt, 1).should.be.fulfilled;
      await this.campaignDB.incrementSaleCount(campaignId).should.be.fulfilled;
      await this.campaignDB.incrementSaleCount(campaignId).should.be.fulfilled;

      let res = await this.campaignDB.get(campaignId);
      res['saleCount'].toNumber().should.be.equal(2);
    });
  });

  describe('CampaignDB::Features::Negatives', () => {
    it('does not allow to create a campaign item with invalid parameters', async () => {
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.create(0, 1, 2, 3, finishAt, 5).should.be.rejected;
      await this.campaignDB.create(1, 0, 2, 3, finishAt, 5).should.be.rejected;
      await this.campaignDB.create(2, 1, 0, 3, finishAt, 5).should.be.rejected;
      await this.campaignDB.create(3, 1, 2, 0, finishAt, 5).should.be.rejected;
      await this.campaignDB.create(4, 1, 2, 3, finishAt - 100, 5).should.be.rejected;
    });

    it('does not allow to create a duplicate item in db', async () => {
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.create(1, 1, 2, 3, finishAt, 5).should.be.fulfilled;
      await this.campaignDB.create(1, 1, 2, 3, finishAt, 5).should.be.rejectedWith(ERROR_CAMPAIGN_ALREADY_EXIST);
    });

    it('does not allow to update a non-existent campaign item in db', async () => {
      let finishAt = (await getCurrentTimestamp()) + 100;
      await this.campaignDB.update(123, finishAt, 1).should.be.rejectedWith(ERROR_CAMPAIGN_DOES_NOT_EXIST);
    });

    it('does not allow to increment sale count of a non-existent campaign item in db', async () => {
      await this.campaignDB.incrementSaleCount(1).should.be.rejectedWith(ERROR_CAMPAIGN_DOES_NOT_EXIST);
    });
  });
});
