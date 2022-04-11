// @ts-ignore
import { artifacts, ethers, network } from "hardhat";
import { readContractAddress, saveFrontendFiles } from "./helpers";
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

  const glfiAddress = readContractAddress('/GLFI.json')
  const treasuryAddress = readContractAddress('/GLFITreasury.json')

  const Distributor = await ethers.getContractFactory('Distributor')
  const distributor = await Distributor.deploy(treasuryAddress, glfiAddress, constants.epochLengthInBlocks, constants.firstEpochBlock)
  await distributor.deployed()

  console.log('Token address:', distributor.address)

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(distributor, 'Distributor')
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
