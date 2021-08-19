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


    
})
