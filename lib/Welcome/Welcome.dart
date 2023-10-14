import 'package:flutter/material.dart';

import 'content_model.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                children: const [
                  OnBoardingScreen(
                    heading: 'Task Voice.',
                    headingText: 'Welcome to ',
                    imageUrl:
                        'https://i.pinimg.com/564x/8f/77/76/8f7776ba639ad8e957bab5f1359c124c.jpg',
                    paragraph:
                        'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document',
                    subheading: 'Direct Message',
                  ),
                  OnBoardingScreen(
                    heading: 'Task Voice.',
                    headingText: 'Welcome to ',
                    imageUrl:
                        'https://i.pinimg.com/564x/76/50/58/76505822c73746520ea90bea00bca03b.jpg',
                    paragraph:
                        'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document',
                    subheading: 'Create Videos',
                  ),
                  OnBoardingScreen(
                    heading: 'Task Voice.',
                    headingText: 'Welcome to ',
                    imageUrl:
                        'https://i.pinimg.com/564x/12/31/3b/12313b622d7f98a3b9703400dde29d0f.jpg',
                    paragraph:
                        'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document',
                    subheading: 'Direct Message',
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 12,
              child: ListView.builder(
                  itemCount: 3,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 12,
                      width: 12,
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Color.fromARGB(255, 255, 166, 74)
                              : Colors.indigo,
                          borderRadius: BorderRadius.circular(50)),
                    );
                  }),
            ),
            const SizedBox(
              height: 40,
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                  height: 60,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                          duration: Duration(microseconds: 500),
                          curve: Curves.ease);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor:
                            const Color.fromARGB(255, 255, 166, 74)),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ));
  }
}
