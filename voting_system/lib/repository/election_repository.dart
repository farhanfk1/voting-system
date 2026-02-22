import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ElectionRepository {
  final String _rpcUrl = 'http://192.168.0.116:7545'; 
  final String _privateKey = '0x63cb110b24cd132b892bb143f3b77a62e8c9291df96b48913c166450a39c5b95'; 
  final String _contractAddress = '0xA6d204F386F914A0938dCbd48C69c20ffce1b1be';
  late Web3Client _client;
  late Credentials _credentials;
 // late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late ContractFunction _createElection;
  late ContractFunction _getAllElections;
  late ContractFunction _addCandidate;
  late ContractFunction _advancePhase;
  late ContractFunction _getCandidates;

  ElectionRepository() {
   _client = Web3Client(_rpcUrl, Client());
   _testConnection();
    // _contractAddress = EthereumAddress.fromHex('0x558c24bF4A0388984fD05Ed95a6A698A955A85bd'); 
  }
  void _testConnection()async {
      try {
  final block = await _client.getBlockNumber();
  debugPrint("Connected to blockchain! Current block: $block");
} catch (e) {
  debugPrint("Cannot connect to blockchain: $e");
}
  }

  Future<void> init() async {
    try {
    _credentials = EthPrivateKey.fromHex(_privateKey);
    final senderAddress = await _credentials.extractAddress();
      print("Sender address from Flutter: ${senderAddress.hex}");
    final String  abiString = await rootBundle.loadString('assets/abi/dvs.json');
    final abijson = jsonDecode(abiString);
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abijson['abi']), 'DVS'),
      EthereumAddress.fromHex(_contractAddress),
    );

    _createElection = _contract.function('createElection');
    _getAllElections = _contract.function('getAllElections');
    _addCandidate = _contract.function('addCandidate');
    _advancePhase = _contract.function('advancePhase');
    _getCandidates = _contract.function('getCandidates');
    debugPrint("Smart contract initialized successfully");
    print("Smart contract initialized successfully");
    } catch (e) {
     debugPrint("Error initializing contract: $e");
     rethrow;
    }  
  }

  Future<Map<String, dynamic>> createElection(String name, String description, int start, int end) async {
    // Check if contract is initialized
    try {
      // Validate input parameters
      if (name.isEmpty) {
        throw Exception("Election name cannot be empty");
      }
      if (description.isEmpty) {
        throw Exception("Election description cannot be empty");
      }
      if (start <= 0 || end <= 0) {
        throw Exception("Invalid date values");
      }
      if (end <= start) {
        throw Exception("End date must be after start date");
      }
      
      debugPrint("Creating election: name=$name, start=$start, end=$end");
       
       
       final txHash = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _createElection,
          parameters: [name, description, BigInt.from(start), BigInt.from(end)],
          maxGas: 3000000,
        ),
        chainId: 1337,
      );
      
      debugPrint("Election creation transaction sent successfully, txHAsh: $txHash");
      // return the new election as a map
      return {
      'id': txHash,   // temporary unique identifier
      'name': name,
      'description': description,
      'start': start,
      'end': end,
      'phase': 0,     // assuming new elections start at phase 0
      };
    } catch (e) {
      debugPrint("Error in createElection: $e");
      rethrow;
    }
  }
  Future<List<Map<String, dynamic>>> getAllElections() async {
    final getAllElections = _contract.function('getAllElections');
    final result = await _client.call(
      contract: _contract,
       function: getAllElections,
        params: [],);
         // Make sure result is not null and has expected structure
        final  ids = result[0] ?? [];
        final  names = result[1] ?? [];
        final  phases = result[2] ?? [];
          // Convert the result from blockchain into a list
     return List.generate(ids.length, (i){
      return {
        'id' : ids[i].toInt(),
        'name' : names[i] ?? 'unnamed',
        'phase' : phases[i].toInt(),
        'description': '',
      };
     });
  }

  Future<void> addCandidate(int electionId, String candidateName) async {
    try {
      if (candidateName.isEmpty) {
        throw Exception("Candidate name cannot be empty");
      }
      debugPrint("Adding candidate '$candidateName' to election $electionId");
      
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _addCandidate,
          parameters: [BigInt.from(electionId), candidateName],
          maxGas: 500000,
        ),
        chainId: 1337,
      );
      debugPrint("Candidate added successfully");
    } catch (e) {
      debugPrint("Error adding candidate: $e");
      rethrow;
    }
  }

  Future<void> advancePhase(int electionId) async {
    try {
      debugPrint("Advancing phase for election $electionId");
      
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _advancePhase,
          parameters: [BigInt.from(electionId)],
          maxGas: 500000,
        ),
        chainId: 1337,
      );
      debugPrint("Phase advanced successfully");
    } catch (e) {
      debugPrint("Error advancing phase: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCandidates(int electionId) async {
    try {
      final result = await _client.call(
        contract: _contract,
        function: _getCandidates,
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