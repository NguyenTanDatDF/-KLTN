import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
class ProfileScreen extends StatelessWidget {
  Color bgColor;
  ProfileScreen({
    Key? key,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
    );
  }
}

