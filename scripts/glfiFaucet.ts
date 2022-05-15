// @ts-ignore
import { ethers } from "hardhat";
import { readContractAddress, saveFrontendFiles } from "./helpers";

// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.address
  );

  const glfiAddress = readContractAddress("/GLFI.json");

  const GlfiFaucet = await ethers.getContractFactory("GLFIFaucet");
  const glfiFaucet = await GlfiFaucet.deploy(glfiAddress);
  await glfiFaucet.deployed();

  console.log("Token address of glfiFaucet:", glfiFaucet.address);

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(glfiFaucet, "GLFIFaucet");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
