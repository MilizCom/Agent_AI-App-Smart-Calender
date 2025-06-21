import 'package:flutter/material.dart';

class DebugShowComponent {
  final BuildContext context;
  const DebugShowComponent(this.context);

  void showBottom(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
