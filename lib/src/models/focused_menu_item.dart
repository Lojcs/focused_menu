import 'package:flutter/material.dart';

class FocusedMenuItem {
  Color? backgroundColor;
  Color? highlightColor;
  Widget title;
  Widget? trailing;
  Function onPressed;

  FocusedMenuItem({
    this.backgroundColor,
    this.highlightColor,
    required this.title,
    this.trailing,
    required this.onPressed,
  });
}
