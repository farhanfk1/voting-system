import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/viewsModel/admin_auth_view_model.dart';
import 'package:voting_system/viewsModel/election_view_model.dart';
import 'package:voting_system/viewsModel/login_view_model.dart';
import 'package:voting_system/viewsModel/vote_view_model.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAMpYbB_W3CRIkeCwzc4V28K3vrjSbbCX4",
  authDomain: "dapp-5ae3c.firebaseapp.com",
  projectId: "dapp-5ae3c",
  storageBucket: "dapp-5ae3c.firebasestorage.app",
  messagingSenderId: "875258730243",
  appId: "1:875258730243:web:62c1176ef6f666cb977b36",
  measurementId: "G-67JZH7EJP7"
      ),
    );
  } else {
    await Firebase.initializeApp(
    ); // For Android/iOS
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ChangeNotifierProvider(create: (_) => AdminAuthViewModel()),
      ChangeNotifierProvider(create: (_) => ElectionViewModel()),
      ChangeNotifierProvider(create: (_) => VoteViewModel()),


    ],
    child:  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voting System',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       initialRoute: RoutesName.login,
       onGenerateRoute: Routes.generateRoute,
    )
    );
    
    
  }
}

