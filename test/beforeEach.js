const {WETH_ABI} = require("../config")

module.exports = async () => {
    [a, b, c] = await ethers.getSigners()
    alice = a
    bob = b
    charlotte = c

    const Treasury = await ethers.getContractFactory("Treasury")
    treasury = await Treasury.deploy()
    await treasury.deployed()

    const TomatoLP = await ethers.getContractFactory("TomatoLP")
    tomatoLP = await TomatoLP.deploy(treasury.address)
    await tomatoLP.deployed()

    const TomatoToken = await ethers.getContractFactory("TomatoToken")
    tomatoToken = await TomatoToken.deploy(treasury.address, tomatoLP.address)
    await tomatoToken.deployed()

    tomatoLP.setTMTOAddress(tomatoToken.address)

    const ICO = await ethers.getContractFactory("ICO")
    ico = await ICO.deploy(treasury.address)
    await ico.deployed()

    treasury.setTokenContract(tomatoToken.address)
    treasury.setICOContract(ico.address)

    const LPToken = await ethers.getContractFactory("LPToken")
    lpToken = await LPToken.deploy(tomatoLP.address)
    await lpToken.deployed()

    tomatoLP.setLPTokenAddress(lpToken.address)
    
    WETH = await new ethers.Contract('0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2', WETH_ABI, alice)
  }