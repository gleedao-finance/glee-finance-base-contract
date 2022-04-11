// @ts-ignore
import { artifacts, ethers, network } from "hardhat";
import { readContractAddress, saveFrontendFiles } from "./helpers";

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

  const glfiAddress = readContractAddress('/GLFI.json')
  const treasuryHelperAddress = readContractAddress('/TreasuryHelper.json')

  const GLFITreasury = await ethers.getContractFactory('GLFITreasury')
  const glfiTreasury = await GLFITreasury.deploy(glfiAddress, treasuryHelperAddress)
  await glfiTreasury.deployed()

  console.log('Token address:', glfiTreasury.address)

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(glfiTreasury, 'GLFITreasury')

  const TreasuryHelper = await ethers.getContractFactory('TreasuryHelper')
  const treasuryHelper = await TreasuryHelper.attach(treasuryHelperAddress)

  await treasuryHelper.setTreasuryAddress(glfiTreasury.address)

  console.log("Treasury address alloted in treasuryHelper contract")
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
