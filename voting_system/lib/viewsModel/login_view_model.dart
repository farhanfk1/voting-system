
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_system/repository/auth_repository.dart';
import 'package:voting_system/utils/utils.dart';

class LoginViewModel with ChangeNotifier{
  
  final AuthRepository _authRepository = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<void> login({
    required String email,
     required String password,
      required BuildContext context})async{
        setLoading(true);
        try{
          await _authRepository.signIn(email, password);
          Utils.toastMessage("Login Successful");
        } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
      print('The password provided is too weak.');
       } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
       } else {
          Utils.toastMessage(e.message ?? "Login Failed");
             } }finally{
          setLoading(false);
        }
       }

       Future<void>  register({
        required String email,
        required String password,
        required BuildContext context
        })async{
         setLoading(true);
         try{
          await _authRepository.signUp(email, password);
          Utils.toastMessage("SignUp scuccessfuly");
         }on FirebaseAuthException catch (e){
          if(e.code == 'weak-password'){
            Utils.toastMessage("The password provided is too weak");
          } else if(e.code == 'email-already-in-use'){
          Utils.toastMessage('The account already esists for that email');
          } else{
            Utils.toastMessage(e.message ?? "Sign Up Failed");
          }
         }
         finally{
          setLoading(false);
         }
        }
}