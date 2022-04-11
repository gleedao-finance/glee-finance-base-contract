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

  const glfiStakingAddress = readContractAddress('/GLFIStaking.json')
  const sGLFIAddress = readContractAddress('/SGLFI.json')

  const StakingWarmup = await ethers.getContractFactory('StakingWarmup')
  const stakingWarmup = await StakingWarmup.deploy(glfiStakingAddress, sGLFIAddress)
  await stakingWarmup.deployed()

  console.log('Token address:', stakingWarmup.address)

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(stakingWarmup, 'StakingWarmup')
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
