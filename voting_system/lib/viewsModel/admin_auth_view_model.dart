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

  Future<bool> adminLogin(String email, String password) async {
    _isLoading = true;
    notifyListeners();
  
   try{
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password);

      // Step 2: Allow only specific admin email

    if (userCredential.user != null && email == _adminEmail && password == _adminPassword){
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
    } else{
              // Logged in but not an admin → log out immediately
        await _auth.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
    }

   } on FirebaseAuthException catch (e){
          debugPrint("Login failed: ${e.message}");
      _isLoading = false;
      notifyListeners();
      return false;
   }
  }
  void logout() async{
    await _auth.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }
}
