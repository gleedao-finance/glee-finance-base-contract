// @ts-ignore
import { artifacts, ethers, network } from "hardhat";
import { readContractAddress } from "./helpers";

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

  const sGLFIAddress = readContractAddress('/SGLFI.json')

  const wSGLFI = await ethers.getContractFactory('wsGLFI')
  const wsGLFI = await wSGLFI.deploy(sGLFIAddress)
  await wsGLFI.deployed()

  console.log('Token address:', wsGLFI.address)

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(wsGLFI)
}

export function saveFrontendFiles(sampleToken: any) {
  const fs = require('fs')
  const contractsDir = __dirname + '/constants'

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir)
  }

  fs.writeFileSync(
    contractsDir + '/' + 'WSGLFI.json',
    JSON.stringify({ Token: sampleToken.address }, undefined, 2)
  )

  const TokenArtifact = artifacts.readArtifactSync('wsGLFI')

  fs.writeFileSync(
    contractsDir + '/abis/WSGLFI.json',
    JSON.stringify(TokenArtifact, null, 2)
  )
}



main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
