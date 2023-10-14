// ignore_for_file: prefer_const_constructors

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

/// Flutter code sample for [BottomNavigationBar].

class ButtonNavigation   extends  StatefulWidget {
  const ButtonNavigation ({super.key});

  @override
  State<ButtonNavigation> createState() => _ButtonNavigationState();
}



class _ButtonNavigationState extends State<ButtonNavigation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: Colors.indigo,
          animationDuration:Duration(milliseconds: 300) ,
          onTap: (index){
            print(index);
          },
          items: [
        Icon(
            Icons.home,
            color:Colors.white),
        Icon(Icons.favorite,
            color:Colors.white),
        Icon(Icons.settings,
            color:Colors.white,
        ),
        Icon(Icons.person,
            color:Colors.white),

      ]
      ),
    );
  }
}

