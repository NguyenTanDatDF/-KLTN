import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:todo_kltn/Component/favoritepage.dart';
import 'package:todo_kltn/Component/profilepage.dart';

import 'homepage.dart';
import 'settingpage.dart';

final List<Map<String, dynamic>> pageDetails = [
  {
    'pageName': HomeScreen(
      bgColor: Colors.blue.shade200,
    ),
    'title': 'Home',
    'navigationBarColor': Colors.white,
    'bottom_color': Colors.indigo
  },
  {
    'pageName': FavoriteScreen(
      bgColor: Colors.green.shade200,
    ),
    'title': 'Favorite',
    'navigationBarColor': Colors.white,
    'bottom_color': Colors.green.shade600
  },
  {
    'pageName': SettingScreen(
      bgColor: Colors.pink.shade200
    ),
    'title': 'Setting',
    'navigationBarColor': Colors.white,
    'bottom_color':Colors.pink.shade600
  },
  {
    'pageName': ProfileScreen(
      bgColor: Colors.amber.shade200,
    ),
    'title': 'Profile',
    'navigationBarColor': Colors.white,
    'bottom_color': Colors.amber.shade600
  },
];