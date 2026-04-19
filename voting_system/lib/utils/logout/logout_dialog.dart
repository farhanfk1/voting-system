import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/utils/utils.dart';

class LogoutDialog {

  static void show(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () async {

                Navigator.pop(context);

                try {

                  await FirebaseAuth.instance.signOut();

                  if(context.mounted){
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RoutesName.login,
                      (route) => false,
                    );
                  }

                } catch (e) {
                  Utils.toastMessage("Error logging out: $e");
                }

              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),

          ],
        );

      },
    );

  }

}