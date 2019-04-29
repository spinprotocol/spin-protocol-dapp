const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();
const { getCurrentTimestamp, increaseTime } = require('./utils/evm');

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
const SHARE_AND_REWARD_MULTIPLIERS = {
  customerRatio: 500,
  influencerRatio: 10,
  supplierRatio: 50,
  serviceProviderRatio: 2000
};
const ESCROW_INITIAL_FUNDING = new BigNumber(20000000);
const USER_INITIAL_FUNDING = new BigNumber(10000);

  
contract('SpinProtocol', ([creator, addr1, addr2, addr3, addr4, addr5, addr6, feeCollector, unauthorizedAddr, randomAddr]) => {

  beforeEach(async () => {
    // Deploy system contracts
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

    // Initialize system contracts
    await this.universalDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.actorDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.campaignDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.dealDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.productDB.setProxy(this.proxy.address).should.be.fulfilled;
    await this.purchaseDB.setProxy(this.proxy.address).should.be.fulfilled;
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

    // Add system contracts to proxy contract
    await this.proxy.addContract('SpinProtocol', this.spinProtocol.address).should.be.fulfilled;
    await this.proxy.addContract('EscrowAndFees', this.escrow.address).should.be.fulfilled;
    await this.proxy.addContract('ActorDB', this.actorDB.address).should.be.fulfilled;
    await this.proxy.addContract('CampaignDB', this.campaignDB.address).should.be.fulfilled;
    await this.proxy.addContract('DealDB', this.dealDB.address).should.be.fulfilled;
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
      // Set share & reward ratios
      await this.proxy.setShareAndRewardRatios(
        SHARE_AND_REWARD_MULTIPLIERS.customerRatio,
        SHARE_AND_REWARD_MULTIPLIERS.influencerRatio,
        SHARE_AND_REWARD_MULTIPLIERS.supplierRatio,
        SHARE_AND_REWARD_MULTIPLIERS.serviceProviderRatio
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
      let productId = 25347;
      let productPrice = 20000;
      let productDescription = 'Fancy product';
      let supplierId = 1234;
      let actorAddress = addr1;

      // First register a supplier
      await this.proxy.registerActor(supplierId, actorAddress, SYSTEM_ROLES.supplier).should.be.fulfilled;
      
      // Check if actor attributes are set correct
      let actor = await this.actorDB.get(supplierId);
      actor['actorAddress'].should.be.equal(actorAddress);
      actor['role'].should.be.equal(SYSTEM_ROLES.supplier);

      // Register the product
      await this.proxy.registerProduct(productId, supplierId, productPrice, productDescription).should.be.fulfilled;
      
      let product = await this.productDB.get(productId);
      product['supplierId'].toNumber().should.be.equal(supplierId);
      product['price'].toNumber().should.be.equal(productPrice);
      product['metadata'].should.be.equal(productDescription);
    });

    it('registers a campaign', async () => {
      let campaignId = 2412;
      let influencerId = 1789231;
      let finishAt = (await getCurrentTimestamp()) + 300;
      let totalSupply = 10;
      let productId = 45646;
      let productPrice = 20000;
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
      await this.proxy.registerProduct(productId, supplierId, productPrice, productDescription).should.be.fulfilled;

      // Register the campaign
      await this.proxy.registerCampaign(campaignId, supplierId, productId, totalSupply, finishAt).should.be.fulfilled;

      // Check if token balance of the user registered is reduced by user registration fee
      supplierPostBalance = await this.spinToken.balanceOf(supplierAddress);
      supplierPostBalance.toNumber().should.be.equal(supplierPreBalance.toNumber() - REGISTRATION_FEES.campaign.toNumber());
    });

    it('registers a deal', async () => {
      let campaignId = 2412;
      let finishAt = (await getCurrentTimestamp()) + 300;
      let totalSupply = 10;
      let productId = 4757;
      let productPrice = 10000;
      let productDescription = 'Fancy product';
      let dealId = 234521;
      let dealRatio = 10;
      let supplierId = 1234;
      let influencerId = 1789231;
      let customerId = 93735;
      let supplierAddress = addr1;
      let influencerAddress = addr2;
      let customerAddress = addr3;

      // First register a supplier, influencer and a customer
      await this.proxy.registerActor(supplierId, supplierAddress, SYSTEM_ROLES.supplier).should.be.fulfilled;
      await this.proxy.registerActor(influencerId, influencerAddress, SYSTEM_ROLES.influencer).should.be.fulfilled;
      await this.proxy.registerActor(customerId, customerAddress, SYSTEM_ROLES.customer).should.be.fulfilled;

      // Register a product
      await this.proxy.registerProduct(productId, supplierId, productPrice, productDescription).should.be.fulfilled;
      // Register a campaign
      await this.proxy.registerCampaign(campaignId, supplierId, productId, totalSupply, finishAt).should.be.fulfilled;
      // Create a deal
      await this.proxy.attendCampaign(dealId, campaignId, influencerId, dealRatio).should.be.fulfilled;
    });

    it('records a purchase', async () => {
      let purchaseId = 7523;
      let purchaseAmount = 5;
      let campaignId = 2412;
      let finishAt = (await getCurrentTimestamp()) + 300;
      let totalSupply = 10;
      let productId = 4757;
      let productPrice = 10000;
      let productDescription = 'Fancy product';
      let dealId = 234521;
      let dealRatio = 10;
      let supplierId = 1234;
      let influencerId = 1789231;
      let customerId = 93735;
      let supplierAddress = addr1;
      let influencerAddress = addr2;
      let customerAddress = addr3;

      // First register a supplier, influencer and a customer
      await this.proxy.registerActor(supplierId, supplierAddress, SYSTEM_ROLES.supplier).should.be.fulfilled;
      await this.proxy.registerActor(influencerId, influencerAddress, SYSTEM_ROLES.influencer).should.be.fulfilled;
      await this.proxy.registerActor(customerId, customerAddress, SYSTEM_ROLES.customer).should.be.fulfilled;

      // Register a product
      await this.proxy.registerProduct(productId, supplierId, productPrice, productDescription).should.be.fulfilled;
      // Register a campaign
      await this.proxy.registerCampaign(campaignId, supplierId, productId, totalSupply, finishAt).should.be.fulfilled;
      // Create a deal
      await this.proxy.attendCampaign(dealId, campaignId, influencerId, dealRatio).should.be.fulfilled;
      // Register a purchase
      await this.proxy.recordPurchase(
        purchaseId,
        customerId,
        campaignId,
        dealId,
        purchaseAmount,
      ).should.be.fulfilled;
    });

    it('releases R/S', async () => {
      let purchaseCount = 20;
      let campaignId = 2412;
      let finishAt = (await getCurrentTimestamp()) + 300;
      let totalSupply = 100;
      let productId = 4757;
      let productPrice = 10000;
      let productDescription = 'Fancy product';
      let deal1Id = 234521;
      let dealRatio = 10;
      let supplierId = 1234;
      let influencerId = 1789231;
      let customerId = 93735;
      let supplierAddress = addr1;
      let influencerAddress = addr2;
      let customerAddress = addr3;
      let influencerPreBalance;
      let influencerPostBalance;
      let supplierPreBalance;
      let supplierPostBalance;

      let deal2Id = 66666;
      let deal3Id = 88888;

      // First register a supplier, influencer and a customer
      await this.proxy.registerActor(supplierId, supplierAddress, SYSTEM_ROLES.supplier).should.be.fulfilled;
      await this.proxy.registerActor(influencerId, influencerAddress, SYSTEM_ROLES.influencer).should.be.fulfilled;
      await this.proxy.registerActor(5555, unauthorizedAddr, SYSTEM_ROLES.influencer).should.be.fulfilled;
      await this.proxy.registerActor(7777, randomAddr, SYSTEM_ROLES.influencer).should.be.fulfilled;
      await this.proxy.registerActor(customerId, customerAddress, SYSTEM_ROLES.customer).should.be.fulfilled;
      await this.proxy.registerActor(131231, randomAddr, SYSTEM_ROLES.customer).should.be.fulfilled;

      // Register a product
      await this.proxy.registerProduct(productId, supplierId, productPrice, productDescription).should.be.fulfilled;
      // Register a campaign
      await this.proxy.registerCampaign(campaignId, supplierId, productId, totalSupply, finishAt).should.be.fulfilled;
      // Create a deal
      await this.proxy.attendCampaign(deal1Id, campaignId, influencerId, dealRatio).should.be.fulfilled;
      // Create a deal
      await this.proxy.attendCampaign(deal2Id, campaignId, 5555, 10).should.be.fulfilled;
      // Create a deal
      await this.proxy.attendCampaign(deal3Id, campaignId, 7777, 10).should.be.fulfilled;

      // Make a purchase from deal-1
      await this.proxy.recordPurchase(23354, customerId, campaignId, deal1Id, purchaseCount).should.be.fulfilled;
      // Make a purchase from deal-1
      await this.proxy.recordPurchase(578, customerId, campaignId, deal1Id, purchaseCount).should.be.fulfilled;
      // Make a purchase from deal-2
      await this.proxy.recordPurchase(98274, customerId, campaignId, deal2Id, purchaseCount).should.be.fulfilled;
      // Make a purchase from deal-3
      await this.proxy.recordPurchase(345678, 131231, campaignId, deal3Id, purchaseCount).should.be.fulfilled;

      // Get pre balances before share release
      supplierPreBalance = (await this.spinToken.balanceOf(supplierAddress)).toNumber();
      influencerPreBalance = (await this.spinToken.balanceOf(influencerAddress)).toNumber();

      // Wind block time forward to a time when the campaign ends
      await increaseTime(400);
      // Release shares and rewards
      await this.proxy.releaseRevenue(campaignId).should.be.fulfilled;

      let totalSaleCount = totalSupply - (await this.campaignDB.getCurrentSupply(campaignId)).toNumber();

      // Check balance for influencer-1
      let influencerShare = calculateInfluencerShare(productPrice, totalSaleCount, purchaseCount * 2, dealRatio, SHARE_AND_REWARD_MULTIPLIERS.influencerRatio);
      influencerPostBalance = (await this.spinToken.balanceOf(influencerAddress)).toNumber();
      influencerPostBalance.should.be.equal(influencerPreBalance + influencerShare);

      // Check balance for supplier
      let supplierShare = calculateSupplierShare(productPrice, totalSaleCount, SHARE_AND_REWARD_MULTIPLIERS.supplierRatio);
      supplierPostBalance = (await this.spinToken.balanceOf(supplierAddress)).toNumber();
      supplierPostBalance.should.be.equal(supplierPreBalance + supplierShare);
    });

    it('releases customer rewards', async () => {
      let purchaseCount = 20;
      let campaignId = 2412;
      let finishAt = (await getCurrentTimestamp()) + 300;
      let totalSupply = 100;
      let productId = 4757;
      let productPrice = 10000;
      let productDescription = 'Fancy product';
      let dealId = 234521;
      let dealRatio = 10;
      let supplierId = 1234;
      let influencerId = 1789231;
      let customer1Id = 93735;
      let customer2Id = 123142;
      let customer3Id = 5676745;
      let customer4Id = 23456;

      // First register a supplier, influencer and a customer
      await this.proxy.registerActor(supplierId, addr1, SYSTEM_ROLES.supplier).should.be.fulfilled;
      await this.proxy.registerActor(influencerId, addr2, SYSTEM_ROLES.influencer).should.be.fulfilled;
      await this.proxy.registerActor(customer1Id, addr3, SYSTEM_ROLES.customer).should.be.fulfilled;
      await this.proxy.registerActor(customer2Id, addr4, SYSTEM_ROLES.customer).should.be.fulfilled;
      await this.proxy.registerActor(customer3Id, addr5, SYSTEM_ROLES.customer).should.be.fulfilled;
      await this.proxy.registerActor(customer4Id, addr6, SYSTEM_ROLES.customer).should.be.fulfilled;

      // Register a product
      await this.proxy.registerProduct(productId, supplierId, productPrice, productDescription).should.be.fulfilled;
      // Register a campaign
      await this.proxy.registerCampaign(campaignId, supplierId, productId, totalSupply, finishAt).should.be.fulfilled;
      // Create a deal
      await this.proxy.attendCampaign(dealId, campaignId, influencerId, dealRatio).should.be.fulfilled;

      // Make a purchase as customer-1
      await this.proxy.recordPurchase(23354, customer1Id, campaignId, dealId, purchaseCount).should.be.fulfilled;
      // Make a purchase as customer-2
      await this.proxy.recordPurchase(578, customer2Id, campaignId, dealId, purchaseCount).should.be.fulfilled;
      // Make a purchase as customer-3
      await this.proxy.recordPurchase(98274, customer3Id, campaignId, dealId, purchaseCount).should.be.fulfilled;
      // Make a purchase as customer-4
      await this.proxy.recordPurchase(345678, customer4Id, campaignId, dealId, purchaseCount).should.be.fulfilled;

      // Wind block time forward to a time when the campaign ends
      await increaseTime(400);
      // Release shares and rewards
      await this.proxy.releaseRewards(campaignId).should.be.fulfilled;

      // let totalSaleCount = totalSupply - (await this.campaignDB.getCurrentSupply(campaignId)).toNumber();

      // // Check balance for influencer-1
      // let rs = calculateInfluencerShare(productPrice, totalSaleCount, purchaseCount * 2, dealRatio);
      // influencerPostBalance = (await this.spinToken.balanceOf(influencerAddress)).toNumber();
      // influencerPostBalance.should.be.equal(influencerPreBalance + rs);
    });
  });
});

function calculateInfluencerShare(productPrice, totalSaleCount, saleCount, dealRatio, multiplier) {
  return Number(totalSaleCount * productPrice * saleCount * dealRatio / 10000 * multiplier / 10000);
}

function calculateSupplierShare(productPrice, totalSaleCount, supplierRatio) {
  return Number(totalSaleCount * productPrice * supplierRatio / 10000);
}

function calculateCustomerReward(productPrice, totalSaleCount, purchaseCount, customerRatio) {
  return Number(totalSaleCount * productPrice * purchaseCount * dealRatio / 10000 / 1000);
}
