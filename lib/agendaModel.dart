import 'package:flutter/material.dart';

class AgendaItem {
  final String title;
  final Color color;

  AgendaItem({required this.title, required this.color});

  @override
  String toString() => title;

  
}
