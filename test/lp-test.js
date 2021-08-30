const { expect } = require("chai")
const {WETH_ABI} = require("../config")

describe("LP", function () {
  let ico, treasury, tomatoToken, WETH, tomatoLP, lpToken, alice, bob, charlotte

  beforeEach ( async () => {
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
  })

  async function ICOSellOutAndTransfer () {
      await ico.changePhase()
      await ico.changePhase()
      await alice.sendTransaction({from: alice.address, to: ico.address, value: ethers.utils.parseEther(`1000`)})
      await bob.sendTransaction({from: bob.address, to: ico.address, value: ethers.utils.parseEther(`1000`)})
      await charlotte.sendTransaction({from: charlotte.address, to: ico.address, value: ethers.utils.parseEther(`1000`)})
      await ico.sendEther(tomatoLP.address, ethers.utils.parseEther(`3000`));
      await tomatoLP.wrapEther(ethers.utils.parseEther(`3000`));
  }

  it('Mint an initial 150,000 TMTO supply (30k ETH times the ICO exchange rate) for your liquidity contract', async () => {
    let bal = await tomatoToken.balanceOf(tomatoLP.address)
    expect(bal.toString()).to.deep.equal('150000000000000000000000')
  })

  it('should have withdraw function to your ICO contract that moves the invested funds to your liquidity contract and wraps the ether to WETH', async () => {
    await ICOSellOutAndTransfer()
    lpBal = await WETH.balanceOf(tomatoLP.address)
    expect(lpBal.toString()).to.deep.equal(ethers.utils.parseEther(`3000`))
  })

  it('should mint LP tokens for liquidity deposits', async () => {
    await ICOSellOutAndTransfer()
    let amount0 = await tomatoToken.balanceOf(tomatoLP.address)
    let amount1 = await WETH.balanceOf(tomatoLP.address)
    await tomatoLP.initialize(amount0.toString(), amount1.toString())
    let lpBal = await lpToken.balanceOf(tomatoLP.address)
    expect(lpBal.toString()).to.deep.equal()
  })


    // Burns LP tokens to return liquidity to holder
    // Accepts trades with a 1% fee

})