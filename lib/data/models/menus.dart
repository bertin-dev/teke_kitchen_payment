import 'package:flutter/material.dart';

class Menus {
  Menus(this.title, this.icon, this.color, this.inactiveIcon);
  final String title;
  final Color color;
  final Widget icon;
  final Widget inactiveIcon;
}
