import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ElectionRepository {
  final String _rpcUrl = 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID'; 
  final String _privateKey = 'YOUR_PRIVATE_KEY'; 

  late Web3Client _client;
  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late ContractFunction _createElection;

  ElectionRepository() {
    _client = Web3Client(_rpcUrl, Client());
    _contractAddress = EthereumAddress.fromHex('0x5b38Da6a701c568545dCfcB03FcB875f56beddC4'); 
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
