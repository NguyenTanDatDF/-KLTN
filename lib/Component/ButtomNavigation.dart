import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:todo_kltn/Component/tab_map.dart';
class TabBarScreen  extends StatefulWidget {
  const TabBarScreen ({Key? key}):super(key:key);

  @override
  State<TabBarScreen> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  int _activePageIndex=0;
  final PageController _pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(

        backgroundColor: pageDetails[_activePageIndex]['bottom_color'],
      ) ,
      body:PageView(
        controller:_pageController ,
          onPageChanged: (index){
            setState(() {
              _activePageIndex = index;
            });
          },
          children: [
        pageDetails[0]['pageName'],
        pageDetails[1]['pageName'],
        pageDetails[2]['pageName'],
        pageDetails[3]['pageName'],

      ]) ,
      bottomNavigationBar: CurvedNavigationBar(
        color: pageDetails[_activePageIndex]['bottom_color'],
        backgroundColor: pageDetails[_activePageIndex]['navigationBarColor'],
        index: _activePageIndex,
        onTap: (index){
          _pageController.animateToPage(index, duration: const Duration(microseconds: 400), curve: Curves.ease,);

        },
        items:const [
          Icon(
              Icons.home,
              color:Colors.white),
          Icon(Icons.event,
              color:Colors.white),

          Icon(Icons.view_list,
              color:Colors.white),
          Icon(Icons.settings,
              color:Colors.white
          ),
        ],

      ),
    );
  }
}
