import 'package:flutter/material.dart';

class StyleButton {
  ButtonStyle decoration({Color? bgColor, EdgeInsetsGeometry? padding}) {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: padding ??
          EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 40.0,
          ),
      elevation: 4.0,
      backgroundColor: bgColor ?? Colors.blue[800],
      // backgroundColor: Color.fromARGB(255, 0, 201, 211),
    );
  }
}
