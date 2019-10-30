Object.assign(global, require('ffp-js'));
const assert = require('assert');

const {
    Deployer,
    Token,
    UTILS,
    viewContract,
    callContract
} = require('../utils/caver.js');
const { METADATA } = require('../utils/metadata');
const { evmError } = require('../utils/errorFilter.js')

describe('[RevenueLedger] function check', () => {

    const revenueData = [2000, 1550, 2]

    before('test token send', async () => {
        await go(
            viewContract(
                METADATA.RevenueLedger,
                "revenueSpin(uint256,uint256,uint256)",
                revenueData
            ),
            spin => UTILS.toPeb(String(UTILS.fromPeb(spin) * 2)),
            spin => (log(`\t -> Send test token : ${ UTILS.fromPeb(spin) } SPIN`), spin),
            spin => callContract(
                'transfer', 
                ['address', 'uint256'],
                [METADATA.RevenueLedger._address, spin], 
                Token
            )
        )
    })

    it('➡️  (Non-admin) createRevenueLedger()', () => 
        evmError (() => callContract(
                'createRevenueLedger', 
                ["uint256","uint256","uint256","uint256","uint256","uint256","uint256","uint256","uint256"], 
                [1,1,1,1,1,1,1,1,1], 
                METADATA.RevenueLedger._address,
                true
        ))
    )

    it('➡️  createRevenueLedger()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'createRevenueLedger', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256","uint256","uint256","uint256"], 
                    [1,1,1,1,1,1,1,1,1], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('getRevenueLedger()', async () => {
        assert.equal(
            false,
            await go(
                viewContract(METADATA.RevenueLedger, 'getRevenueLedger(uint256)', [1]),
                ({ isAccount }) => isAccount
            )
        )
    })

    it('getRevenueLedgerList()', async () => {
        assert.equal(
            true,
            await go(
                viewContract(METADATA.RevenueLedger, 'getRevenueLedgerList()', []),
                list => list.length > 0
            )
        )
    })

    it(`revenueSpin(${ revenueData })`, async () => {
        const expectedReturn = (revenueData[0]/(revenueData[1]/100)).toFixed(revenueData[2]) 

        assert.equal(
            UTILS.toPeb(expectedReturn),
            await viewContract(METADATA.RevenueLedger, 'revenueSpin(uint256,uint256,uint256)', revenueData)
        )
    })

    it('➡️  (Non-admin) revenueShare()', () => 
        evmError (() => callContract(
                'revenueShare', 
                ["uint256","address","uint256","uint256","uint256"], 
                [1,"0x2686b14a063eb9fd99e236168f79b7510e706fc6",...revenueData], 
                METADATA.RevenueLedger._address,
                true
        ))
    )

    it('➡️  revenueShare()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'revenueShare', 
                    ["uint256","address","uint256","uint256","uint256"], 
                    [1, Deployer.address, ...revenueData], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Already share) revenueShare()', () => 
        evmError (() => callContract(
                'revenueShare', 
                ["uint256","address","uint256","uint256","uint256"], 
                [1,"0x2686b14a063eb9fd99e236168f79b7510e706fc6",...revenueData], 
                METADATA.RevenueLedger._address
        ))
    )

    it('➡️  updateIsAccount()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'updateIsAccount', 
                    ["uint256","bool"], 
                    [1, false], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  Re revenueShare()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'revenueShare', 
                    ["uint256","address","uint256","uint256","uint256"], 
                    [1, Deployer.address, ...revenueData], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  deleteRevenueLedger()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'deleteRevenueLedger', 
                    ["uint256"], 
                    [1], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    after('test token send', async () => {
        await go(
            viewContract(
                METADATA.RevenueLedger,
                "getBalance(string)",
                ["SPIN"]
            ),
            spin => (log(`\t -> Send remaining balance token : ${ UTILS.fromPeb(spin) } SPIN`), spin),
            spin => spin === 0 ? 
            null
            : callContract(
                'sendToken', 
                ['string', 'address', 'uint256'],
                ["SPIN", Deployer.address, spin], 
                METADATA.RevenueLedger._address
            )
        )
    })

})