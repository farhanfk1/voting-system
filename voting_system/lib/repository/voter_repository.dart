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
      'hasVoted': false,
    });
  }

  // Check if voter is already registered
  Future<bool> isVoterRegistered() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('voters').doc(uid).get();
    return doc.exists;
  }

  //has already voted
  Future<bool> hasAlreadyVoted() async {
  final uid = _auth.currentUser!.uid;
  final doc = await _firestore.collection('voters').doc(uid).get();
  return doc.exists && doc.data()?['hasVoted'] == true;
}
}
