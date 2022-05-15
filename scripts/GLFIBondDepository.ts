// @ts-ignore
import { artifacts, ethers, network } from "hardhat";
import { readContractAddress, saveFrontendFiles } from "./helpers";
import { constants } from "./constants";

// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.
async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  const [deployer, MockDao] = await ethers.getSigners();

  const glfiTreasuryAddress = readContractAddress("/GLFITreasury.json");
  const mimAddress = readContractAddress("/MIMToken.json");
  const glfiAddress = readContractAddress("/GLFI.json");

  const GLFIBondDepository = await ethers.getContractFactory(
    "GLFIBondDepository"
  );
  const glfiBondDepository = await GLFIBondDepository.deploy(
    glfiAddress,
    mimAddress,
    glfiTreasuryAddress,
    MockDao.address,
    constants.zeroAddress
  );
  await glfiBondDepository.deployed();

  console.log("Token address:", glfiBondDepository.address);

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(glfiBondDepository, "GLFIBondDepository");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
