const { expect } = require("chai")

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

    const TomatoToken = await ethers.getContractFactory("TomatoToken")
    tomatoToken = await TomatoToken.deploy(treasury.address)
    await tomatoToken.deployed()

    const ICO = await ethers.getContractFactory("ICO")
    ico = await ICO.deploy(tomatoToken.address)
    await ico.deployed()
    
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
    
})
