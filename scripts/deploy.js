// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require("hardhat");

async function main() {
  const [deployer, MockDAO] = await ethers.getSigners();
  console.log("Deploying contracts with the account: " + deployer.address);

  // Initial staking index
  const initialIndex = "7675210820";

  // First block epoch occurs
  const firstEpochBlock = "8961000";

  // What epoch will be first epoch
  const firstEpochNumber = "338";

  // How many blocks are in each epoch
  const epochLengthInBlocks = "2200";

  // Initial reward rate for epoch
  const initialRewardRate = '3000'

  // Ethereum 0 address, used when toggling changes in treasury
  const zeroAddress = '0x0000000000000000000000000000000000000000'

  // Large number for approval for Frax and DAI
  const largeApproval = "100000000000000000000000000000000";

  // Initial mint for Frax and DAI (10,000,000)
  const initialMint = "10000000000000000000000000";

  // DAI bond BCV
  const daiBondBCV = "369";

  // Bond vesting length in blocks. 129600 ~ 5 days
  const bondVestingLength = "129600";

  // Min bond price
  const minBondPrice = "50000";

  // Max bond payout
  const maxBondPayout = '50'

  // DAO fee for bond
  const bondFee = '10000'

  // Max debt bond can take on
  const maxBondDebt = '1000000000000000'

  // Initial Bond debt
  const intialBondDebt = '0'

  // Deploy OHM
  const Time = await ethers.getContractFactory("TimeERC20Token");
  const time = await Time.deploy();

  console.log("Time ERC20 deployed");
  // Deploy DAI
  const MIMToken = await ethers.getContractFactory("MIMToken");
  const MimToken = await MIMToken.deploy();

  console.log("Mim Token Deployed: ", MimToken.address);
  // Deploy 10,000,000 mock DAI and mock Frax
  await MimToken.mint(deployer.address, initialMint, {
    gasLimit: 2500000,
  });

  console.log("Minted");
  const TreasuryHelper = await ethers.getContractFactory("TreasuryHelper");
  // check the limitAmount
  const treasuryHelper = await TreasuryHelper.deploy(time.address,
    MimToken.address, 0, { gasLimit: 8000000, });

  console.log('treasury helper done: ' + treasuryHelper.address)
  // Deploy treasury
  //@dev changed function in treaury from 'valueOf' to 'valueOfToken'... solidity function was coflicting w js object property name
  const Treasury = await ethers.getContractFactory('TimeTreasury')
  // check the limitAmount
  const treasury = await Treasury.deploy(time.address, treasuryHelper.address, {
    gasLimit: 8000000,
  })
  console.log('lol hogaya BC '+ await treasury.address)

  await treasuryHelper.setTreasuryAddress(treasury.address, {
    gasLimit: 8000000,
  })

  console.log('treasury address setted in helper contract+ ' + treasury.address)

  // Deploy bonding calc
  const TimeBondingCalculator = await ethers.getContractFactory(
    'TimeBondingCalculator'
  )
  const timeBondingCalculator = await TimeBondingCalculator.deploy(time.address)

  // Deploy staking distributor
  const Distributor = await ethers.getContractFactory('Distributor')
  const distributor = await Distributor.deploy(
    treasury.address,
    time.address,
    epochLengthInBlocks,
    firstEpochBlock
  )

  // Deploy sOHM
  const MEMO = await ethers.getContractFactory('MEMOries')
  const memo = await MEMO.deploy()

  // Deploy Staking
  const Staking = await ethers.getContractFactory('TimeStaking')
  const staking = await Staking.deploy(
    time.address,
    memo.address,
    epochLengthInBlocks,
    firstEpochNumber,
    firstEpochBlock
  )

  // Deploy staking warmpup
  const StakingWarmpup = await ethers.getContractFactory('StakingWarmup')
  const stakingWarmup = await StakingWarmpup.deploy(
    staking.address,
    memo.address
  )

  // Deploy staking helper
  const StakingHelper = await ethers.getContractFactory('StakingHelper')
  const stakingHelper = await StakingHelper.deploy(
    staking.address,
    time.address
  )

  // Deploy DAI bond
  //@dev changed function call to Treasury of 'valueOf' to 'valueOfToken' in BondDepository due to change in Treausry contract
  const MIMBond = await ethers.getContractFactory('TimeBondDepository')
  const mimBond = await MIMBond.deploy(
    time.address,
    MimToken.address,
    treasury.address,
    MockDAO.address,
    zeroAddress
  )
  console.log('Mim Bond deployed: ' + mimBond.address)
  // queue and toggle DAI bond reserve depositor
  await treasuryHelper.queue('0', mimBond.address)
  await treasuryHelper.toggle('0', mimBond.address, zeroAddress, {
    gasLimit: 8000000,
  })

  console.log('mimBond initialization started!!')
  // Set DAI bond terms
  await mimBond.initializeBondTerms(
    daiBondBCV,
    minBondPrice,
    maxBondPayout,
    bondFee,
    maxBondDebt,
    bondVestingLength
  )

  console.log('mimBond initialization done!!')
  // Set staking for DAI bond
  await mimBond.setStaking(staking.address, true)

  // Initialize sOHM and set the index
  await memo.initialize(staking.address)
  await memo.setIndex(initialIndex)

  // set distributor contract and warmup contract
  await staking.setContract('0', distributor.address)
  await staking.setContract('1', stakingWarmup.address)

  // Set treasury for OHM token
  await time.setVault(treasury.address)

  // Add staking contract as distributor recipient
  await distributor.addRecipient(staking.address, initialRewardRate)

  // queue and toggle reward manager
  await treasuryHelper.queue('8', distributor.address)
  await treasuryHelper.toggle('8', distributor.address, zeroAddress, {
    gasLimit: 2500000,
  })

  // queue and toggle deployer reserve depositor
  await treasuryHelper.queue('0', deployer.address)
  await treasuryHelper.toggle('0', deployer.address, zeroAddress, {
    gasLimit: 2500000,
  })

  // queue and toggle liquidity depositor
  await treasuryHelper.queue('4', deployer.address)
  await treasuryHelper.toggle('4', deployer.address, zeroAddress, {
    gasLimit: 2500000,
  })

  console.log('toggle done')
  // Approve the treasury to spend DAI
  await MimToken.approve(treasury.address, largeApproval)

  // Approve dai bonds to spend deployer's DAI
  await MimToken.approve(mimBond.address, largeApproval)

  // Approve staking and staking helper contract to spend deployer's OHM
  await time.approve(staking.address, largeApproval)
  await time.approve(stakingHelper.address, largeApproval)

  // Deposit 9,000,000 DAI to treasury, 600,000 OHM gets minted to deployer and 8,400,000 are in treasury as excesss reserves
  await treasury.deposit(
    '9000000000000000000000000',
    MimToken.address,
    '8400000000000000'
  )

  console.log('Treasury deposited');
  // Stake 100 OHM through helper
  await stakingHelper.stake('100000000000', deployer.address, {
    gasLimit: 2500000,
  })

  console.log("staked!!");

  // Bond 1,000 OHM and Frax in each of their bonds
  // await mimBond.deposit('1000000000000000000000', '60000', deployer.address)

  console.log('Time: ' + time.address)
  console.log('MIM Token: ' + MimToken.address)
  console.log('Treasury: ' + treasury.address)
  console.log('Time Bonding Calc: ' + timeBondingCalculator.address)
  console.log('Staking: ' + staking.address)
  console.log('MEMO: ' + memo.address)
  console.log('Distributor ' + distributor.address)
  console.log('Staking Warmup ' + stakingWarmup.address)
  console.log('Staking Helper ' + stakingHelper.address)
  console.log('MIM Bond: ' + mimBond.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
