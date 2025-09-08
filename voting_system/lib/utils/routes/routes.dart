import 'package:flutter/material.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/views/home.dart';
import 'package:voting_system/views/login.dart';
import 'package:voting_system/views/signup.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
     

      case RoutesName.login:
      return MaterialPageRoute(builder: (BuildContext context)=> LoginScreen());

       case RoutesName.signup:
      return MaterialPageRoute(builder: (BuildContext context)=> SignUpScreen());
      
      case RoutesName.home:
      return MaterialPageRoute(builder: (BuildContext context)=> HomeScreen());

      default: 
      return MaterialPageRoute(builder: (_){
       return Scaffold(
        body: Center(
          child: Text("No Route Found"),
        ),
       );
      });
    }
  }
}