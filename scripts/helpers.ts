import { artifacts } from "hardhat";

export function saveFrontendFiles(sampleToken: any, contractName: any) {
  const fs = require('fs')
  const contractsDir = __dirname + '/constants'

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir)
  }

  fs.writeFileSync(
    contractsDir + '/' + contractName + '.json',
    JSON.stringify({ Token: sampleToken.address }, undefined, 2)
  )

  const TokenArtifact = artifacts.readArtifactSync(contractName)

  fs.writeFileSync(
    contractsDir + '/abis' + '/' + contractName + '.json',
    JSON.stringify(TokenArtifact, null, 2)
  )
}

export function readContractAddress(path: any) : string {
  const fs = require('fs')
  const contractsDir = __dirname + '/constants' + path

  let stringJson = fs.readFileSync(contractsDir, 'utf-8')
  return JSON.parse(stringJson).Token;
}

export function readJson(path: any) : string {
  const fs = require('fs')
  const contractsDir = __dirname + '/constants' + path

  return fs.readFileSync(contractsDir, 'utf-8')
}