import 'package:flutter/material.dart';
import 'package:voting_system/widgets/colors.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final double height;
  final double width;
  final bool loading;

  const RoundButton({super.key,
  this.height =40,
   this.width = 200,
    required this.onPress,
    required this.title,
    this.loading = false
    });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onPress,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: loading ? CircularProgressIndicator(color: Colors.white,) : Text(title, style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor),),
        ),
      ),
    );
  }
}