const { expect } = require("chai")

describe("TomatoToken", function () {
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

  it('mints 500000 tomato coins to treasury', async () => {
    expect(await tomatoToken.balanceOf(treasury.address)).to.equal("500000")
  })

  it('tax is enabled by default', async () => {
    expect(await tomatoToken.tax()).to.equal(true)
  })

  it('transfer does not allow an amount of 0', async () => {
    expect(tomatoToken.transfer(bob, 0)).to.be.revertedWith('amount must be greater than 0')
  })

  // TODO test transfer function

  //
    
})
