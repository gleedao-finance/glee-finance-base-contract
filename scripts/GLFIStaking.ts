// @ts-ignore
import {artifacts, ethers, network} from 'hardhat'
import { saveFrontendFiles, readContractAddress, readJson } from "./helpers";
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
  const sGLFIAddress = readContractAddress('/SGLFI.json')

  const GLFIStaking = await ethers.getContractFactory('GLFIStaking')
  const glfiStaking = await GLFIStaking.deploy(glfiAddress,
                                               sGLFIAddress,
                                              constants.epochLengthInBlocks,
                                              constants.firstEpochNumber,
                                              constants.firstEpochBlock)
  await glfiStaking.deployed()

  console.log('Token address:', glfiStaking.address)

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(glfiStaking, 'GLFIStaking')
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
