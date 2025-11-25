import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ElectionRepository {
  final String _rpcUrl = 'http://127.0.0.1:7545'; 
  final String _privateKey = '0x781a4c4b12a8902b4658ee006d4a3a012cfbb11b4cb8147abe42b095fd49d255'; 

  late Web3Client _client;
  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late ContractFunction _createElection;

  ElectionRepository() {
    _client = Web3Client(_rpcUrl, Client());
    _contractAddress = EthereumAddress.fromHex('0xFc23cBe2fE5151c9fcE32F4A4dCD78bE47383D4C'); 
  }

  Future<void> init() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
    final abiCode = await rootBundle.loadString('assets/abi/election.json');

    _contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'Election'),
      _contractAddress,
    );

    _createElection = _contract.function('createElection');
  }

  Future<void> createElection(String name, String description, int start, int end) async {
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _createElection,
        parameters: [name, description, BigInt.from(start), BigInt.from(end)],
        maxGas: 1000000,
      ),
      chainId: null,
    );
  }
}