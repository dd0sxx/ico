const { expect } = require("chai")
const {WETH_ABI} = require("../config")

describe("ICO", function () {
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
  
  it('expect contracts to deploy', async () => {
    expect(ico).to.not.equal(undefined)
    expect(treasury).to.not.equal(undefined)
    expect(tomatoToken).to.not.equal(undefined)
  })

  it('starts in seed phase by default', async () => {
    expect(await ico.phase()).to.equal(0)
  })

  it('should allow the owner to manually change the phase', async () => {
    expect(await ico.phase()).to.equal(0)
    await ico.changePhase()
    expect(await ico.phase()).to.equal(1)
    await ico.changePhase()
    expect(await ico.phase()).to.equal(2)
    expect(ico.changePhase()).to.be.revertedWith("ICO is in phase open")
  })

  it('should allow owner to pause and unpause the contract', async () => {
    expect(await ico.paused()).to.equal(false)
    await ico.togglePause(true)
    expect(await ico.paused()).to.equal(true)
    await ico.togglePause(false)
    expect(await ico.paused()).to.equal(false)
  })

  it('should allow owner to add an array of addresses to whitelist', async () => {
    await ico.addToWhitelist([alice.address, bob.address])
    expect(await ico.whitelist(alice.address)).to.deep.equal(true)
    expect(await ico.whitelist(bob.address)).to.deep.equal(true)
    expect(await ico.whitelist(charlotte.address)).to.deep.equal(false)
  })

  it('should not allow whitelisted address after the seed phase is over', async () => {
    await ico.changePhase()
    expect(ico.addToWhitelist([alice.address, bob.address])).to.be.revertedWith("whitelist is irrelevant after seed phase")
  })

  it('should not allow users to withdraw funds in the seed or general phase', async () => {
      expect(ico.redeem()).to.be.revertedWith("cannot withdraw until phase open")
      await ico.changePhase()
      expect(ico.redeem()).to.be.revertedWith("cannot withdraw until phase open")
  })

  it('should allow users to contribute funds if they are whitelisted', async () => {
    await ico.addToWhitelist([alice.address, bob.address])
    await alice.sendTransaction({from: alice.address, to: ico.address, value: ethers.utils.parseEther(`5`)})
    await bob.sendTransaction({from: bob.address, to: ico.address, value: ethers.utils.parseEther(`10`)})
    expect(await ico.balances(alice.address)).to.deep.equal(ethers.utils.parseEther(`5`))
    expect(await ico.balances(bob.address)).to.deep.equal(ethers.utils.parseEther(`10`))
    expect(charlotte.sendTransaction({from: charlotte.address, to: ico.address, value: ethers.utils.parseEther(`10`)})).to.be.revertedWith("address not whitelisted for seed sale")
  })

  it('should allow anyone to contribute during general phase', async () => {
      await ico.changePhase()
      await alice.sendTransaction({from: alice.address, to: ico.address, value: ethers.utils.parseEther(`5`)})
      await bob.sendTransaction({from: bob.address, to: ico.address, value: ethers.utils.parseEther(`10`)})
      await charlotte.sendTransaction({from: charlotte.address, to: ico.address, value: ethers.utils.parseEther(`10`)})
      
  })

  it('should allow users to redeem tokens', async () => {
    await ico.changePhase()
    await alice.sendTransaction({from: alice.address, to: ico.address, value: ethers.utils.parseEther(`5`)})
    await bob.sendTransaction({from: bob.address, to: ico.address, value: ethers.utils.parseEther(`10`)})
    await ico.changePhase()
    let initBal1 = await tomatoToken.balanceOf(alice.address);
    let initBal2 = await tomatoToken.balanceOf(bob.address);
    let initBal3 = await tomatoToken.balanceOf(charlotte.address);
    expect(initBal1).to.deep.equal(0)
    expect(initBal2).to.deep.equal(0)
    expect(initBal3).to.deep.equal(0)
    await ico.redeem()
    await ico.connect(bob).redeem()
    let bal1 = await tomatoToken.balanceOf(alice.address);
    let bal2 = await tomatoToken.balanceOf(bob.address);
 
    expect(bal1).to.deep.equal(ethers.BigNumber.from(`${((25 * 0.98) * (10 ** 18))}`)) // mulitply number to decimal and take away 2%
    expect(bal2).to.deep.equal(ethers.BigNumber.from(`${((50 * 0.98) * (10 ** 18))}`))
    expect(ico.connect(charlotte).redeem()).to.be.revertedWith()
  })
    
})
