import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

Future<UserCredential> signIn(String email, String password)async{
  
  return await _firebaseAuth.signInWithEmailAndPassword(
    email: email,
     password: password
     );
}   


Future<UserCredential> signUp(String email, String password)async{
  
  return await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
     password: password
     );
} 
      User? get currentUser => _firebaseAuth.currentUser;

Future<void> signOut()async{
    await _firebaseAuth.signOut();
}

}