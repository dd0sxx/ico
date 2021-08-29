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
    ico = await ICO.deploy(treasury.address)
    await ico.deployed()

    treasury.setTokenContract(tomatoToken.address)
    treasury.setICOContract(ico.address)
    
  })

})