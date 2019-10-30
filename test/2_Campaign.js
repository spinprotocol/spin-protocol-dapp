Object.assign(global, require('ffp-js'));
const assert = require('assert');

const {
    Test,
    viewContract,
    callContract
} = require('../utils/caver.js');

const { evmError } = require('../utils/errorFilter.js')
const { METADATA } = require('../utils/metadata.js');

describe('[Campaign] function check', () => {

    before('Test influencer add auth', async () => {
        await callContract(
                'addAuth', 
                ['string', 'address'], 
                ["influencer", Test.address], 
                METADATA.AuthStorage._address
            )
    })

    it('➡️  (Non-admin) createCampaign()', () => 
        evmError (() => callContract(
                'createCampaign', 
                ["uint256","uint256","uint256","uint256","uint256","uint256"], 
                [1,1,1,1, parseInt(new Date().getTime()/1000) + 10000,  parseInt(new Date().getTime()/1000) + 20000], 
                METADATA.Campaign._address,
                true
        ))
    )

    it('➡️  createCampaign()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'createCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"], 
                    [1,1,1,1, parseInt(new Date().getTime()/1000) + 10000,  parseInt(new Date().getTime()/1000) + 20000], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Non-admin) deleteCampaign()', () => 
        evmError (() => callContract(
                'deleteCampaign', 
                ["uint256"], 
                [1], 
                METADATA.Campaign._address,
                true
        ))
    )

    it('➡️  deleteCampaign()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'deleteCampaign', 
                    ["uint256"], 
                    [1], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  createCampaign()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'createCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"], 
                    [1,1,1,1, parseInt(new Date().getTime()/1000) + 10000,  parseInt(new Date().getTime()/1000) + 20000], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Overlap) createCampaign()', async () => 
        evmError(() => callContract(
            'createCampaign', 
            ["uint256","uint256","uint256","uint256","uint256","uint256"], 
            [1,1,1,1, parseInt(new Date().getTime()/1000) + 10000,  parseInt(new Date().getTime()/1000) + 20000], 
            METADATA.Campaign._address
        ))
    )

    it('➡️  attendCampaign()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'attendCampaign', 
                    ["uint256","uint256"], 
                    [1,100], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('getCampaign()', async () => {
        assert.equal(
            true,
            await go(
                viewContract(METADATA.Campaign,'getCampaign(uint256)',[1]),
                ({ appliedInfluencerList }) => appliedInfluencerList[0] === "100"
            )
        )
    })

    it('➡️  cancelCampaign()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'cancelCampaign', 
                    ["uint256","uint256"], 
                    [1,100], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Non-admin) updateCampaign()', async () => 
        evmError(() => callContract(
            'updateCampaign', 
            ["uint256","uint256","uint256","uint256","uint256","uint256"], 
            [1,1,1,1, parseInt(new Date().getTime()/1000) + 5,  parseInt(new Date().getTime()/1000) + 20000], 
            METADATA.Campaign._address,
            true
        ))
    )

    it('➡️  updateCampaign()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'updateCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"],
                    [1,1,1,1, parseInt(new Date().getTime()/1000) + 3,  parseInt(new Date().getTime()/1000) + 20000],
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Already start campaign) attendCampaign()', async () => 
        evmError(() => callContract(
            'attendCampaign', 
            ["uint256","uint256"], 
            [1,100], 
            METADATA.Campaign._address,
            true
        ))
    )

    it('➡️  (Already start campaign) deleteCampaign()', async () => 
        evmError(() => callContract(
            'deleteCampaign', 
            ["uint256"], 
            [1], 
            METADATA.Campaign._address
        ))
    )


    it('➡️  updateSaleEnd()', async () => {
        assert.equal(
            true,
            await go(
                callContract(
                    'updateSaleEnd', 
                    ["uint256","uint256"],
                    [1, parseInt(new Date().getTime()/1000) + 5],
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    after('Test influencer remove auth', async () => {
        await callContract(
                'removeAuth', 
                ['string', 'address'], 
                ["influencer", Test.address], 
                METADATA.AuthStorage._address
            )
    })

})