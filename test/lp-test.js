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
      await ico.connect(alice).redeem()
      await ico.connect(bob).redeem()
      await ico.connect(charlotte).redeem()
  }

  async function approve () {
    await tomatoToken.connect(alice).approve(tomatoLP.address, '500000000000000000000000')
    await tomatoToken.connect(bob).approve(tomatoLP.address, '500000000000000000000000')
    await tomatoToken.connect(charlotte).approve(tomatoLP.address, '500000000000000000000000')
    
    await lpToken.connect(alice).approve(tomatoLP.address, '500000000000000000000000')
    await lpToken.connect(bob).approve(tomatoLP.address, '500000000000000000000000')
    await lpToken.connect(charlotte).approve(tomatoLP.address, '500000000000000000000000')

    await WETH.connect(alice).approve(tomatoLP.address, '500000000000000000000000')
    await WETH.connect(bob).approve(tomatoLP.address, '500000000000000000000000')
    await WETH.connect(charlotte).approve(tomatoLP.address, '500000000000000000000000')
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

  it('should mint first LP tokens for lpcontract', async () => {
    await ICOSellOutAndTransfer()
    let amount0 = await tomatoToken.balanceOf(tomatoLP.address)
    let amount1 = await WETH.balanceOf(tomatoLP.address)
    await tomatoLP.initialize(amount0.toString(), amount1.toString())
    let lpBal = await lpToken.balanceOf(tomatoLP.address)
    expect(lpBal.toString()).to.deep.equal('21213203435596425732025') //init balance
  })

  it('should mint LP tokens for liquidity providers', async () => {
    await ICOSellOutAndTransfer()
    let amount0 = await tomatoToken.balanceOf(tomatoLP.address)
    let amount1 = await WETH.balanceOf(tomatoLP.address)
    await tomatoLP.initialize(amount0.toString(), amount1.toString())
    let lpBal = await lpToken.balanceOf(tomatoLP.address)
    expect(lpBal.toString()).to.deep.equal('21213203435596425732025') //end of init 

    await bob.sendTransaction({from: bob.address, to: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', value: ethers.utils.parseEther(`100`)})
    await charlotte.sendTransaction({from: charlotte.address, to: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', value: ethers.utils.parseEther(`300`)})

    await approve()

    await tomatoLP.connect(bob).provideLiquidity(ethers.utils.parseEther(`5`), ethers.utils.parseEther(`1`))
    await tomatoLP.connect(charlotte).provideLiquidity(ethers.utils.parseEther(`5`), ethers.utils.parseEther(`1`))

    let bobLPBal = await lpToken.balanceOf(bob.address)
    let charLPBal = await lpToken.balanceOf(charlotte.address)
    expect(bobLPBal.toString()).to.deep.equal('707083211746155985') 
    expect(charLPBal.toString()).to.deep.equal('707083211746155985') 

  })
  
    it('should burn LP tokens for WETH and TMTO', async () => {
      await ICOSellOutAndTransfer()
      let amount0 = await tomatoToken.balanceOf(tomatoLP.address)
      let amount1 = await WETH.balanceOf(tomatoLP.address)
      await tomatoLP.initialize(amount0.toString(), amount1.toString())
      let lpBal = await lpToken.balanceOf(tomatoLP.address)
      expect(lpBal.toString()).to.deep.equal('21213203435596425732025') //end of init 
  
      await bob.sendTransaction({from: bob.address, to: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', value: ethers.utils.parseEther(`100`)})
      await charlotte.sendTransaction({from: charlotte.address, to: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', value: ethers.utils.parseEther(`300`)})
  
      await approve()
  
      await tomatoLP.connect(bob).provideLiquidity(ethers.utils.parseEther(`5`), ethers.utils.parseEther(`1`))
      await tomatoLP.connect(charlotte).provideLiquidity(ethers.utils.parseEther(`5`), ethers.utils.parseEther(`1`))
  
      let bobLPBal = await lpToken.balanceOf(bob.address)
      let charLPBal = await lpToken.balanceOf(charlotte.address)
      expect(bobLPBal.toString()).to.deep.equal('707083211746155985') 
      expect(charLPBal.toString()).to.deep.equal('707083211746155985') 
      // end of aquiring lp tokens
      
      let bobWETHBal = await WETH.balanceOf(bob.address)
      let charWETHBal = await WETH.balanceOf(charlotte.address)
      let bobMTOBal = await tomatoToken.balanceOf(bob.address)
      let charTMTOBal = await tomatoToken.balanceOf(charlotte.address)

      await tomatoLP.connect(bob).withdrawLiquidity(bobLPBal.toString())
      await tomatoLP.connect(charlotte).withdrawLiquidity(charLPBal.toString())

      let bobWETHBalAfter = await WETH.balanceOf(bob.address)
      let charWETHBalAfter = await WETH.balanceOf(charlotte.address)
      let bobMTOBalAfter = await tomatoToken.balanceOf(bob.address)
      let charTMTOBalAfter = await tomatoToken.balanceOf(charlotte.address)

      expect(Number(bobWETHBalAfter)).to.be.greaterThan(Number(bobWETHBal))
      expect(Number(charWETHBalAfter)).to.be.greaterThan(Number(charWETHBal))
      expect(Number(bobMTOBalAfter)).to.be.greaterThan(Number(bobMTOBal))
      expect(Number(charTMTOBalAfter)).to.be.greaterThan(Number(charTMTOBal))
      
      let bobLPBalAfter = await lpToken.balanceOf(bob.address)
      let charLPBalAfter = await lpToken.balanceOf(charlotte.address)
      expect(bobLPBalAfter.toString()).to.deep.equal('0') 
      expect(charLPBalAfter.toString()).to.deep.equal('0') 
    })

})