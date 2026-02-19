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
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Stack(
        children:[ 
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
            )
          ),
        ),
         Positioned(
          top: -60,
         left: -40,
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          )
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            )
            ),        
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ReusableTextFormField(
                  controller: emailController,
                  hintText: "Enter Email",
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid Email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15,),
                RoundButton(
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      auth.sendPasswordResetEmail(email: emailController.text.trim())
                          .then((value) {
                        Utils.toastMessage(
                            'We have sent you email to recover password, please check email');
                      }).onError((error, stackTrace) {
                        Utils.toastMessage(error.toString());
                      });
                    }
                  },
                  title: 'Forgot',
                )
              ],
            ),
          ),
        ),
        ]
      ),
    );
  }
}