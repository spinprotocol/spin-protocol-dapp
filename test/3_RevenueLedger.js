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

    const _spinAmount = 2000
    const _marketPrice = 1550
    const _rounding = 2

    before('test token send', async () => {
        const to = METADATA.RevenueLedger._address

        await go(
            viewContract(
                METADATA.RevenueLedger,
                'revenueSpin(uint256,uint256,uint256)',
                [_spinAmount,_marketPrice,_rounding]
            ),
            amount => UTILS.toPeb(String(UTILS.fromPeb(amount) * 2)),
            amount => (log(`\t -> Send test token : ${ UTILS.fromPeb(amount) } SPIN`), amount),
            amount => callContract(
                'transfer', 
                ['address', 'uint256'],
                [to, amount], 
                Token
            )
        )
    })

    it('➡️  (Non-admin) createRevenueLedger()', () => {
        const revenueLedgerId = 1
        const campaignId = 1
        const influencerId = 1
        const salesAmount = 1
        const salesPrice = 1
        const profit = 1
        const revenueRatio = 1
        const spinRatio = 1
        const fiatRatio = 1

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'createRevenueLedger', 
                    ['uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256'], 
                    [revenueLedgerId, campaignId, influencerId, salesAmount, salesPrice, profit, revenueRatio, spinRatio, fiatRatio], 
                    METADATA.RevenueLedger._address,
                    true
                ),
                evmError
            )
        )
    })

    it('➡️  createRevenueLedger()', async () => {
        const revenueLedgerId = 1
        const campaignId = 1
        const influencerId = 1
        const salesAmount = 1
        const salesPrice = 1
        const profit = 1
        const revenueRatio = 1
        const spinRatio = 1
        const fiatRatio = 1

        assert.equal(
            true,
            await go(
                callContract(
                    'createRevenueLedger', 
                    ['uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256', 'uint256','uint256'], 
                    [revenueLedgerId, campaignId, influencerId, salesAmount, salesPrice, profit, revenueRatio, spinRatio, fiatRatio], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('getRevenueLedger()', async () => {
        const revenueLedgerId = 1

        assert.equal(
            false,
            await go(
                viewContract(METADATA.RevenueLedger, 'getRevenueLedger(uint256)', [revenueLedgerId]),
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

    it(`revenueSpin(${ [_spinAmount,_marketPrice,_rounding] })`, async () => {
        const expectedReturn = (_spinAmount/(_marketPrice/100)).toFixed(_rounding) 

        assert.equal(
            UTILS.toPeb(expectedReturn),
            await viewContract(
                METADATA.RevenueLedger, 
                'revenueSpin(uint256,uint256,uint256)', 
                [_spinAmount, _marketPrice, _rounding]
            )
        )
    })

    it('➡️  (Non-admin) revenueShare()', () => {
        const _revenueLedgerId = 1
        const _to = Deployer.address

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'revenueShare', 
                    ['uint256', 'address', 'uint256', 'uint256', 'uint256'], 
                    [_revenueLedgerId, _to, _spinAmount, _marketPrice, _rounding], 
                    METADATA.RevenueLedger._address,
                    true
                ),
                evmError
            )
        )
    })

    it('➡️  revenueShare()', async () => {
        const _revenueLedgerId = 1
        const _to = Deployer.address

        assert.equal(
            true,
            await go(
                callContract(
                    'revenueShare', 
                    ['uint256', 'address', 'uint256', 'uint256', 'uint256'], 
                    [_revenueLedgerId, _to, _spinAmount, _marketPrice, _rounding], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Already share) revenueShare()', () => {
        const _revenueLedgerId = 1
        const _to = Deployer.address

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'revenueShare', 
                    ['uint256', 'address', 'uint256', 'uint256', 'uint256'], 
                    [_revenueLedgerId, _to, _spinAmount, _marketPrice, _rounding], 
                    METADATA.RevenueLedger._address
                ),
                evmError
            )
        )
    })

    it('➡️  updateIsAccount()', async () => {
        const revenueLedgerId = 1
        const state = false

        assert.equal(
            true,
            await go(
                callContract(
                    'updateIsAccount', 
                    ['uint256', 'bool'], 
                    [revenueLedgerId, state], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  Re revenueShare()', async () => {
        const _revenueLedgerId = 1
        const _to = Deployer.address

        assert.equal(
            true,
            await go(
                callContract(
                    'revenueShare', 
                    ['uint256', 'address', 'uint256', 'uint256', 'uint256'], 
                    [_revenueLedgerId, _to, _spinAmount, _marketPrice, _rounding], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  deleteRevenueLedger()', async () => {
        const _revenueLedgerId = 1

        assert.equal(
            true,
            await go(
                callContract(
                    'deleteRevenueLedger', 
                    ['uint256'], 
                    [_revenueLedgerId], 
                    METADATA.RevenueLedger._address
                ),
                a => a.status
            )
        )
    })

    after('test token send', async () => {
        const tokenName = 'SPIN'
        const to = Deployer.address

        await go(
            viewContract(
                METADATA.RevenueLedger,
                'getBalance(string)',
                ['SPIN']
            ),
            amount => (log(`\t -> Send remaining balance token : ${ UTILS.fromPeb(amount) } SPIN`), amount),
            amount => amount === 0 ? 
            null
            : callContract(
                'sendToken', 
                ['string', 'address', 'uint256'],
                [tokenName, to, amount], 
                METADATA.RevenueLedger._address
            )
        )
    })

})