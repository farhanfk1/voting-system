import 'package:flutter/material.dart';
import 'package:voting_system/repository/election_repository.dart';
import 'package:voting_system/repository/vote_repository.dart';

class VoteViewModel with ChangeNotifier{
  final ElectionRepository _electionRepo = ElectionRepository();
  final VoteRepository _repo = VoteRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  
  List<Map<String, dynamic>> _elections = [];
  List<Map<String, dynamic>> get elections => _elections;

  // Track voted elections locally since VoterRepository is commented out
  Set<int> _votedElections = {};

  Future<void> init() async {

    try {
         _isLoading = true;
    notifyListeners();
    await _electionRepo.init();
    await _repo.init();
     
    final data = await _electionRepo.getAllElections();
    _elections = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint("INIT ERROR: $e");
    }finally {
      _isLoading = false;
      notifyListeners();
    }
 
     } 
  Future<List<Map<String, dynamic>>> getCandidates(int electionId) async {
  return await _electionRepo.getCandidates(electionId);
}

  Future<String> castVote(int electionId, int candidateIndex) async {
    _isLoading = true;
    notifyListeners();
    try {
    //  Check if voter already voted locally
    if (_votedElections.contains(electionId)) {
      throw Exception("Already voted");
    }
    
    //  Cast vote on blockchain
      await _repo.vote(BigInt.from(electionId), candidateIndex);
      
    // Mark as voted locally
    _votedElections.add(electionId);
      
    return "Vote cast successfully!";
    } catch (e) {
      debugPrint("Vote error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getResult(int electionId) async {
    return await _repo.getResult(BigInt.from(electionId));
  }



}
