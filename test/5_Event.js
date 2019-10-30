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

describe('[Event] function check', () => {

    before('test token send', async () => {
        await go(
            log(`\t -> Send test token : 10 SPIN`),
            _ => callContract(
                'transfer', 
                ['address', 'uint256'],
                [METADATA.Event._address, UTILS.toPeb(10)], 
                Token
            )
        )
    })

    it('➡️  pushHistory()', async () => {
        const sendData = [
            [1,"test1",Deployer.address,1], 
            [1,"test1",Deployer.address,1], 
            [1,"test2",Deployer.address,3],
            [1,"test2",Deployer.address,3]]

        assert.equal(
            true,
            await go(
                sendData,
                map(data => go(
                    callContract(
                        'pushHistory', 
                        ["uint256","string","address","uint256"], 
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
        assert.equal(
            2,
            await viewContract(METADATA.Event, 'getEventBenefitCount(uint256,string)', [1,"test2"]),
        )
    })

    it('➡️  removeHistory()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'removeHistory', 
                    ["uint256","string"], 
                    [1,"test2"],
                    METADATA.Event._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Non-admin) sendReward()', () => 
        evmError (() => callContract(
                'sendReward', 
                ["uint256","string[]","address[]","uint256[]"], 
                [1,["test1","test2","test1"],[Deployer.address,Deployer.address,Deployer.address],[1,1,8]], 
                METADATA.Event._address,
                true
        ))
    )

    it('➡️  sendReward()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'sendReward', 
                    ["uint256","string[]","address[]","uint256[]"], 
                    [1,["test1","test2","test1"],[Deployer.address,Deployer.address,Deployer.address],[1,7,1]], 
                    METADATA.Event._address
                ),
                a => a.status
            )
        )
    })
        
    it('➡️  (Non-history) sendReward()', () => 
        evmError (() => callContract(
                'sendReward', 
                ["uint256","string[]","address[]","uint256[]"], 
                [1,["test2"],[Deployer.address],[1]], 
                METADATA.Event._address,
                true
        ))
    )

    after('test token send', async () => {
        await go(
            viewContract(
                METADATA.Event,
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
                METADATA.Event._address
            )
        )
    })
})