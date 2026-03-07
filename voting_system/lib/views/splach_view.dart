import 'package:flutter/material.dart';
import 'package:voting_system/viewsModel/splach_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final SplashServices splashService = SplashServices();

  @override
  void initState() {
    super.initState();
    splashService.checkAuthentication(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}