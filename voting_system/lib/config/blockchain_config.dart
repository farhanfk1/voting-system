/// Single place for Ganache / RPC settings. Update [rpcUrl] if your PC IP changes.
class BlockchainConfig {
  BlockchainConfig._();

  /// Your PC LAN IP (run `ipconfig` on Windows). Use 10.0.2.2 from Android emulator → host.
  static const String rpcUrl = 'http://192.168.0.121:7545';

  static const int chainId = 1337;
}
