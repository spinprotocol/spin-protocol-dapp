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

describe('[Event] function check', () => {

    before('test token send', async () => {
        const to = METADATA.Event._address
        const amount = UTILS.toPeb(10)

        await go(
            log(`\t -> Send test token : 10 SPIN`),
            _ => callContract(
                'transfer', 
                ['address', 'uint256'],
                [to, amount], 
                Token
            )
        )
    })

    it('➡️  pushHistory()', async () => {
        const sendData = [
            [1, 'test1', Deployer.address, 1], 
            [1, 'test1', Deployer.address, 1], 
            [1, 'test2', Deployer.address, 3],
            [1, 'test2', Deployer.address, 3]]

        assert.equal(
            true,
            await go(
                sendData,
                map(data => go(
                    callContract(
                        'pushHistory', 
                        ['uint256', 'string', 'address', 'uint256'], 
                        data, 
                        METADATA.Event._address
                    ),
                    a => a.status
                )),
                filter(a => !a),
                a => a.length === 0
            )
        )
    })

    it('getEventBenefitCount()', async () => {
        const eventId = 1
        const userId = 'test2'

        assert.equal(
            2,
            await viewContract(METADATA.Event, 'getEventBenefitCount(uint256,string)', [eventId, userId]),
        )
    })

    it('➡️  removeHistory()', async () => {
        const eventId = 1
        const userId = 'test2'

        assert.equal(
            true,
            await go(
                callContract(
                    'removeHistory', 
                    ['uint256', 'string'], 
                    [eventId, userId],
                    METADATA.Event._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Non-admin) sendReward()', () => {
        const eventId = 1
        const userIds = ['test1', 'test2', 'test1']
        const userWallets = [Deployer.address, Deployer.address, Deployer.address]
        const rewardAmounts = [1, 1, 8]

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'sendReward', 
                    ['uint256', 'string[]', 'address[]', 'uint256[]'], 
                    [eventId, userIds, userWallets, rewardAmounts], 
                    METADATA.Event._address,
                    true
            ),
                evmError
            )
        )
    })

    it('➡️  sendReward()', async () => {
        const eventId = 1
        const userIds = ['test1', 'test2', 'test1']
        const userWallets = [Deployer.address,Deployer.address,Deployer.address]
        const rewardAmounts = [1,7,1]

        assert.equal(
            true,
            await go(
                callContract(
                    'sendReward', 
                    ['uint256', 'string[]', 'address[]', 'uint256[]'], 
                    [eventId, userIds, userWallets, rewardAmounts], 
                    METADATA.Event._address
                ),
                a => a.status
            )
        )
    })
        
    it('➡️  (Non-history) sendReward()', () => {
        const eventId = 1
        const userIds = ['test2']
        const userWallets = [Deployer.address]
        const rewardAmounts = [1]
        
        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'sendReward', 
                    ['uint256', 'string[]', 'address[]', 'uint256[]'], 
                    [eventId, userIds, userWallets, rewardAmounts], 
                    METADATA.Event._address
            ),
                evmError
            )
        )
    })

    after('test token send', async () => {
        const tokenName = 'SPIN'
        const to = Deployer.address

        await go(
            viewContract(
                METADATA.Event,
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
                METADATA.Event._address
            )
        )
    })
})