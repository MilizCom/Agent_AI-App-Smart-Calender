import 'package:flutter/material.dart';

class HeightScreen {
  final BuildContext context;

  HeightScreen(this.context);

  double getHeight() {
    double height = MediaQuery.of(context).size.height;
    double appBarHeight = AppBar().preferredSize.height;
    double bottomBarHeight = MediaQuery.of(context).padding.bottom;
    double topBarHeight = MediaQuery.of(context).padding.top;
    return height - appBarHeight - bottomBarHeight - topBarHeight;
  }
}
