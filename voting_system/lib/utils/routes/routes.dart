import 'package:flutter/material.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/views/login.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case RoutesName.login:
      return MaterialPageRoute(builder: (BuildContext context)=> LoginScreen());

       case RoutesName.home:
      return MaterialPageRoute(builder: (BuildContext context)=> LoginScreen());

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