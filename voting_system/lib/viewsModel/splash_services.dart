import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_system/utils/routes/routes_name.dart';

class SplashServices {

  void checkAuthentication(BuildContext context){

    final auth = FirebaseAuth.instance;

    Timer(const Duration(seconds: 3), () {

      final user = auth.currentUser;

      if(context.mounted){

        if(user != null){

          Navigator.pushReplacementNamed(
            context,
            RoutesName.home,
          );

        }else{

          Navigator.pushReplacementNamed(
            context,
            RoutesName.login,
          );

        }

      }

    });

  }

}