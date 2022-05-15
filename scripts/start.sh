#!/bin/bash

#npx hardhat run ./GLFI.ts --network meter &&
#npx hardhat run ./MIM.ts --network meter &&
#npx hardhat run ./TreasuryHelper.ts --network meter &&
#npx hardhat run ./Treasury.ts --network meter &&
#npx hardhat run ./GLFIBondingCalculator.ts --network meter &&
#npx hardhat run ./Distributor.ts --network meter &&
#npx hardhat run ./sGLFI.ts --network meter &&
#npx hardhat run ./GLFIStaking.ts --network meter &&
#npx hardhat run ./StakingWarmup.ts --network meter &&
#npx hardhat run ./StakingHelper.ts --network meter &&
npx hardhat run ./GLFIBondDepository.ts --network meter &&
npx hardhat run ./wsORCL.ts --network meter
npx hardhat run ./initialize.ts --network meter