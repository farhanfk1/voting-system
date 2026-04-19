import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AdminAuthViewModel with ChangeNotifier {
    final FirebaseAuth _auth = FirebaseAuth.instance;

  final String _adminEmail = 'farhankhanbamkhel170@gmail.com';
  final String _adminPassword = 'adminfarhan';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final doc = await FirebaseFirestore.instance.collection('admin').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint("Error checking admin status: $e");
      return false;
    }
  }

Future<bool> adminLogin(String email, String password) async {
  _isLoading = true;
  notifyListeners();

  try {
    // Try logging in first
    UserCredential userCredential;

    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
     } 
     catch (e) {
      rethrow;
     }
    

    final user = userCredential.user;
    // Check if correct admin
    if (user != null && email == _adminEmail) {
      _isLoggedIn = true;

      // Firestore check
      final uid = user.uid;
      final doc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('admin').doc(uid).set({
          'name': 'Admin',
          'email': _adminEmail,
          'cnic': '16202-7618540-3',
          'phone': '03159883348',
          'dob': '10/03/2003',
          'address': 'Swabi',
          'hasVoted': false,
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      await _auth.signOut();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  } on FirebaseAuthException catch (e) {
    debugPrint("Admin login failed: ${e.message}");
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  // Admin logout
  Future<void> adminLogout() async {
    try {
      await _auth.signOut();
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error during admin logout: $e");
    }
  }
}