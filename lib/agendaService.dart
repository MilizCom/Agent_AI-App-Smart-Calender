import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'agendaModel.dart';

class AgendaService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("agendas");

  DateTime _normalize(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  String _dateKey(DateTime date) =>
      _normalize(date).toIso8601String().split('T').first;

  Future<List<AgendaItem>> getAgendaForDay(DateTime day) async {
    final snapshot = await _dbRef.child(_dateKey(day)).get();
    if (!snapshot.exists) return [];

    final List data = jsonDecode(jsonEncode(snapshot.value));
    return data
        .map((e) => AgendaItem(
              title: e['title'],
              color: Color(int.parse(e['color'].toString())),
            ))
        .toList();
  }

  Future<void> saveAgendaForDay(DateTime day, List<AgendaItem> items) async {
    final data = items
        .map((e) => {
              'title': e.title,
              'color': e.color.value.toString(),
            })
        .toList();

    if (data.isEmpty) {
      await _dbRef.child(_dateKey(day)).remove();
    } else {
      await _dbRef.child(_dateKey(day)).set(data);
    }
  }

  Stream<List<AgendaItem>> listenAgendaForDay(DateTime day) {
    final normalizedKey = _dateKey(day);
    return _dbRef.child(normalizedKey).onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final List data = jsonDecode(jsonEncode(event.snapshot.value));
      return data
          .map<AgendaItem>((e) => AgendaItem(
                title: e['title'],
                color: Color(int.parse(e['color'].toString())),
              ))
          .toList();
    });
  }
}
