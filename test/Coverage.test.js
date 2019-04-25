const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const ActorDB = artifacts.require('ActorDB');
const CampaignDB = artifacts.require('CampaignDB');
const DealDB = artifacts.require('DealDB');
const ProductDB = artifacts.require('ProductDB');
const PurchaseDB = artifacts.require('PurchaseDB');
const SpinProtocol = artifacts.require('SpinProtocol');
const Escrow = artifacts.require('EscrowAndFees');
const SpinToken = artifacts.require('MockSpinToken');

  
contract('Coverage', ([creator, addr1, addr2, unauthorizedAddr, randomAddr]) => {

  beforeEach(async () => {
    this.proxy = await Proxy.new();
    this.universalDB = await UniversalDB.new();
    this.actorDB = await ActorDB.new(this.universalDB.address);
    this.campaignDB = await CampaignDB.new(this.universalDB.address);
    this.dealDB = await DealDB.new(this.universalDB.address);
    this.productDB = await ProductDB.new(this.universalDB.address);
    this.purchaseDB = await PurchaseDB.new(this.universalDB.address);
    this.spinToken = await SpinToken.new();
    this.escrow = await Escrow.new();
    this.spinProtocol = await SpinProtocol.new();

    await this.escrow.setProxy(this.proxy.address).should.be.fulfilled;
    await this.spinProtocol.setProxy(this.proxy.address).should.be.fulfilled;
    await this.spinProtocol.setEscrow(this.escrow.address).should.be.fulfilled;
    await this.spinProtocol.setDataStore(
      this.actorDB.address,
      this.campaignDB.address,
      this.dealDB.address,
      this.productDB.address,
      this.purchaseDB.address
    ).should.be.fulfilled;

    await this.proxy.addContract('SpinProtocol', this.spinProtocol.address).should.be.fulfilled;
    await this.proxy.addContract('EscrowAndFees', this.escrow.address).should.be.fulfilled;
    await this.proxy.addContract('ActorDB', this.actorDB.address).should.be.fulfilled;
    await this.proxy.addContract('CampaignDB', this.campaignDB.address).should.be.fulfilled;
    await this.proxy.addContract('DealDB', this.dealDB.address).should.be.fulfilled;
    await this.proxy.addContract('ProductDB', this.productDB.address).should.be.fulfilled;
    await this.proxy.addContract('PurchaseDB', this.purchaseDB.address).should.be.fulfilled;
  });

  describe('SpinProtocol::Authority', () => {
    it('sets system token', async () => {
      await this.proxy.setToken(this.spinToken.address).should.be.fulfilled;
    });
  });
});
