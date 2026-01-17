import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ElectionRepository {
  final String _rpcUrl = 'http://192.168.18.27:7545'; 
  final String _privateKey = '0xa9a0ba887c153603e38f102dc9c8c214468ad8a721eac7358a0c3048fc3360ed'; 
  final String _contractAddress = '0x558c24bF4A0388984fD05Ed95a6A698A955A85bd';
  //privatekey 0x9516159ce91b1c5d4d1f4597e481fcdd48b951966ec5b5998df661e4d76ee8c8
  // contrctAddres 0x3c6BA40962Aade7d6c2199B8d12f0bE3A0c5d8cC
  late Web3Client _client;
  late Credentials _credentials;
 // late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late ContractFunction _createElection;
  late ContractFunction _getAllElections;

  ElectionRepository() {
   _client = Web3Client(_rpcUrl, Client());
   _testConnection();
    // _contractAddress = EthereumAddress.fromHex('0x3c6BA40962Aade7d6c2199B8d12f0bE3A0c5d8cC'); 
  }
  void _testConnection()async {
      try {
  final block = _client.getBlockNumber();
  debugPrint("Connected to blockchain! Current block: $block");
} catch (e) {
  debugPrint("Cannot connect to blockchain: $e");
}
  }

  Future<void> init() async {
    try {
    _credentials = EthPrivateKey.fromHex(_privateKey);
    final String  abiString = await rootBundle.loadString('assets/abi/dvs.json');
    final abijson = jsonDecode(abiString);
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abijson['abi']), 'DVS'),
      EthereumAddress.fromHex(_contractAddress),
    );

    _createElection = _contract.function('createElection');
    _getAllElections = _contract.function('getAllElections');
    debugPrint("Smart contract initialized successfully");
    } catch (e) {
     debugPrint("Error initializing contract: $e");
     rethrow;
    }  
  }

  Future<void> createElection(String name, String description, int start, int end) async {
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
      
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _createElection,
          parameters: [name, description, BigInt.from(start), BigInt.from(end)],
          maxGas: 3000000,
        ),
        chainId: 1337,
      );
      
      debugPrint("Election creation transaction sent successfully");
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
        final ids = result[0];
        final names = result[1];
        final phases = result[2];
          // Convert the result from blockchain into a list
     return List.generate(ids.length, (i){
      return {
        'id' : ids[i].toInt(),
        'name' : names[i],
        'phase' : phases[i].toInt(),
      };
     });
  }
}