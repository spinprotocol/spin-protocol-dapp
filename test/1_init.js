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
        const account = Signer.address

        assert.equal(
            true,
            await viewContract(
                METADATA.Campaign, 
                'isAdmin(address)', 
                [account]
            )
        )
    })

    it('[Token] init token address of RevenueLedger', async () => {
        const _tokenName = 'SPIN'

        assert.equal(
            UTILS.toChecksumAddr(Token),
            await viewContract(
                METADATA.RevenueLedger, 
                'getTokenAddr(string)', 
                [_tokenName]
            )
        )
    })

})

describe('[AuthStorage] Auth function', () => {
    it('(Non-admin) isAdmin()', async () => {
        const account = Test.address

        assert.equal(
            false,
            await viewContract(
                METADATA.Campaign, 
                'isAdmin(address)', 
                [account]
            )
        )
    })

    it('➡️  addAuth(admin,Test)', async () => {
        const auth = 'admin'
        const account = Test.address

        assert.equal(
            true,
            await go(
                callContract(
                    'addAuth', 
                    ['string', 'address'], 
                    [auth, account], 
                    METADATA.AuthStorage._address
                ),
                a => a.status
            )
        )
    })

    it('isAdmin(Test) of Campaign', async () => {
        const account = Test.address

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
        const auth = 'admin'
        const account = Test.address

        assert.equal(
            true,
            await go(
                callContract(
                    'removeAuth', 
                    ['string', 'address'], 
                    [auth, account], 
                    METADATA.AuthStorage._address
                ),
                a => a.status
            )
        )
    })

    it('removeAuth(Test) of Campaign', async () => {
        const account = Test.address

        assert.equal(
            false,
            await viewContract(
                METADATA.Campaign,
                'isAdmin(address)',
                [account]
            )
        )
    })
})

describe('[Token] Token Control function', () => {

    before('test token send', async () => {
        const to = METADATA.RevenueLedger._address
        const amount = UTILS.toPeb(1)

        await go(
            log(`\t -> Send test token : 1 SPIN`),
            _ => callContract(
                'transfer', 
                ['address', 'uint256'], 
                [to, amount], 
                Token
            )
        )
    })

    it('getBalance(SPIN) : 1', async () => {
        const tokenName = 'SPIN'

        assert.equal(
            UTILS.toPeb(1),
            await viewContract(
                METADATA.RevenueLedger, 
                'getBalance(string)', 
                [tokenName]
            )
        )
    })

    it('➡️  (Non-admin) sendToken(Deployer,1)', async () => {
        const tokenName = 'SPIN'
        const to = Deployer.address
        const amount = UTILS.toPeb(1)

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'sendToken', 
                    ['string', 'address', 'uint256'], 
                    [tokenName, to, amount], 
                    METADATA.RevenueLedger._address,
                    true
                ),
                evmError
            )
        )
    })

    it('➡️  sendToken(Deployer,1)', async () => {
        const tokenName = 'SPIN'
        const to = Deployer.address
        const amount = UTILS.toPeb(1)

        assert.equal(
            true,
            await go(
                callContract(
                    'sendToken', 
                    ['string', 'address', 'uint256'], 
                    [tokenName, to, amount], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('getBalance(SPIN) : 0', async () => {
        const tokenName = 'SPIN'

        assert.equal(
            0,
            await viewContract(
                METADATA.RevenueLedger, 
                'getBalance(string)', 
                [tokenName]
            )
        )
    })
})
