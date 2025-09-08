import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  final VoidCallback onPress;
  const WelcomeButton({super.key,  this.title,required this.onPress,});
   final String? title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:const BorderRadius.only(
            topLeft: Radius.circular(50)
          )
        ),
        child:  Text(
          title!,
          
         style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold
        ),),
      ),
    );
  }
}