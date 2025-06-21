import 'package:flutter/material.dart';

class AppbarLayout {
  PreferredSizeWidget getAppBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey[200],
      // backgroundColor: Color.fromARGB(255, 0, 201, 211),
    );
  }
}
