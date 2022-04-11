
export class constants {
  public static initialIndex ="7675210820";
  public static firstEpochBlock ="8961000"; // Should be the deployement time in uint32(block.timestamp)
  public static firstEpochNumber ="1";  // for every rebase done, this increase by 1. This can be used as a vesting strategy
  public static epochLengthInBlocks ="3600";  // time for rebase in seconds, 8 hrs i.e 8*3600
  public static initialRewardRate ="300";  // try to reduce and check it's effect
  public static zeroAddress ="0x0000000000000000000000000000000000000000";
  public static largeApproval ="100000000000000000000000000000000";
  public static initialMint ="10000000000000000000000000";
  public static daiBondBCV ="369";
  public static bondVestingLength ="1200";  // 3 days times in second (3*24*3600)
  public static minBondPrice ="50000";
  public static maxBondPayout ="50";
  public static bondFee ="10000";
  public static maxBondDebt ="1000000000000000";
  public static initialBondDebt ="0";
}