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
        const auth = "influencer"
        const account = Test.address

        await callContract(
                'addAuth', 
                ['string', 'address'], 
                [auth, account], 
                METADATA.AuthStorage._address
            )
    })

    it('➡️  (Non-admin) createCampaign()', async () => {
        const campaignId = 1
        const productId = 1
        const revenueRatio = 1
        const totalSupply = 1
        const startAt = parseInt(new Date().getTime()/1000) + 10000
        const endAt = parseInt(new Date().getTime()/1000) + 20000

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'createCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"], 
                    [campaignId, productId, revenueRatio, totalSupply, startAt, endAt], 
                    METADATA.Campaign._address,
                    true
                ),
                evmError
            )
        )
    })

    it('➡️  createCampaign()', async () => {
        const campaignId = 1
        const productId = 1
        const revenueRatio = 1
        const totalSupply = 1
        const startAt = parseInt(new Date().getTime()/1000) + 10000
        const endAt = parseInt(new Date().getTime()/1000) + 20000

        assert.equal(
            true,
            await go(
                callContract(
                    'createCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"], 
                    [campaignId, productId, revenueRatio, totalSupply, startAt, endAt], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Non-admin) deleteCampaign()', async () => {
        const campaignId = 1

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'deleteCampaign', 
                    ["uint256"], 
                    [campaignId], 
                    METADATA.Campaign._address,
                    true
                ),
                evmError
            )
        )
    })

    it('➡️  deleteCampaign()', async () => {
        const campaignId = 1

        assert.equal(
            true,
            await go(
                callContract(
                    'deleteCampaign', 
                    ["uint256"], 
                    [campaignId], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  createCampaign()', async () => {
        const campaignId = 1
        const productId = 1
        const revenueRatio = 1
        const totalSupply = 1
        const startAt = parseInt(new Date().getTime()/1000) + 10000
        const endAt = parseInt(new Date().getTime()/1000) + 20000

        assert.equal(
            true,
            await go(
                callContract(
                    'createCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"], 
                    [campaignId, productId, revenueRatio, totalSupply, startAt, endAt], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Overlap) createCampaign()', async () => {
        const campaignId = 1
        const productId = 1
        const revenueRatio = 1
        const totalSupply = 1
        const startAt = parseInt(new Date().getTime()/1000) + 10000
        const endAt = parseInt(new Date().getTime()/1000) + 20000
        
        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'createCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"], 
                    [campaignId, productId, revenueRatio, totalSupply, startAt, endAt], 
                    METADATA.Campaign._address
                ),
                evmError
            )
        )
    })

    it('➡️  attendCampaign()', async () => {
        const campaignId = 1
        const influencerId = 100

        assert.equal(
            true,
            await go(
                callContract(
                    'attendCampaign', 
                    ["uint256","uint256"], 
                    [campaignId,influencerId], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('getCampaign()', async () => {
        const campaignId = 1

        assert.equal(
            true,
            await go(
                viewContract(METADATA.Campaign,'getCampaign(uint256)',[campaignId]),
                ({ appliedInfluencerList }) => appliedInfluencerList[0] === "100"
            )
        )
    })

    it('➡️  cancelCampaign()', async () => {
        const campaignId = 1
        const influencerId = 100

        assert.equal(
            true,
            await go(
                callContract(
                    'cancelCampaign', 
                    ["uint256","uint256"], 
                    [campaignId,influencerId], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Non-admin) updateCampaign()', async () => {
        const campaignId = 1
        const productId = 1
        const revenueRatio = 1
        const totalSupply = 1
        const startAt = parseInt(new Date().getTime()/1000) + 5
        const endAt = parseInt(new Date().getTime()/1000) + 20000

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'updateCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"], 
                    [campaignId, productId, revenueRatio, totalSupply, startAt, endAt], 
                    METADATA.Campaign._address,
                    true
                ),
                evmError
            )
        )
    })

    it('➡️  updateCampaign()', async () => {
        const campaignId = 1
        const productId = 1
        const revenueRatio = 1
        const totalSupply = 1
        const startAt = parseInt(new Date().getTime()/1000) + 3
        const endAt = parseInt(new Date().getTime()/1000) + 20000  

        assert.equal(
            true,
            await go(
                callContract(
                    'updateCampaign', 
                    ["uint256","uint256","uint256","uint256","uint256","uint256"],
                    [campaignId, productId, revenueRatio, totalSupply, startAt, endAt], 
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    it('➡️  (Already start campaign) attendCampaign()', async () => {
        const campaignId = 1
        const influencerId = 100

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'attendCampaign', 
                    ["uint256","uint256"], 
                    [campaignId,influencerId], 
                    METADATA.Campaign._address,
                    true
                ),
                evmError
            )
        )
    })

    it('➡️  (Already start campaign) deleteCampaign()', async () => {
        const campaignId = 1

        assert.equal(
            'evm: execution reverted',
            await go(
                () => callContract(
                    'deleteCampaign', 
                    ["uint256"], 
                    [campaignId], 
                    METADATA.Campaign._address
                ),
                evmError
            )
        )
    })

    it('➡️  updateSaleEnd()', async () => {
        const campaignId = 1
        const endAt = parseInt(new Date().getTime()/1000) + 5
        
        assert.equal(
            true,
            await go(
                callContract(
                    'updateSaleEnd', 
                    ["uint256","uint256"],
                    [campaignId, endAt],
                    METADATA.Campaign._address
                ),
                a => a.status
            )
        )
    })

    after('Test influencer remove auth', async () => {
        const auth = "influencer"
        const account = Test.address

        await callContract(
                'removeAuth', 
                ['string', 'address'], 
                [auth, account], 
                METADATA.AuthStorage._address
            )
    })

})