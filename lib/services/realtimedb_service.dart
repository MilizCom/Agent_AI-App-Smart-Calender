import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/agenda_model.dart';

class RealtimeDatabase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("agendas");
  final DatabaseReference _prompt = FirebaseDatabase.instance.ref("prompt");

  String _dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<String?> getPrompt() async {
    final snapshot = await _prompt.get();
    if (!snapshot.exists) return null;
    return snapshot.value as String;
  }

  Future<AgendaItem?> getAgendaForDay(DateTime day) async {
    final snapshot = await _dbRef.child(_dateKey(day)).get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return AgendaItem.fromMap(data);
  }

  Future<void> saveAgendaForDay(DateTime day, AgendaItem item) async {
    final data = item.toMap();
    await _dbRef.child(_dateKey(day)).set(data);
  }

  Future<void> deleteAgendaForDay(DateTime day) async {
    await _dbRef.child(_dateKey(day)).remove();
  }

  Stream<AgendaItem?> listenAgendaForDay(DateTime day) {
    final key = _dateKey(day);
    return _dbRef.child(key).onValue.map((event) {
      if (event.snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return AgendaItem.fromMap(data);
    });
  }

  Future<http.Response> updatePrompt(String prompt) async {
    String promptIdKey = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    await _prompt.child(promptIdKey).set(prompt);
    return http.Response('Prompt updated successfully', 200);
  }
}
