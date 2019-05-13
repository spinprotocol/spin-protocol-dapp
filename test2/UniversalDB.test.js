const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');

const CONTRACT_NAME = 'ActorDB';
const DB_TABLE_NAME = web3.utils.soliditySha3("ActorTable");

// Error messages from UniversalDB contract
const ERROR_ONLY_CONTRACT = 'Only specific contract';


contract('UniversalDB', ([creator, unauthorizedAddr, randomAddr]) => {
  let nodeId = 12324353;

  beforeEach(async () => {
    this.proxy = await Proxy.new();

    this.universalDB = await UniversalDB.new();
    this.universalDB.setProxy(this.proxy.address).should.be.fulfilled;

    // Add creator address as if it is ActorDB contract who is one of the clients for UniversalDB contract
    // In this way, we can call UniversalDB functions directly.
    await this.proxy.addContract(CONTRACT_NAME, creator).should.be.fulfilled;
  });

  describe('UniversalDB::Authority', () => {
    it('sets proxy', async () => {
      await this.universalDB.setProxy(randomAddr).should.be.fulfilled;
      let proxy = await this.universalDB.proxy();
      proxy.should.be.equal(randomAddr);
    });

    it('does not allow unauthorized address to access proxy setter function', async () => {
      await this.universalDB.setProxy(this.proxy.address, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow unauthorized address to access attribute setter functions', async () => {
      let key = web3.utils.soliditySha3('data_key');
      await this.universalDB.setIntStorage(CONTRACT_NAME, key, -123, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
      await this.universalDB.setUintStorage(CONTRACT_NAME, key, 123, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
      await this.universalDB.setAddressStorage(CONTRACT_NAME, key, randomAddr, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
      await this.universalDB.setBoolStorage(CONTRACT_NAME, key, true, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
      await this.universalDB.setBytesStorage(CONTRACT_NAME, key, web3.utils.toHex(123), {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
      await this.universalDB.setStringStorage(CONTRACT_NAME, key, 'asdad', {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
      await this.universalDB.pushNodeToLinkedList(CONTRACT_NAME, DB_TABLE_NAME, nodeId, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
      
      // Create a linked list and an item in the list with authorized address to test the remaining functions
      await this.universalDB.pushNodeToLinkedList(CONTRACT_NAME, DB_TABLE_NAME, nodeId).should.be.fulfilled;
      await this.universalDB.removeNodeFromLinkedList(CONTRACT_NAME, DB_TABLE_NAME, nodeId, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });
  });

  describe('UniversalDB::Setters/Getters', () => {
    it('sets/gets data', async () => {
      let _int = -123;
      let _uint = 456;
      let _address = randomAddr;
      let _bool = true;
      let _bytes = web3.utils.toHex('asdadadasdadadasdadasdasdasdqweqweqfadsfdgdghdgfsjhskfjhskfsjfnsjfsf');
      let _string = 'asdadadasdadadasdadasdasdasdqweqweqfadsfdgdghdgfsjhskfjhskfsjfnsjfsf';

      await this.universalDB.setIntStorage(CONTRACT_NAME, web3.utils.soliditySha3('int_data'), _int).should.be.fulfilled;
      await this.universalDB.setUintStorage(CONTRACT_NAME, web3.utils.soliditySha3('uint_data'), _uint).should.be.fulfilled;
      await this.universalDB.setAddressStorage(CONTRACT_NAME, web3.utils.soliditySha3('address_data'), _address).should.be.fulfilled;
      await this.universalDB.setBoolStorage(CONTRACT_NAME, web3.utils.soliditySha3('bool_data'), _bool).should.be.fulfilled;
      await this.universalDB.setBytesStorage(CONTRACT_NAME, web3.utils.soliditySha3('bytes_data'), _bytes).should.be.fulfilled;
      await this.universalDB.setStringStorage(CONTRACT_NAME, web3.utils.soliditySha3('string_data'), _string).should.be.fulfilled;

      // Get data back for the keys and compare them with the actual values
      let int = await this.universalDB.getIntStorage(CONTRACT_NAME, web3.utils.soliditySha3('int_data'));
      let uint = await this.universalDB.getUintStorage(CONTRACT_NAME, web3.utils.soliditySha3('uint_data'));
      let address = await this.universalDB.getAddressStorage(CONTRACT_NAME, web3.utils.soliditySha3('address_data'));
      let bool = await this.universalDB.getBoolStorage(CONTRACT_NAME, web3.utils.soliditySha3('bool_data'));
      let bytes = await this.universalDB.getBytesStorage(CONTRACT_NAME, web3.utils.soliditySha3('bytes_data'));
      let string = await this.universalDB.getStringStorage(CONTRACT_NAME, web3.utils.soliditySha3('string_data'));

      int.toNumber().should.be.equal(_int);
      uint.toNumber().should.be.equal(_uint);
      address.should.be.equal(_address);
      bool.should.be.equal(_bool);
      bytes.should.be.equal(_bytes);
      string.should.be.equal(_string);
    });

    it('creates and modifies linklist', async () => {
      await this.universalDB.pushNodeToLinkedList(CONTRACT_NAME, DB_TABLE_NAME, nodeId).should.be.fulfilled;
      let doesExist = await this.universalDB.doesNodeExist(CONTRACT_NAME, DB_TABLE_NAME, nodeId);
      doesExist.should.be.true;

      doesExist = await this.universalDB.doesListExist(CONTRACT_NAME, DB_TABLE_NAME);
      doesExist.should.be.true;

      await this.universalDB.removeNodeFromLinkedList(CONTRACT_NAME, DB_TABLE_NAME, nodeId).should.be.fulfilled;
      doesExist = await this.universalDB.doesNodeExist(CONTRACT_NAME, DB_TABLE_NAME, nodeId);
      doesExist.should.be.false;

      doesExist = await this.universalDB.doesListExist(CONTRACT_NAME, DB_TABLE_NAME);
      doesExist.should.be.false;
    });

    it('iterates all items in linklist', async () => {
      let nodeIds = [1234, 45667, 34456, 342452, 123178];

      // First create some nodes in DB
      for (let i = 0; i < nodeIds.length; i++) {
        await this.universalDB.pushNodeToLinkedList(CONTRACT_NAME, DB_TABLE_NAME, nodeIds[i]).should.be.fulfilled;
      }

      let totalUsers = (await this.universalDB.getLinkedListSize(CONTRACT_NAME, DB_TABLE_NAME)).toNumber();
      totalUsers.should.be.equal(nodeIds.length);

      let node = 0; // Start from the HEAD. HEAD is always 0.
      let index = totalUsers - 1;
      do {
        let ret = await this.universalDB.getAdjacent(CONTRACT_NAME, DB_TABLE_NAME, node, true);
        // ret value includes direction and node id. Ex => {'0': true, '1': 1234}
        node = ret['1'].toNumber();

        // it means that we reach the end of the list
        if (!node) break;
        // The first item in TRUE direction is the last item pushed => LIFO (stack)
        node.should.be.equal(nodeIds[index]);
        index--;
      } while (node)
    });
  });
});
