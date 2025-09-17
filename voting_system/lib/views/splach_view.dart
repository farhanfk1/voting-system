import 'package:flutter/material.dart';
import 'package:voting_system/viewsModel/splach_services.dart';

class Splach_screen extends StatefulWidget {
  const Splach_screen({super.key});

  @override
  State<Splach_screen> createState() => _Splach_screenState();
}

class _Splach_screenState extends State<Splach_screen> {
  SplachServices splachScreen = SplachServices();
  @override
  void initState() {
    super.initState();
    splachScreen.checkAuthentication(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Splach Screen'),
      ),
    );
  }
}