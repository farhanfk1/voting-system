import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_system/utils/utils.dart';
import 'package:voting_system/widgets/reusable_textfield.dart';
import 'package:voting_system/widgets/round_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Passsword'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           ReusableTextFormField(
            controller: emailController, 
            hintText: 'Forgot Password', 
            labelText: 'Forgot Password'),
        
            SizedBox(height: 15,),
        
            RoundButton(onPress: (){
          auth.sendPasswordResetEmail(email: emailController.text.toString()).then((value){
       Utils.toastMessage('We have send you email to recover password, plz check email');
          }).onError((error, stackTrace){
        Utils.toastMessage(error.toString());
          });
            }, 
            title: 'Forgot')
          ],
        ),
      ),
    );
  }
}