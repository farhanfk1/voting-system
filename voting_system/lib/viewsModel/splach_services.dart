import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_system/utils/routes/routes_name.dart';

class SplachServices {

void checkAuthentication(BuildContext context){
    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Navigate to home or voter screen
        Navigator.pushReplacementNamed(context, RoutesName.home);
      } else {
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, RoutesName.login);
      }
    });
  }

}