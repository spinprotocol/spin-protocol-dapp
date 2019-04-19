const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const PurchaseDB = artifacts.require('PurchaseDB');
const CONTRACT_NAME_PURCHASE_DB = 'PurchaseDB';

// Error messages from PurchaseDB contract
const ERROR_ONLY_CONTRACT = 'Only specific contract';
const ERROR_ALREADY_EXIST = 'Purchase already exists';
const ERROR_DOES_NOT_EXIST = 'Purchase does not exist';


contract('purchaseDB', ([creator, unauthorizedAddr, randomAddr]) => {

  beforeEach(async () => {
    this.proxy = await Proxy.new();

    this.universalDB = await UniversalDB.new();
    this.universalDB.setProxy(this.proxy.address).should.be.fulfilled;

    this.purchaseDB = await PurchaseDB.new(this.universalDB.address);
    this.purchaseDB.setProxy(this.proxy.address).should.be.fulfilled;

    await this.proxy.addContract(CONTRACT_NAME_PURCHASE_DB, this.purchaseDB.address).should.be.fulfilled;
    // Add creator address as if it is SpinProtocol contracts who is a client for PurchaseDB contract
    // In this way, we can call PurchaseDB functions directly.
    await this.proxy.addContract('SpinProtocol', creator).should.be.fulfilled;
  });

  describe('PurchaseDB::Authority', () => {
    it('does not allow an unauthorized address to set proxy', async () => {
      await this.purchaseDB.setProxy(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to set db pointer', async () => {
      await this.purchaseDB.setUniversalDB(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to create a new purchase item in db', async () => {
      await this.purchaseDB.create(1, 2, 3, 4, 5, 6, 7, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });
  });

  describe('PurchaseDB::Features', () => {
    it('sets proxy', async () => {
      await this.purchaseDB.setProxy(randomAddr).should.be.fulfilled;
      let proxy = await this.purchaseDB.proxy();
      proxy.should.be.equal(randomAddr);
    });

    it('sets db pointer', async () => {
      await this.purchaseDB.setUniversalDB(randomAddr).should.be.fulfilled;
      let universalDB = await this.purchaseDB.universalDB();
      universalDB.should.be.equal(randomAddr);
    });

    it('creates a new purchase item in db', async () => {
      let purchaseId = 124;
      let campaignId = 345;
      let customerId = 123345;
      let dealId = 67543;
      let transactionId = 23454;
      let purchaseAmount = 3581;
      let purchasedAt = 98237461;

      await this.purchaseDB.create(
        purchaseId,
        transactionId,
        customerId,
        campaignId,
        dealId,
        purchaseAmount,
        purchasedAt
      ).should.be.fulfilled;

      let res = await this.purchaseDB.get(purchaseId);
      res['campaignId'].toNumber().should.be.equal(campaignId);
      res['customerId'].toNumber().should.be.equal(customerId);
      res['dealId'].toNumber().should.be.equal(dealId);
      res['transactionId'].toNumber().should.be.equal(transactionId);
      res['purchaseAmount'].toNumber().should.be.equal(purchaseAmount);
      res['purchasedAt'].toNumber().should.be.equal(purchasedAt);
    });
  });

  describe('PurchaseDB::Features::Negatives', () => {
    it('does not allow to create a purchase item with invalid parameters', async () => {
      await this.purchaseDB.create(0, 1, 2, 3, 4, 5, 6).should.be.rejected;
      await this.purchaseDB.create(1, 0, 2, 3, 4, 5, 6).should.be.rejected;
      await this.purchaseDB.create(1, 2, 0, 3, 4, 5, 6).should.be.rejected;
      await this.purchaseDB.create(1, 2, 3, 0, 4, 5, 6).should.be.rejected;
      await this.purchaseDB.create(1, 2, 3, 4, 0, 5, 6).should.be.rejected;
    });

    it('does not allow to create a duplicate item in db', async () => {
      await this.purchaseDB.create(1, 2, 3, 4, 5, 6, 7).should.be.fulfilled;
      await this.purchaseDB.create(1, 20, 30, 40, 50, 60, 70).should.be.rejectedWith(ERROR_ALREADY_EXIST);
    });
  });
});
