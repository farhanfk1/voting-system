import 'package:flutter/material.dart';
import 'package:voting_system/repository/vote_repository.dart';

class VoteViewModel with ChangeNotifier{
  final VoteRepository _repo = VoteRepository();

  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  
  List<Map<String, dynamic>> _elections = [];
  List<Map<String, dynamic>> get elections => _elections;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await _repo.init();
    _elections = await _repo.getElections();
    _isLoading = false;
    notifyListeners();
  }


  Future<void> castVote(BigInt electionId, int candidateIndex) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.vote(electionId, candidateIndex);
    } catch (e) {
      debugPrint("Vote error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getResult(BigInt electionId) async {
    return await _repo.getResult(electionId);
  }

}