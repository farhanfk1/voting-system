
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_system/repository/auth_repository.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/utils/utils.dart';

class LoginViewModel with ChangeNotifier{
  
  final AuthRepository _authRepository = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
     required String password,
      required BuildContext context})async{
        setLoading(true);
        try{
          await _authRepository.signIn(email, password);
          Utils.toastMessage("Login Successful");
          // Move navigation here
         Navigator.pushReplacementNamed(context, RoutesName.home);
          return true;
        } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
      print('The password provided is too weak.');
       } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
       } else {
          Utils.toastMessage(e.message ?? "Login Failed");
             }
             return false;
              }finally{
          setLoading(false);
        }
       }

      Future<void> register({
  required String email,
  required String password,
  required BuildContext context,
  required String name,
  required String cnic,
  required String phone,
  required String dob,
  required String address,
}) async {
  setLoading(true);

  try {
    // Step 1: Create Firebase Auth user
    UserCredential userCredential = await _authRepository.signUp(email, password);
    final uid = userCredential.user!.uid;

    // Step 2: Save voter details in Firestore
    await FirebaseFirestore.instance.collection('voters').doc(uid).set({
      'name': name,
      'email': email,
      'cnic': cnic,
      'phone': phone,
      'dob': dob,
      'address': address,
      'hasVoted': false,
    });

    Utils.toastMessage("SignUp successfully");

    // Optionally: Navigate to login or home
    Navigator.pushNamed(context, RoutesName.login);

  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      Utils.toastMessage("The password provided is too weak");
    } else if (e.code == 'email-already-in-use') {
      Utils.toastMessage('The account already exists for that email');
    } else {
      Utils.toastMessage(e.message ?? "Sign Up Failed");
    }
  } catch (e) {
    Utils.toastMessage(e.toString());
  } finally {
    setLoading(false);
  }

}}