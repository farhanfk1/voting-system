import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class VoteRepository {
    final String _rpcUrl = 'http://127.0.0.1:7545';
  final String _privateKey = '0x9516159ce91b1c5d4d1f4597e481fcdd48b951966ec5b5998df661e4d76ee8c8';

    late Web3Client _client;
  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late ContractFunction _voteFunction;
  late ContractFunction _getResultFunction;
  late ContractFunction _getElectionListFunction;

    VoteRepository() {
    _client = Web3Client(_rpcUrl, Client());
_contractAddress = EthereumAddress.fromHex('0x3c6BA40962Aade7d6c2199B8d12f0bE3A0c5d8cC');
  }
    Future<void> init() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
    final abiCode = await rootBundle.loadString('assets/abi/dvs.json');

    _contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'Election'),
      _contractAddress,
    );

    _voteFunction = _contract.function('vote');
    _getResultFunction = _contract.function('getResult');
    _getElectionListFunction = _contract.function('getElections');
  }
  
  // Get list of elections
  Future<List<Map<String, dynamic>>> getElections() async {
    final res = await _client.call(
      contract: _contract,
      function: _getElectionListFunction,
      params: [],
    );

    // Convert response to list of maps (id, name, description)
    List<Map<String, dynamic>> elections = [];
    for (var e in res[0]) {
      elections.add({
        'id': e[0] as BigInt,
        'name': e[1] as String,
        'description': e[2] as String,
      });
    }
    return elections;
  }
    // Cast a vote
  Future<void> vote(BigInt electionId, int candidateIndex) async {
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _voteFunction,
        parameters: [electionId, BigInt.from(candidateIndex)],
        maxGas: 100000,
      ),
    );
  }
    // Get election result
  Future<Map<String, dynamic>> getResult(BigInt electionId) async {
    final res = await _client.call(
      contract: _contract,
      function: _getResultFunction,
      params: [electionId],
    );

    // Example: res[0] = List of votes per candidate
    return {
      'votes': res[0], // List<BigInt>
    };
  }
}