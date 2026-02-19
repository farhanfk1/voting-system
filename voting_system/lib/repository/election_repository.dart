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
        'description': '', // add description if your contract supports it
      };
     });
  }
}