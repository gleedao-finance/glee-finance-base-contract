// @ts-ignore
import { artifacts, ethers, network } from "hardhat";
import { readContractAddress } from "./helpers";
import "./constants";

const distributorAdd = readContractAddress('/Distributor.json')
const sGLFIAdd = readContractAddress('/SGLFI.json')
const wsGLFIAdd = readContractAddress('/WSGLFI.json')
const mimAdd = readContractAddress('/MIMToken.json')
const StakingHelperAdd = readContractAddress('/StakingHelper.json')
const StakingWarmupAdd = readContractAddress('/StakingWarmup.json')
const glfiAdd = readContractAddress('/GLFI.json')
const GLFIBondDepositoryAdd = readContractAddress('/GLFIBondDepository.json')
const GLFIBondingCalculatorAdd = readContractAddress('/GLFIBondingCalculator.json')
const GLFIStakingAdd = readContractAddress('/GLFIStaking.json')
const GLFITreasuryAdd = readContractAddress('/GLFITreasury.json')
const TreasuryHelperAdd = readContractAddress('/TreasuryHelper.json')

async function main() {

  const [deployer, dao] = await ethers.getSigners()
  const gasLimitVal = 2500000

  const MIMBond = await ethers.getContractFactory('GLFIBondDepository')
  const mimBond = await MIMBond.attach(GLFIBondDepositoryAdd)

  const GLFI = await ethers.getContractFactory('GLFI')
  const glfi = await GLFI.attach(glfiAdd)

  const SGLFI = await ethers.getContractFactory('SGLFI')
  const sGLFI = await SGLFI.attach(sGLFIAdd)

  const GLFITreasury = await ethers.getContractFactory('GLFITreasury')
  const treasury = await GLFITreasury.attach(GLFITreasuryAdd)

  const TreasuryHelper = await ethers.getContractFactory('TreasuryHelper')
  const treasuryHelper = await TreasuryHelper.attach(TreasuryHelperAdd)

  const Distributor = await ethers.getContractFactory('Distributor')
  const distributor = await Distributor.attach(distributorAdd)

  const GLFIStaking = await ethers.getContractFactory('GLFIStaking')
  const staking = await GLFIStaking.attach(GLFIStakingAdd)

  const StakingWarmup = await ethers.getContractFactory('StakingWarmup')
  const stakingWarmup = await StakingWarmup.attach(StakingWarmupAdd)

  const StakingHelper = await ethers.getContractFactory('StakingHelper')
  const stakingHelper = await StakingHelper.attach(StakingHelperAdd)

  const MIMToken = await ethers.getContractFactory('MIMToken')
  const mim = await MIMToken.attach(mimAdd)

  // const MIMFaucet = await ethers.getContractFactory('MIMFAUCET')
  // const mimFaucet = await MIMFaucet.deploy(mimAdd)
  // await mimFaucet.deployed()

  console.log("contracts are attached to their ABIs")

  for(let i=1; i< 30; i++){
    const rebaseTxn = await staking.rebase();
    await rebaseTxn.wait();
    console.log("rebase ", i)
  }

  // console.log("mim faucet address:", mimFaucet.address);
  //
  // console.log("mim faucet balance:", await mim.balanceOf(mimFaucet.address))
  //
  // await mim.transfer(mimFaucet.address, '100000000000000000000000', {gasLimit: 2500000})
  //
  // console.log("mim faucet balance:", await mim.balanceOf(mimFaucet.address))
  // console.log("Bond price in USD of deployer", await mimBond.bondPriceInUSD())
  // console.log("Debt Ratio", await mimBond.debtRatio())
  // console.log("Current Debt", await mimBond.currentDebt())
  // console.log("total glfi supply Debt", await glfi.totalSupply())
  // console.log("Bond Info of deployer", await mimBond.useHelper())
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
