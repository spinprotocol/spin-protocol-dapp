const BigNumber = require('bignumber.js');
require('chai')
  .use(require('chai-shallow-deep-equal'))
  .use(require('chai-bignumber')(BigNumber))
  .use(require('chai-as-promised'))
  .should();
const { ZERO_ADDRESS } = require('./utils/constants');

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const ActorDB = artifacts.require('ActorDB');
const CONTRACT_NAME_ACTOR_DB = 'ActorDB';

// Error messages from ActorDB contract
const ERROR_ONLY_CONTRACT = 'Only specific contract';
const ERROR_ALREADY_EXIST = 'Actor already exists';
const ERROR_DOES_NOT_EXIST = 'Actor does not exist';

  
contract('ActorDB', ([creator, addr1, addr2, unauthorizedAddr, randomAddr]) => {

  beforeEach(async () => {
    this.proxy = await Proxy.new();

    this.universalDB = await UniversalDB.new();
    this.universalDB.setProxy(this.proxy.address).should.be.fulfilled;

    this.actorDB = await ActorDB.new(this.universalDB.address);
    this.actorDB.setProxy(this.proxy.address).should.be.fulfilled;

    await this.proxy.addContract(CONTRACT_NAME_ACTOR_DB, this.actorDB.address).should.be.fulfilled;
    // Add creator address as if it is SpinProtocol contracts who is a client for ActorDB contract
    // In this way, we can call ActorDB functions directly.
    await this.proxy.addContract('SpinProtocol', creator).should.be.fulfilled;
  });

  describe('ActorDB::Authority', () => {
    it('does not allow an unauthorized address to set proxy', async () => {
      await this.actorDB.setProxy(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to set db pointer', async () => {
      await this.actorDB.setUniversalDB(randomAddr, {from: unauthorizedAddr}).should.be.rejected;
    });

    it('does not allow an unauthorized address to create a new actor item in db', async () => {
      await this.actorDB.create(1, addr1, 'random_role', {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });

    it('does not allow an unauthorized address to update an actor item in db', async () => {
      let actorId = 1;
      await this.actorDB.create(actorId, addr1, 'fake_role').should.be.fulfilled;
      await this.actorDB.updateAddress(actorId, addr2, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
      await this.actorDB.updateSFame(actorId, 5434, {from: unauthorizedAddr}).should.be.rejectedWith(ERROR_ONLY_CONTRACT);
    });
  });

  describe('ActorDB::Features', () => {
    it('sets proxy', async () => {
      await this.actorDB.setProxy(randomAddr).should.be.fulfilled;
      let proxy = await this.actorDB.proxy();
      proxy.should.be.equal(randomAddr);
    });

    it('sets db pointer', async () => {
      await this.actorDB.setUniversalDB(randomAddr).should.be.fulfilled;
      let universalDB = await this.actorDB.universalDB();
      universalDB.should.be.equal(randomAddr);
    });

    it('creates a new actor item in db', async () => {
      let actorId = 124;
      let actorAddress = addr1;
      let role = 'random_role';

      await this.actorDB.create(actorId, actorAddress, role).should.be.fulfilled;

      let _addr = await this.actorDB.getAddress(actorId);
      let _role = await this.actorDB.getRole(actorId);
      _addr.should.be.equal(actorAddress);
      _role.should.be.equal(role);
    });

    it('updates an actor item in db', async () => {
      let actorId = 124;
      let sfame = 123;

      await this.actorDB.create(actorId, addr1, 'random_role').should.be.fulfilled;
      await this.actorDB.updateAddress(actorId, addr2).should.be.fulfilled;
      await this.actorDB.updateSFame(actorId, sfame).should.be.fulfilled;

      let _addr = await this.actorDB.getAddress(actorId);
      let _sfame = await this.actorDB.getSFame(actorId);

      _addr.should.be.equal(addr2);
      _sfame.toNumber().should.be.equal(sfame);
    });
  });

  describe('ActorDB::Features::Negatives', () => {
    it('does not allow to create an actor item with invalid parameters', async () => {
      await this.actorDB.create(0, addr1, 'fake_role').should.be.rejected;
      await this.actorDB.create(1, ZERO_ADDRESS, 'fake_role').should.be.rejected;
    });

    it('does not allow to create a duplicate item in db', async () => {
      await this.actorDB.create(1, addr1, 'fake_role').should.be.fulfilled;
      await this.actorDB.create(1, addr2, 'fake_role_2').should.be.rejectedWith(ERROR_ALREADY_EXIST);
    });

    it('does not allow to update a non-existent actor item in db', async () => {
      await this.actorDB.updateAddress(123, addr2).should.be.rejectedWith(ERROR_DOES_NOT_EXIST);
      await this.actorDB.updateSFame(123, 4562).should.be.rejectedWith(ERROR_DOES_NOT_EXIST);
    });
  });
});
