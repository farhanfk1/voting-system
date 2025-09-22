import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register voter
  Future<void> registerVoter(String name, String cnic) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('voters').doc(uid).set({
      'name': name,
      'cnic': cnic,
      'votedElections': [],
    });
  }

  // Check if voter is already registered
  Future<bool> isVoterRegistered() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('voters').doc(uid).get();
    return doc.exists;
  }

  //has already voted
  Future<bool> hasAlreadyVoted(BigInt electionId) async {
  final uid = _auth.currentUser!.uid;
  final doc = await _firestore.collection('voters').doc(uid).get();


    if (doc.exists) {
      final data = doc.data();
      List<dynamic> votedElections = data?['votedElections'] ?? [];
      return votedElections.contains(electionId.toString());
    }
    return false;}

    Future<void> markAsVoted(BigInt electionId) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('voters').doc(uid).update({
      'votedElections': FieldValue.arrayUnion([electionId.toString()]),
    });
  }
}
