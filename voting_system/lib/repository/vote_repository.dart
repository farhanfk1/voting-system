import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:voting_system/config/blockchain_config.dart';
import 'package:web3dart/web3dart.dart';

class VoteRepository {
  final String _rpcUrl = BlockchainConfig.rpcUrl;

  late Web3Client _client;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late ContractFunction _voteFunction;
  late ContractFunction _getCandidatesFunction;
  late ContractFunction _getAllElectionsFunction;

  VoteRepository() {
    _client = Web3Client(_rpcUrl, Client());
    _contractAddress = EthereumAddress.fromHex('0xadC54BFB1637cDa0Ace8019e7b88f0926a7ED93A');
  }

  Future<void> init() async {
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
  /// [voterPrivateKey] — Ganache private key assigned to this Firebase user.
  Future<void> vote(
    BigInt electionId,
    int candidateIndex, {
    required String voterPrivateKey,
  }) async {
    try {
      final credentials = EthPrivateKey.fromHex(voterPrivateKey);
      final sender = await credentials.extractAddress();
      debugPrint('Voting from wallet: ${sender.hex}');

      await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: _voteFunction,
          parameters: [electionId, BigInt.from(candidateIndex)],
          maxGas: 100000,
        ),
        chainId: BlockchainConfig.chainId,
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

    final ids = res[0] is List ? List<dynamic>.from(res[0] as List) : <dynamic>[];
    final names = res[1] is List ? List<dynamic>.from(res[1] as List) : <dynamic>[];
    final votes = res[2] is List ? List<dynamic>.from(res[2] as List) : <dynamic>[];

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