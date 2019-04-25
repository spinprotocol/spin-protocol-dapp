const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const ProductDB = artifacts.require('ProductDB');
const CONTRACT_NAME_PRODUCT_DB = 'ProductDB';

// Error messages from ProductDB contract
const ERROR_ONLY_CONTRACT = 'Only specific contract';
const ERROR_ALREADY_EXIST = 'Product already exists';
const ERROR_DOES_NOT_EXIST = 'Product does not exist';

  
contract('ProductDB', ([creator, unauthorizedAddr, randomAddr]) => {

  beforeEach(async () => {
    this.proxy = await Proxy.new();

    this.universalDB = await UniversalDB.new();
    this.universalDB.setProxy(this.proxy.address).should.be.fulfilled;

    this.productDB = await ProductDB.new(this.universalDB.address);
    this.productDB.setProxy(this.proxy.address).should.be.fulfilled;

    await this.proxy.addContract(CONTRACT_NAME_PRODUCT_DB, this.productDB.address).should.be.fulfilled;
    // Add creator address as if it is SpinProtocol contracts who is a client for ProductDB contract
    // In this way, we can call ProductDB functions directly.
    await this.proxy.addContract('SpinProtocol', creator).should.be.fulfilled;
  });

  describe('ProductDB::Authority', () => {
    it('does not allow an unauthorized address to set proxy', async () => {
      await this.productDB.setProxy(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to set db pointer', async () => {
      await this.productDB.setUniversalDB(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to create a new product item in db', async () => {
      await this.productDB.create(1, 2, 3, 'random description', {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });

    it('does not allow an unauthorized address to update a product item in db', async () => {
      let productId = 1;
      await this.productDB.create(productId, 123, 30000, 'fake description').should.be.fulfilled;
      await this.productDB.update(productId, 10000, 'updated description', {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });
  });

  describe('ProductDB::Features', () => {
    it('sets proxy', async () => {
      await this.productDB.setProxy(randomAddr).should.be.fulfilled;
      let proxy = await this.productDB.proxy();
      proxy.should.be.equal(randomAddr);
    });

    it('sets db pointer', async () => {
      await this.productDB.setUniversalDB(randomAddr).should.be.fulfilled;
      let universalDB = await this.productDB.universalDB();
      universalDB.should.be.equal(randomAddr);
    });

    it('creates a new product item in db', async () => {
      let productId = 124;
      let supplierId = 32453;
      let price = 10000;
      let description = 'random description';

      await this.productDB.create(productId, supplierId, price, description).should.be.fulfilled;

      let res = await this.productDB.get(productId);
      res['supplierId'].toNumber().should.be.equal(supplierId);
      res['price'].toNumber().should.be.equal(price);
      res['metadata'].should.be.equal(description);
    });

    it('updates a product item in db', async () => {
      let productId = 124;
      let supplierId = 32453;
      let price = 10000;
      let newPrice = 20000;
      let newDescription = 'random updated description';

      await this.productDB.create(productId, supplierId, price, 'random description').should.be.fulfilled;
      await this.productDB.update(productId, newPrice, newDescription).should.be.fulfilled;

      let res = await this.productDB.get(productId);
      res['price'].toNumber().should.be.equal(newPrice);
      res['metadata'].should.be.equal(newDescription);
    });
  });

  describe('ProductDB::Features::Negatives', () => {
    it('does not allow to create a product item with invalid parameters', async () => {
      await this.productDB.create(0, 1, 2, 'fake description').should.be.rejected;
      await this.productDB.create(1, 0, 2, 'fake description').should.be.rejected;
    });

    it('does not allow to create a duplicate item (with the same id)', async () => {
      await this.productDB.create(1, 2, 3, 'fake description').should.be.fulfilled;
      await this.productDB.create(1, 3, 5, 'fake description again').should.be.rejectedWith(ERROR_ALREADY_EXIST);
    });

    it('does not allow to update a non-existent product item', async () => {
      await this.productDB.update(123, 4, 'updated description').should.be.rejectedWith(ERROR_DOES_NOT_EXIST);
    });
  });
});
