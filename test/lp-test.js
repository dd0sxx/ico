const { expect } = require("chai")
const {WETH_ABI} = require("../config")

describe("LP", function () {
  let ico, treasury, tomatoToken, alice, bob, charlotte

  beforeEach ( async () => {
    [a, b, c] = await ethers.getSigners()
    alice = a
    bob = b
    charlotte = c

    const Treasury = await ethers.getContractFactory("Treasury")
    treasury = await Treasury.deploy()
    await treasury.deployed()

    const TomatoLP = await ethers.getContractFactory("TomatoLP")
    tomatoLP = await TomatoLP.deploy()
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
    
    const WETH = await new ethers.Contract('0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2', WETH_ABI, alice)
  })

  async function ICOSellOut () {
        await ico.changePhase()
        await ico.changePhase()
        await alice.sendTransaction({from: alice.address, to: ico.address, value: ethers.utils.parseEther(`1000`)})
        await bob.sendTransaction({from: bob.address, to: ico.address, value: ethers.utils.parseEther(`1000`)})
        await charlotte.sendTransaction({from: charlotte.address, to: ico.address, value: ethers.utils.parseEther(`1000`)})
        await ico.redeem()
        await ico.connect(bob).redeem()
        let bal1 = await tomatoToken.balanceOf(alice.address);
        let bal2 = await tomatoToken.balanceOf(bob.address);
     
        expect(bal1).to.deep.equal(ethers.BigNumber.from(`${((25 * 0.98) * (10 ** 18))}`)) // mulitply number to decimal and take away 2%
        expect(bal2).to.deep.equal(ethers.BigNumber.from(`${((50 * 0.98) * (10 ** 18))}`))
        expect(ico.connect(charlotte).redeem()).to.be.revertedWith()
  }

  it('Mint an initial 150,000 TMTO supply (30k ETH times the ICO exchange rate) for your liquidity contract', async () => {
    let bal = await tomatoToken.balanceOf(tomatoLP.address)
    expect(bal.toString()).to.deep.equal('150000000000000000000000')
  })

  it('should have withdraw function to your ICO contract that moves the invested funds to your liquidity contract', async () => {
    
  })

})