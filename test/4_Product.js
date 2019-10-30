Object.assign(global, require('ffp-js'));
const assert = require('assert');

const {
    UTILS,
    viewContract,
    callContract
} = require('../utils/caver.js');
const { METADATA } = require('../utils/metadata');

describe('[Product] function check', () => {
    let initProductData = {}; //viewCount, purchaseCount
    let initUserPurchaseCount = 0; //userId : 99
    const callData = ["test", 1]

    before('test token send', async () => {
        initProductData = await viewContract( METADATA.Product, "getProductData(string,uint256)", callData)
        initUserPurchaseCount = await viewContract(METADATA.Product, 'getPurchaseCountByUser(string,uint256,uint256)', [...callData, 99])
    })

    it('➡️  addViewCount()', async () => {
        assert.equal(
            Number(initProductData.viewCount) + 1,
            await go(
                callContract(
                    'addViewCount', 
                    ["string","uint256","uint256"], 
                    [ ...callData, 10], 
                    METADATA.Product._address
                ),
                _ => viewContract( METADATA.Product,"getProductData(string,uint256)", callData),
                ({viewCount}) => viewCount
            )
        )
    })

    it('➡️  addPurchaseCount()', async () => {
        assert.equal(
            Number(initProductData.purchaseCount) + 5,
            await go(
                callContract(
                    'addPurchaseCount', 
                    ["string","uint256","uint256","uint256"], 
                    [ ...callData, 5, 10], 
                    METADATA.Product._address
                ),
                _ => viewContract( METADATA.Product,"getProductData(string,uint256)", callData),
                ({purchaseCount}) => purchaseCount
            )
        )
    })

    it('➡️  addPurchaseCount()', async () => {
        assert.equal(
            Number(initProductData.purchaseCount) + 7,
            await go(
                callContract(
                    'addPurchaseCount', 
                    ["string","uint256","uint256","uint256"], 
                    [ ...callData, 2, 99], 
                    METADATA.Product._address
                ),
                _ => viewContract( METADATA.Product,"getProductData(string,uint256)", callData),
                ({purchaseCount}) => purchaseCount
            )
        )
    })

    it('➡️  subPurchaseCount()', async () => {
        assert.equal(
            Number(initProductData.purchaseCount) + 2,
            await go(
                callContract(
                    'subPurchaseCount', 
                    ["string","uint256","uint256","uint256"], 
                    [ ...callData, 5, 10], 
                    METADATA.Product._address
                ),
                _ => viewContract( METADATA.Product,"getProductData(string,uint256)", callData),
                ({purchaseCount}) => purchaseCount
            )
        )
    })

    it('getPurchaseCountByUser()', async () => {
        assert.equal(
            Number(initUserPurchaseCount) + 2,
            await viewContract(METADATA.Product, 'getPurchaseCountByUser(string,uint256,uint256)', [...callData, 99])
        )
    })

    //event catch - view, purchase

    it('catch view event', async () => {
        assert.equal(
            true,
            await go(
                UTILS.getPastEvent(
                    METADATA.Product, 
                    "ViewProduct", 
                    {
                        productId : 1,
                        memberNo : 10
                    },
                    10868210
                ),
                a => a.length > 0
            )
        )
    })

    it('catch purchase event', async () => {
        assert.equal(
            true,
            await go(
                UTILS.getPastEvent(
                    METADATA.Product, 
                    "PurchaseAdd", 
                    {
                        productId : 1,
                        memberNo : 10
                    },
                    10868210
                ),
                a => a.length > 0
            )
        )
    })
})