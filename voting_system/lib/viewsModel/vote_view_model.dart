import 'package:flutter/material.dart';
import 'package:voting_system/repository/election_repository.dart';
import 'package:voting_system/repository/vote_repository.dart';
import 'package:voting_system/repository/voter_repository.dart';
import 'package:voting_system/repository/wallet_assignment_repository.dart';

class VoteViewModel with ChangeNotifier {
  final ElectionRepository _electionRepo = ElectionRepository();
  final VoteRepository _repo = VoteRepository();
  final VoterRepository _voterRepo = VoterRepository();
  final WalletAssignmentRepository _walletRepo = WalletAssignmentRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _elections = [];
  List<Map<String, dynamic>> get elections => _elections;

  bool _isInitialized = false;

  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _electionRepo.init();
      await _repo.init();

      final data = await _electionRepo.getAllElections();
      _elections = List<Map<String, dynamic>>.from(data);
      _isInitialized = true;
    } catch (e) {
      debugPrint("INIT ERROR: $e");
    } finally {
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
      await _walletRepo.ensureWalletAssigned();

      final electionIdBig = BigInt.from(electionId);
      final alreadyVoted = await _voterRepo.hasAlreadyVoted(electionIdBig);
      if (alreadyVoted) {
        return 'You have already voted in this election.';
      }

      final privateKey = await _walletRepo.getPrivateKeyForCurrentUser();
      if (privateKey == null) {
        throw Exception(
          'No Ganache wallet assigned. Please log out and sign in again.',
        );
      }

      await _repo.vote(
        electionIdBig,
        candidateIndex,
        voterPrivateKey: privateKey,
      );

      await _voterRepo.markAsVoted(electionIdBig);
      return 'Vote cast successfully!';
    } catch (e) {
      debugPrint("Vote error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<Map<String, dynamic>> getResult(int electionId) async {
    await _ensureInitialized();
    return await _repo.getResult(BigInt.from(electionId));
  }
}
