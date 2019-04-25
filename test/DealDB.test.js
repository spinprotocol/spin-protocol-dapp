const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();
const { getCurrentTimestamp } = require('./utils/evm');

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const DealDB = artifacts.require('DealDB');
const CONTRACT_NAME_DEAL_DB = 'DealDB';

// Error messages from DealDB contract
const ERROR_ONLY_CONTRACT = 'Only specific contract';
const ERROR_DEAL_ALREADY_EXIST = 'Item already exists';
const ERROR_DEAL_DOES_NOT_EXIST = 'Item does not exist';

  
contract('DealDB', ([creator, addr1, addr2, unauthorizedAddr, randomAddr]) => {

  beforeEach(async () => {
    this.proxy = await Proxy.new();

    this.universalDB = await UniversalDB.new();
    this.universalDB.setProxy(this.proxy.address).should.be.fulfilled;

    this.dealDB = await DealDB.new(this.universalDB.address);
    this.dealDB.setProxy(this.proxy.address).should.be.fulfilled;

    await this.proxy.addContract(CONTRACT_NAME_DEAL_DB, this.dealDB.address).should.be.fulfilled;
    // Add creator address as if it is SpinProtocol contracts who is a client for DealDB contract
    // In this way, we can call DealDB functions directly.
    await this.proxy.addContract('SpinProtocol', creator).should.be.fulfilled;
  });

  describe('DealDB::Authority', () => {
    it('does not allow an unauthorized address to set proxy', async () => {
      await this.dealDB.setProxy(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to set db pointer', async () => {
      await this.dealDB.setUniversalDB(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to create a new deal item', async () => {
      await this.dealDB.create(1, 1, 1, 1, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });

    it('does not allow an unauthorized address to increment sale count of a deal item', async () => {
      let dealId = 1;
      await this.dealDB.create(dealId, 1, 1, 1).should.be.fulfilled;
      await this.dealDB.incrementSaleCount(dealId, 1, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });
  });

  describe('DealDB::Features', () => {
    it('sets proxy', async () => {
      await this.dealDB.setProxy(randomAddr).should.be.fulfilled;
      let proxy = await this.dealDB.proxy();
      proxy.should.be.equal(randomAddr);
    });

    it('sets db pointer', async () => {
      await this.dealDB.setUniversalDB(randomAddr).should.be.fulfilled;
      let universalDB = await this.dealDB.universalDB();
      universalDB.should.be.equal(randomAddr);
    });

    it('creates a new deal item', async () => {
      let dealId = 124;
      let campaignId = 45662;
      let influencerId = 346452;
      let ratio = 20;

      await this.dealDB.create(
        dealId,
        campaignId,
        influencerId,
        ratio
      ).should.be.fulfilled;

      let res = await this.dealDB.get(dealId);
      res['campaignId'].toNumber().should.be.equal(campaignId);
      res['influencerId'].toNumber().should.be.equal(influencerId);
      res['ratio'].toNumber().should.be.equal(ratio);
    });

    it('increments sale count of a deal item', async () => {
      let dealId = 1;
      let amount = 2;

      await this.dealDB.create(dealId, 1, 1, 1).should.be.fulfilled;
      await this.dealDB.incrementSaleCount(dealId, amount).should.be.fulfilled;

      let res = await this.dealDB.get(dealId);
      res['saleCount'].toNumber().should.be.equal(amount);
    });
  });

  describe('DealDB::Features::Negatives', () => {
    it('does not allow to create a deal item with invalid parameters', async () => {
      await this.dealDB.create(0, 1, 2, 5).should.be.rejected;
      await this.dealDB.create(1, 0, 2, 5).should.be.rejected;
      await this.dealDB.create(2, 1, 0, 5).should.be.rejected;
    });

    it('does not allow to create a duplicate(with same deal id) item', async () => {
      await this.dealDB.create(1, 1, 2, 5).should.be.fulfilled;
      await this.dealDB.create(1, 1, 2, 5).should.be.rejectedWith(ERROR_DEAL_ALREADY_EXIST);
    });

    it('does not allow to increment sale count of a non-existent deal item in db', async () => {
      await this.dealDB.incrementSaleCount(1, 5).should.be.rejectedWith(ERROR_DEAL_DOES_NOT_EXIST);
    });
  });
});
