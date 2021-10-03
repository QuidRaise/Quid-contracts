const hre = require("hardhat");
const { ethers } = hre;

async function main() {
  const QuidRaise = await ethers.getContractFactory("QuidRaise");
  const quidRaise = await QuidRaise.deploy();
  await quidRaise.deployed();
  console.log(`Quid raise contract Deployed: ${quidRaise.address}`);

  if (hre.network.name === "mainnet" || hre.network.name === "testnet") {
    await hre.run("verify:verify", {
      address: quidRaise.address,
      constructorArguments: [],
    });
  } else {
    console.log("Contracts deployed to", hre.network.name, "network. Please verify them manually.");
  }
}
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
