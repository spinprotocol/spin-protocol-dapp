const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();
const { getCurrentTimestamp } = require('./utils/evm');

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const ActorDB = artifacts.require('ActorDB');
const CampaignDB = artifacts.require('CampaignDB');
const ProductDB = artifacts.require('ProductDB');
const PurchaseDB = artifacts.require('PurchaseDB');
const SpinProtocol = artifacts.require('SpinProtocol');
const Escrow = artifacts.require('EscrowAndFees');
const SpinToken = artifacts.require('MockSpinToken');
const SYSTEM_ROLES = {
  influencer: 'influencer',
  supplier: 'supplier',
  customer: 'customer',
  serviceProvider: 'service_provider',
  spinProtocol: 'spin_protocol'
};
const REGISTRATION_FEES = {
  campaign: new BigNumber(5),
  product: new BigNumber(10)
};
const ESCROW_INITIAL_FUNDING = new BigNumber(20000);
const USER_INITIAL_FUNDING = new BigNumber(10000);

  
contract('SpinProtocol', ([creator, addr1, addr2, addr3, feeCollector, unauthorizedAddr, randomAddr]) => {

  beforeEach(async () => {
    // Deploy system contracts
    this.proxy = await Proxy.new();
    this.universalDB = await UniversalDB.new();
    this.actorDB = await ActorDB.new(this.universalDB.address);
    this.campaignDB = await CampaignDB.new(this.universalDB.address);
    this.productDB = await ProductDB.new(this.universalDB.address);
    this.purchaseDB = await PurchaseDB.new(this.universalDB.address);
    this.spinToken = await SpinToken.new();
    this.escrow = await Escrow.new();
    this.spinProtocol = await SpinProtocol.new();

    // Initialize system contracts
    await this.universalDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.actorDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.campaignDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.productDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.purchaseDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.escrow.setProxy(this.proxy.address).should.be.fulfilled;
    await this.spinProtocol.setProxy(this.proxy.address).should.be.fulfilled;
    await this.spinProtocol.setEscrow(this.escrow.address).should.be.fulfilled;
    await this.spinProtocol.setDataStore(
      this.actorDB.address,
      this.campaignDB.address,
      this.productDB.address,
      this.purchaseDB.address
    ).should.be.fulfilled;

    // Add system contracts to proxy contract
    await this.proxy.addContract('SpinProtocol', this.spinProtocol.address).should.be.fulfilled;
    await this.proxy.addContract('EscrowAndFees', this.escrow.address).should.be.fulfilled;
    await this.proxy.addContract('ActorDB', this.actorDB.address).should.be.fulfilled;
    await this.proxy.addContract('CampaignDB', this.campaignDB.address).should.be.fulfilled;
    await this.proxy.addContract('ProductDB', this.productDB.address).should.be.fulfilled;
    await this.proxy.addContract('PurchaseDB', this.purchaseDB.address).should.be.fulfilled;

    // Send some tokens to Escrow contract as an initial funding
    await this.spinToken.transfer(this.escrow.address, ESCROW_INITIAL_FUNDING).should.be.fulfilled;
  });

  describe('SpinProtocol::Authority', () => {
    it('sets system token', async () => {
      await this.proxy.setToken(this.spinToken.address).should.be.fulfilled;
    });
  });

  describe('SpinProtocol::Features', () => {

    beforeEach(async () => {
      // Set fee collector for escrow
      await this.proxy.setFeeCollector(feeCollector).should.be.fulfilled;
      // Set token for escrow
      await this.proxy.setToken(this.spinToken.address).should.be.fulfilled;
      // Set system fees
      await this.proxy.setRegistrationFees(
        REGISTRATION_FEES.campaign,
        REGISTRATION_FEES.product
      ).should.be.fulfilled;
      // Send some tokens to system user
      await this.spinToken.transfer(addr1, USER_INITIAL_FUNDING).should.be.fulfilled;
      await this.spinToken.transfer(addr2, USER_INITIAL_FUNDING).should.be.fulfilled;
      await this.spinToken.transfer(addr3, USER_INITIAL_FUNDING).should.be.fulfilled;
      // And, as a user, approve transfer action for Escrow contract
      await this.spinToken.approve(this.escrow.address, USER_INITIAL_FUNDING, {from: addr1}).should.be.fulfilled;
      await this.spinToken.approve(this.escrow.address, USER_INITIAL_FUNDING, {from: addr2}).should.be.fulfilled;
      await this.spinToken.approve(this.escrow.address, USER_INITIAL_FUNDING, {from: addr3}).should.be.fulfilled;
    });

    it('registers an actor', async () => {
      let actorId = 1234;
      let actorAddress = addr1;
      let role = SYSTEM_ROLES.influencer;

      await this.proxy.registerActor(actorId, actorAddress, role).should.be.fulfilled;
      
      // Check if actor attributes are set correct
      let actor = await this.actorDB.get(actorId);
      actor['actorAddress'].should.be.equal(actorAddress);
      actor['role'].should.be.equal(role);
    });

    it('registers a product', async () => {
      let productId = 1234;
      let productDescription = 'Fancy product';
      let actorId = 1234;
      let actorAddress = addr1;
      let role = SYSTEM_ROLES.supplier;
      let actorPreBalance = await this.spinToken.balanceOf(actorAddress);
      let actorPostBalance;

      // First register a supplier
      await this.proxy.registerActor(actorId, actorAddress, role).should.be.fulfilled;
      
      // Check if actor attributes are set correct
      let actor = await this.actorDB.get(actorId);
      actor['actorAddress'].should.be.equal(actorAddress);
      actor['role'].should.be.equal(role);

      // Register the product
      await this.proxy.registerProduct(productId, actorId, productDescription).should.be.fulfilled;

      // Check if token balance of the user registered is reduced by user registration fee
      actorPostBalance = await this.spinToken.balanceOf(actorAddress);
      actorPostBalance.toNumber().should.be.equal(actorPreBalance.toNumber() - REGISTRATION_FEES.product.toNumber());
    });

    it('registers a campaign', async () => {
      let campaignId = 2412;
      let influencerId = 1789231;
      let finishAt = (await getCurrentTimestamp()) + 300;
      let ratio = 10;
      let productId = 1234;
      let productDescription = 'Fancy product';
      let supplierId = 1234;
      let supplierAddress = addr1;
      let influencerAddress = addr2;
      let supplierPreBalance = await this.spinToken.balanceOf(supplierAddress);
      let supplierPostBalance;

      // First register a supplier
      await this.proxy.registerActor(supplierId, supplierAddress, SYSTEM_ROLES.supplier).should.be.fulfilled;
      await this.proxy.registerActor(influencerId, influencerAddress, SYSTEM_ROLES.influencer).should.be.fulfilled;

      // Register the product
      await this.proxy.registerProduct(productId, supplierId, productDescription).should.be.fulfilled;

      // Register the campaign
      await this.proxy.registerCampaign(campaignId, supplierId, influencerId, productId, finishAt, ratio).should.be.fulfilled;

      // Check if token balance of the user registered is reduced by user registration fee
      supplierPostBalance = await this.spinToken.balanceOf(supplierAddress);
      supplierPostBalance.toNumber().should.be.equal(supplierPreBalance.toNumber() - REGISTRATION_FEES.campaign.add(REGISTRATION_FEES.product).toNumber());
    });

    it('records a purchase', async () => {
      let purchaseId = 7523;
      let transactionId = 16576523;
      let purchaseAmount = 20000;
      let purchasedAt = (await getCurrentTimestamp()) - 1000;
      let campaignId = 2412;
      let finishAt = (await getCurrentTimestamp()) + 300;
      let ratio = 10;
      let productId = 1234;
      let productDescription = 'Fancy product';
      let supplierId = 1234;
      let influencerId = 1789231;
      let customerId = 93735;
      let supplierAddress = addr1;
      let influencerAddress = addr2;
      let customerAddress = addr3;
      let customerPreBalance = await this.spinToken.balanceOf(customerAddress);
      let customerPostBalance;

      // First register a supplier, influencer and a customer
      await this.proxy.registerActor(supplierId, supplierAddress, SYSTEM_ROLES.supplier).should.be.fulfilled;
      await this.proxy.registerActor(influencerId, influencerAddress, SYSTEM_ROLES.influencer).should.be.fulfilled;
      await this.proxy.registerActor(customerId, customerAddress, SYSTEM_ROLES.customer).should.be.fulfilled;

      // Register a product
      await this.proxy.registerProduct(productId, supplierId, productDescription).should.be.fulfilled;
      // Register a campaign
      await this.proxy.registerCampaign(campaignId, supplierId, influencerId, productId, finishAt, ratio).should.be.fulfilled;
      // Register a purchase
      await this.proxy.recordPurchase(campaignId, purchaseId, customerId, productId, transactionId, purchaseAmount, purchasedAt).should.be.fulfilled;

      // Check if token balance of the customer increased by payback amount
      // TODO: For the time being, the payback amount is 10 percent of the purchase amount in SPIN Token
      customerPreBalance = await this.spinToken.balanceOf(supplierAddress);
      customerPostBalance.toNumber().should.be.equal(customerPreBalance.add(purchaseAmount / 10).toNumber());
    });
  });

  // describe('SpinProtocol::Features::Negatives', () => {
  //   it('registers an actor to DB', async () => {
  //     let actorId = '';
  //     let actorAddress = addr1;
  //     let role = SYSTEM_ROLES.influencer;

  //     await this.proxy.registerActor(actorId, actorAddress, role).should.be.fulfilled;
  //     let actor = await this.actorDB.get(actorId).should.be.fulfilled;
  //     actor['actorAddress'].should.be.equal(actorAddress);
  //     actor['role'].should.be.equal(role);
  //   });
  // });
});
