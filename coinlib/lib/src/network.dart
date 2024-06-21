class Network {

  final int wifPrefix, p2pkhPrefix, p2shPrefix, privHDPrefix, pubHDPrefix;
  final String bech32Hrp, messagePrefix;
  final BigInt minFee, minOutput, feePerKb;

  Network({
    required this.wifPrefix,
    required this.p2pkhPrefix,
    required this.p2shPrefix,
    required this.privHDPrefix,
    required this.pubHDPrefix,
    required this.bech32Hrp,
    required this.messagePrefix,
    required this.minFee,
    required this.minOutput,
    required this.feePerKb,
  });

  static final mainnet = Network(
    wifPrefix: 158,
    p2pkhPrefix: 30,
    p2shPrefix: 33,
    privHDPrefix: 0x0221312b,
    pubHDPrefix: 0x022d2533,
    bech32Hrp: "vg",
    messagePrefix: "Verge Signed Message:\n",
    minFee: BigInt.from(1000),
    minOutput: BigInt.from(10000),
    feePerKb: BigInt.from(10000),
  );

  static final testnet = Network(
    wifPrefix: 243,
    p2pkhPrefix: 115,
    p2shPrefix: 198,
    privHDPrefix: 0x04358394,
    pubHDPrefix: 0x043587CF,
    bech32Hrp: "vt",
    messagePrefix: "Verge Signed Message:\n",
    minFee: BigInt.from(1000),
    minOutput: BigInt.from(10000),
    feePerKb: BigInt.from(10000),
  );

}
