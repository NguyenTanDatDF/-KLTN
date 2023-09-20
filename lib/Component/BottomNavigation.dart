// ignore_for_file: prefer_const_constructors

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:todo_kltn/Tab/Profile.dart';
import 'package:todo_kltn/Tab/Setting.dart';
import 'package:todo_kltn/Tab/Timeline.dart';

import '../Tab/Voice.dart';
import '../main.dart';

/// Flutter code sample for [BottomNavigationBar].

class ButtonNavigation   extends  StatefulWidget {
  const ButtonNavigation ({super.key});

  @override
  State<ButtonNavigation> createState() => _ButtonNavigationState();

}



class _ButtonNavigationState extends State<ButtonNavigation> {

  final List<Widget> _tabItems = [Voice(),TimeLine(),Setting(),Profile()];
  int _activePage = 0;





  @override
  Widget build(BuildContext context) {





    return Scaffold(




      body: _tabItems[_activePage],
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: Colors.indigo,
          height: 55.0,
          animationDuration:Duration(milliseconds: 300) ,
          onTap: (index){
            print(index);
            setState(() {
              _activePage = index;
            });
          },

          items: [
        Icon(
            Icons.record_voice_over,
            color:Colors.white),
        Icon(Icons.timelapse,
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

