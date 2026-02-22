import 'package:flutter/widgets.dart';
import 'package:voting_system/data/models/election_model.dart';
import 'package:voting_system/repository/election_repository.dart';

class ElectionViewModel with ChangeNotifier {

  final ElectionRepository _repo = ElectionRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<ElectionModel> _elections = [];
  List<ElectionModel> get elections => _elections;

  /// ---------------------------
  /// INIT (RUN AFTER FIRST FRAME)
  /// ---------------------------
  Future<void> init() async {
    if (_isInitialized) return; // Prevent multiple calls

    _isLoading = true;
    notifyListeners();

    try {
      await _repo.init(); // smart contract initialization
      debugPrint("Contract initialized successfully!");
      await fetchElections();   // Fetch elections after init
      _isInitialized = true;

    } catch (e) {
      debugPrint("contract initialization failed: $e");

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ---------------------------
  /// CREATE ELECTION
  /// ---------------------------
  Future<void> createElection(
      String name, String description, int start, int end) async {
    
    // Check if contract is initialized before proceeding
    if (!_isInitialized) {
      debugPrint("Contract not initialized. Attempting to initialize...");
      try {
        await init();
      } catch (e) {
        debugPrint("Failed to initialize contract: $e");
        throw Exception("Contract initialization failed. Please try again.");
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _repo.createElection(name, description, start, end);
      await fetchElections(); // Refresh list after creation
      debugPrint("Election created successfully");

    } catch (e) {
      debugPrint('Error creating election: $e');
      rethrow;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ---------------------------
  /// FETCH ALL ELECTIONS
  /// ---------------------------
  Future<void> fetchElections() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repo.getAllElections();
      _elections = response.map((e) => ElectionModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching elections: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCandidate(int electionId, String candidateName) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.addCandidate(electionId, candidateName);
      debugPrint("Candidate added successfully");
    } catch (e) {
      debugPrint("Error adding candidate: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> advancePhase(int electionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.advancePhase(electionId);
      await fetchElections();
      debugPrint("Phase advanced successfully");
    } catch (e) {
      debugPrint("Error advancing phase: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getCandidates(int electionId) async {
    try {
      return await _repo.getCandidates(electionId);
    } catch (e) {
      debugPrint("Error getting candidates: $e");
      rethrow;
    }
  }

  String getPhaseText(int phase) {
    switch (phase) {
      case 0:
        return 'Registration';
      case 1:
        return 'Voting';
      case 2:
        return 'Ended';
      default:
        return 'Unknown';
    }
  }
}
