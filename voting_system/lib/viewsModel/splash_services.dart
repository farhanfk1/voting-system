import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_system/utils/routes/routes_name.dart';

class SplashServices {

  void checkAuthentication(BuildContext context) async {

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    Timer(const Duration(seconds: 3), () async {

      

      

        if(user != null){
            Navigator.pushReplacementNamed(
              context,
              RoutesName.home,
            );
          }

        else{

          Navigator.pushReplacementNamed(
            context,
            RoutesName.login,
          );

        }
    }
    );

    }

  }

