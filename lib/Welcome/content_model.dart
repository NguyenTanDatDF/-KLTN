import 'package:flutter/material.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen(
      {super.key,
      required this.imageUrl,
      required this.heading,
      required this.subheading,
      required this.paragraph,
      required this.headingText});

  final String imageUrl;
  final String heading;
  final String subheading;
  final String paragraph;
  final String headingText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 35, right: 35),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                  border: Border(
                      left: BorderSide(color: Colors.orange, width: 4.0))),
              child: RichText(
                  text: TextSpan(
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      children: [
                    TextSpan(
                      text: headingText,
                      style: TextStyle(color: Colors.indigo),
                    ),
                    TextSpan(
                      text: heading,
                      style: TextStyle(color: Colors.indigo),
                    ),
                  ])),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Image.network(imageUrl),
          const SizedBox(
            height: 40,
          ),
          Text(
            subheading,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.indigo),
          ),
          Text(
            paragraph,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
