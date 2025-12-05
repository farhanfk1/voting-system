import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ElectionRepository {
  final String _rpcUrl = 'http://127.0.0.1:7545'; 
  final String _privateKey = '0x9516159ce91b1c5d4d1f4597e481fcdd48b951966ec5b5998df661e4d76ee8c8'; 
  final String _contractAddress = '0x3c6BA40962Aade7d6c2199B8d12f0bE3A0c5d8cC';
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
   
  //    if (_contract == null || _createElection == null) {
  //   throw Exception("Contract not initialized");
  // }
  print("name: $name");
  print("description: $description");
  print("start: $start");
  print("end: $end");
  print("_client: $_client");
  print("_credentials: $_credentials");
  print("_contract: $_contract");
  print("_createElection: $_createElection");
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