async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy();
  await treasury.deployed()
  
  console.log("Treasury address:", treasury.address);
  
  const TomatoToken = await ethers.getContractFactory("TomatoToken")
  tomatoToken = await TomatoToken.deploy(treasury.address)
  await tomatoToken.deployed()
  
  console.log("Tomato Token address:", tomatoToken.address);
  
  const ICO = await ethers.getContractFactory("ICO")
  ico = await ICO.deploy(treasury.address)
  await ico.deployed()
  
  console.log("ICO address:", tomatoToken.address);

  treasury.setTokenContract(tomatoToken.address)
  treasury.setICOContract(ico.address)

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });