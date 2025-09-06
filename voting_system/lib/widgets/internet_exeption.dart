import 'package:flutter/material.dart';

class InternetException extends StatelessWidget {
  final VoidCallback onPress;
  const InternetException({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .15,
        ),
        const Icon(Icons.cloud_off,
        color: Colors.red,
        size: 50,
        ),
        Padding(padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: Text('we are unable to show results. \nplease check your data \n connection.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 20),
          ),
        ),
        ),
          SizedBox(
          height: MediaQuery.sizeOf(context).height * .15,
        ),
        ElevatedButton(
          onPressed: onPress,
         child: Center(
          child: Text('RETRY', style:  Theme.of(context).textTheme.bodySmall,),
         )
         ),
      ],
    );
  }
}