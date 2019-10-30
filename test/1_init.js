Object.assign(global, require('ffp-js'));
const assert = require('assert');

const {
    Deployer,
    Signer,
    Token,
    Test,
    UTILS,
    viewContract,
    callContract
} = require('../utils/caver.js');
const { METADATA } = require('../utils/metadata');
const { evmError } = require('../utils/errorFilter.js')

describe('[Init] setting check', () => {
    it('[Auth] init admin of Campaign', async () => {
        assert.equal(
            true,
            await viewContract(
                METADATA.Campaign, 
                'isAdmin(address)', 
                [Signer.address]
            )
        )
    })

    it('[Token] init token address of RevenueLedger', async () => {
        assert.equal(
            UTILS.toChecksumAddr(Token),
            await viewContract(
                METADATA.RevenueLedger, 
                'getTokenAddr(string)', 
                ["SPIN"]
            )
        )
    })

})

describe('[AuthStorage] Auth function', () => {
    it('(Non-admin) address', async () => {
        assert.equal(
            false,
            await viewContract(
                METADATA.Campaign, 
                'isAdmin(address)', 
                [Test.address]
            )
        )
    })

    it('➡️  addAuth(admin,Test)', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'addAuth', 
                    ["string","address"], 
                    ["admin",Test.address], 
                    METADATA.AuthStorage._address
                ),
                a => a.status
            )
        )
    })

    it('isAdmin(Test) of Campaign', async () => {
        assert.equal(
            true,
            await viewContract(
                METADATA.Campaign, 
                'isAdmin(address)', 
                [Test.address]
            )
        )
    })

    it('➡️  removeAuth(admin,Test)', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'removeAuth', 
                    ["string","address"], 
                    ["admin",Test.address], 
                    METADATA.AuthStorage._address
                ),
                a => a.status
            )
        )
    })

    it('removeAuth(Test) of Campaign', async () => {
        assert.equal(
            false,
            await viewContract(
                METADATA.Campaign,
                'isAdmin(address)',
                [Test.address]
            )
        )
    })
})

describe('[Token] Token Control function', () => {

    before('test token send', async () => {
        await callContract(
                'transfer', 
                ['address', 'uint256'], 
                [METADATA.RevenueLedger._address, UTILS.toPeb(1)], 
                Token
            )
    })

    it('getBalance(SPIN) : 1', async () => {
        assert.equal(
            UTILS.toPeb(1),
            await viewContract(
                METADATA.RevenueLedger, 
                'getBalance(string)', 
                ["SPIN"]
            )
        )
    })

    it('➡️  (Non-admin) sendToken(Deployer,1)', () => 
        evmError(() => callContract(
            'sendToken', 
            ["string","address","uint256"], 
            ["SPIN", Deployer.address, UTILS.toPeb(1)], 
            METADATA.RevenueLedger._address,
            true
        ))
    )

    it('➡️  sendToken(Deployer,1)', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'sendToken', 
                    ["string","address","uint256"], 
                    ["SPIN", Deployer.address, UTILS.toPeb(1)], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('getBalance(SPIN) : 0', async () => {
        assert.equal(
            0,
            await viewContract(
                METADATA.RevenueLedger, 
                'getBalance(string)', 
                ["SPIN"]
            )
        )
    })
})
