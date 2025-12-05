import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final controller = PageController();
  bool isLastPage = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: [
            buildPage
            (color: Colors.green.shade100,
             urlImage: 'assets/images/ballot.jpg',
              title: "Secure Voting",
               subtitle: "Cast your vote with complete end-to-end encryption powered by blockchain technology.",
               ),
           buildPage
            (color: Colors.blue.shade100,
             urlImage: 'assets/images/time.jpg',
              title: "Transparent Results",
               subtitle: "Every vote is recorded on blockchain, ensuring a 100% transparent and tamper-proof process.",
               ),         
                buildPage
            (color: Colors.green.shade100,
             urlImage: 'assets/images/blockchain.jpg',
              title: "Decentralized System",
               subtitle: "A modern voting system without central control — secure, reliable, and trustless.",
               ),              
          ],
        ),
      ),
      bottomSheet: isLastPage ? TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          
          backgroundColor: Colors.teal.shade700,
          minimumSize: const Size.fromHeight(80)
        
        ),
        onPressed: () async {},
       child: const Text('Get Started',
       style: TextStyle(color: Colors.white,
        fontSize: 24
       ),
       )) : Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 80,
        child: Row(
          children: [
            TextButton(onPressed: () => controller.jumpToPage(2), 
            child: Text('Skip')
            ),
            Center(
              child: SmoothPageIndicator
              (controller: controller,
               count: 3,
              effect: WormEffect(
                spacing: 16,
                dotColor: Colors.black26,
                activeDotColor: Colors.teal.shade100,
              ),
              onDotClicked: (index) => controller.animateToPage(
                index,
                 duration: const Duration(
                  milliseconds: 500
                 ), curve: Curves.easeIn),
              ),
            ),
             TextButton(onPressed: () => controller.nextPage(
              duration: Duration(milliseconds: 500), 
              curve: Curves.easeInOut), 
            child: Text('Next')
            ),           
          ],
        ),
      ),
    );
  }

  Widget buildPage({
    required Color color,
    required String urlImage,
    required String title,
    required String subtitle,
  }) => Container(
    color: color,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          urlImage,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        const SizedBox(height: 64,),
        Text(
          title,
          style: TextStyle(
            color: Colors.teal.shade700,
            fontSize: 32,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 24,),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(subtitle, style: TextStyle(
            color: Colors.black
          ),),
        )
      ],
    ),
  );
}