// @ts-ignore
import { artifacts, ethers, network } from "hardhat";
import { saveFrontendFiles } from "./helpers";
import { constants } from "./constants";

// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.
async function main() {
  // This is just a convenience check
  if (network.name === 'hardhat') {
    console.warn(
      'You are trying to deploy a contract to the Hardhat Network, which' +
      'gets automatically created and destroyed every time. Use the Hardhat' +
      " option '--network localhost'"
    )
  }

  // ethers is avaialble in the global scope
  const [deployer] = await ethers.getSigners()

  const MIMToken = await ethers.getContractFactory('MIMToken')
  const MIM = await MIMToken.deploy()
  await MIM.deployed()

  console.log('Token address:', MIM.address)

  const gasLimitVal = await MIM.estimateGas.mint(deployer.address, constants.initialMint);

  await MIM.mint(deployer.address, constants.initialMint, {gasLimit: gasLimitVal});
  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(MIM, 'MIMToken')
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
