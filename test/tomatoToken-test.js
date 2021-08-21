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
    ico = await ICO.deploy(treasury.address)
    await ico.deployed()

    treasury.setTokenContract(tomatoToken.address)
    treasury.setICOContract(ico.address)
    
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

  it('should allow users to transfer tokens', async () => {
    await ico.changePhase()
    await alice.sendTransaction({from: alice.address, to: ico.address, value: ethers.utils.parseEther(`5`)})
    await bob.sendTransaction({from: bob.address, to: ico.address, value: ethers.utils.parseEther(`10`)})
    await ico.changePhase()
    await ico.redeem()
    await ico.connect(bob).redeem()
    await tomatoToken.transfer(charlotte.address, 10)
    await tomatoToken.connect(bob).transfer(charlotte.address, 30)
    let bal1 = await tomatoToken.balanceOf(alice.address)
    let bal2 = await tomatoToken.balanceOf(bob.address)
    let bal3 = await tomatoToken.balanceOf(charlotte.address)
    expect(bal1).to.deep.equal(15)
    expect(bal2).to.deep.equal(20)
    expect(bal3).to.deep.equal(40)
  })

  it('should allow users to transfer a decimal amount of tokens', async () => {
    await ico.changePhase()
    await alice.sendTransaction({from: alice.address, to: ico.address, value: ethers.utils.parseEther(`5`)})
    await bob.sendTransaction({from: bob.address, to: ico.address, value: ethers.utils.parseEther(`10`)})
    await ico.changePhase()
    await ico.redeem()
    await ico.connect(bob).redeem()
    await tomatoToken.transfer(charlotte.address, 1.5)
    await tomatoToken.connect(bob).transfer(charlotte.address, 4.25)
    let bal1 = await tomatoToken.balanceOf(alice.address)
    let bal2 = await tomatoToken.balanceOf(bob.address)
    let bal3 = await tomatoToken.balanceOf(charlotte.address)
    expect(bal1).to.deep.equal(23.5)
    expect(bal2).to.deep.equal(45.75)
    expect(bal3).to.deep.equal(5.75)
  })
    
})
