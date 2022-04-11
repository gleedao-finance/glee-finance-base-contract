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
  const glfiStakingAddress = readContractAddress('/GLFIStaking.json')

  const StakingHelper = await ethers.getContractFactory('StakingHelper')
  const stakingHelper = await StakingHelper.deploy(glfiStakingAddress, glfiAddress)
  await stakingHelper.deployed()

  console.log('Token address:', stakingHelper.address)

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(stakingHelper, 'StakingHelper')
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
