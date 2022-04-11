// @ts-ignore
import { artifacts, ethers, network } from "hardhat";
import { readContractAddress } from "./helpers";
import { constants } from "./constants";

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

  const [deployer] = await ethers.getSigners()
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

  console.log("contracts are attached to their ABIs")

  let txn;

  console.log("step 1")

  txn = await treasuryHelper.queue('0', mimBond.address, {gasLimit:gasLimitVal})
  txn.wait()
  // let nonce = receipt.nonce;

  console.log("step 2")
  txn = await treasuryHelper.toggle('0', mimBond.address, constants.zeroAddress, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 3")

  // console.log(constants.daiBondBCV)
  // console.log(await mimBond.terms())
  txn = await mimBond.initializeBondTerms(
    constants.daiBondBCV,
    constants.minBondPrice,
    constants.maxBondPayout,
    constants.bondFee,
    constants.maxBondDebt,
    constants.bondVestingLength, {gasLimit:gasLimitVal }
  )
  txn.wait()

  console.log("step 4")
  // Set staking for DAI bond
  txn = await mimBond.setStaking(stakingHelper.address, true, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 5")
  // Initialize sOHM and set the index
  txn = await sGLFI.initialize(staking.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 6")
  txn = await sGLFI.setIndex(constants.initialIndex, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 7")
  // set distributor contract and warmup contract
  txn = await staking.setContract('0', distributor.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 8")
  txn = await staking.setContract('1', stakingWarmup.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 9")
  // Set treasury for OHM token
  txn = await glfi.setVault(treasury.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 10")
  // Add staking contract as distributor recipient
  txn = await distributor.addRecipient(staking.address, constants.initialRewardRate, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 11")
  // queue and toggle reward manager
  txn = await treasuryHelper.queue('8', distributor.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 12")
  txn = await treasuryHelper.toggle('8', distributor.address, constants.zeroAddress, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 13")
  // queue and toggle deployer reserve depositor
  txn = await treasuryHelper.queue('0', deployer.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 14")
  txn = await treasuryHelper.toggle('0', deployer.address, constants.zeroAddress, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 15")
  // queue and toggle liquidity depositor
  txn = await treasuryHelper.queue('4', deployer.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 16")
  txn = await treasuryHelper.toggle('4', deployer.address, constants.zeroAddress, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 17")
  txn = await mim.approve(treasury.address, constants.largeApproval, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 18")
  // Approve dai bonds to spend deployer's DAI
  txn = await mim.approve(mimBond.address, constants.largeApproval, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 19")
  // Approve staking and staking helper contract to spend deployer's OHM
  txn = await glfi.approve(staking.address, constants.largeApproval, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 20")
  txn = await glfi.approve(stakingHelper.address, constants.largeApproval, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 21")
  // Deposit 9,000,000 DAI to treasury, 600,000 OHM gets minted to deployer and 8,400,000 are in treasury as excesss reserves
  txn = await treasury.deposit(
    '9000000000000000000000000',
    mim.address,
    '8400000000000000', {gasLimit:gasLimitVal }
  )
  txn.wait()

  console.log("step 22")
  // Stake 100 OHM through helper
  txn = await stakingHelper.stake('100000000000', deployer.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log("step 23")
  txn = await mimBond.deposit('1000000000000000000000', '60000', deployer.address, {gasLimit:gasLimitVal })
  txn.wait()

  console.log('GLFI: ' + glfiAdd)
  console.log('MIM Token: ' + mimAdd)
  console.log('Treasury: ' + GLFITreasuryAdd)
  console.log('TreasuryHelper: ' + TreasuryHelperAdd)
  console.log('GLFI Bonding Calc: ' + GLFIBondingCalculatorAdd)
  console.log('Staking: ' + GLFIStakingAdd)
  console.log('sGLFI: ' + sGLFIAdd)
  console.log('Distributor ' + distributorAdd)
  console.log('Staking Warmup ' + StakingWarmupAdd)
  console.log('Staking Helper ' + StakingHelperAdd)
  console.log('MIM-GLFI Bond: ' + GLFIBondDepositoryAdd)
  console.log('wsGLFI Bond: ' + wsGLFIAdd)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
