import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class VoteRepository {
    final String _rpcUrl = 'http://192.168.0.122:7545';
  final String _privateKey = '0xe36328e66830f6fc94dabff9063e877ad73e71e36745d79c861c5591f98616ed';

  late Web3Client _client;
  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late ContractFunction _voteFunction;
  late ContractFunction _getCandidatesFunction;
  late ContractFunction _getAllElectionsFunction;

  VoteRepository() {
    _client = Web3Client(_rpcUrl, Client());
    _contractAddress = EthereumAddress.fromHex('0x69947Fc989426B320Fb9c861Ca4c0Bc2E74a51e6');
  }

  Future<void> init() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
    final abiString = await rootBundle.loadString('assets/abi/dvs.json');
    final abijson = jsonDecode(abiString);

    _contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abijson['abi']), 'DVS'),
      _contractAddress,
    );

    _voteFunction = _contract.function('vote');
    _getCandidatesFunction = _contract.function('getCandidates');
    _getAllElectionsFunction = _contract.function('getAllElections');
  }

  // Get list of elections (DVS returns ids, names, phases as parallel arrays)
  Future<List<Map<String, dynamic>>> getElections() async {
    final res = await _client.call(
      contract: _contract,
      function: _getAllElectionsFunction,
      params: [],
    );

    final ids = res[0] ?? [];
    final names = res[1] ?? [];
    final phases = res[2] ?? [];

    return List.generate(ids.length, (i) {
      return {
        'id': ids[i] is BigInt ? ids[i] : BigInt.from(ids[i] is int ? ids[i] : 0),
        'name': names[i] ?? 'Unnamed',
        'description': '', // getAllElections does not return description
        'phase': phases[i] is BigInt ? phases[i] : BigInt.from(phases[i] is int ? phases[i] : 0),
      };
    });
  }
    // Cast a vote
  Future<void> vote(BigInt electionId, int candidateIndex) async {
    try {
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _voteFunction,
          parameters: [electionId, BigInt.from(candidateIndex)],
          maxGas: 100000,
        ),
        chainId: 1337,
      );
    } catch (e) {
      rethrow;
    }
  }
  // Get election result (DVS getCandidates returns ids, names, votes)
  Future<Map<String, dynamic>> getResult(BigInt electionId) async {
    final res = await _client.call(
      contract: _contract,
      function: _getCandidatesFunction,
      params: [electionId],
    );

    // getCandidates returns (ids, names, votes) - return all three arrays
    final ids = res[0] ?? [];
    final names = res[1] ?? [];
    final votes = res[2] ?? [];
    
    return {
      'ids': ids,
      'names': names,
      'votes': votes,
    };
  }

   Future<List<Map<String, dynamic>>> getCandidates(int electionId) async {
    try {
      final result = await _client.call(
        contract: _contract,
        function: _getCandidatesFunction,
        params: [BigInt.from(electionId)],
      );
      
      final ids = result[0] ?? [];
      final names = result[1] ?? [];
      final votes = result[2] ?? [];
      
      return List.generate(ids.length, (i) {
        return {
          'id': ids[i].toInt(),
          'name': names[i] ?? 'Unknown',
          'votes': votes[i].toInt(),
        };
      });
    } catch (e) {
      debugPrint("Error getting candidates: $e");
      rethrow;
    }
  }
}