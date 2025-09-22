import 'package:flutter/material.dart';
import 'package:voting_system/repository/vote_repository.dart';
import 'package:voting_system/repository/voter_repository.dart';

class VoteViewModel with ChangeNotifier{
  final VoteRepository _repo = VoteRepository();
final VoterRepository _voterRepo = VoterRepository();
  
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


  Future<String> castVote(BigInt electionId, int candidateIndex) async {
    _isLoading = true;
    notifyListeners();
    try {
    //  Check if voter already voted

    final alreadyVoted = await _voterRepo.hasAlreadyVoted(electionId);
     if (alreadyVoted) {
        return "You have already voted in this election.";
      }
    //  Cast vote on blockchain
      await _repo.vote(electionId, candidateIndex);
    //   Mark as voted in Firestore
    await _voterRepo.markAsVoted(electionId);
    return "Vote cast successfully!";
    } catch (e) {
      debugPrint("Vote error: $e");
      return "Voting failed. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getResult(BigInt electionId) async {
    return await _repo.getResult(electionId);
  }

}