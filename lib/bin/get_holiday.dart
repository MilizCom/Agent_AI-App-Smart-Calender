import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

Future<Map<DateTime, String>> getHolidaysFromApi() async {
  final url = Uri.parse('https://api-harilibur.vercel.app/api');
  final DatabaseReference _holidayRef =
      FirebaseDatabase.instance.ref("holidays");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final Map<DateTime, String> holidays = {};

      for (var item in data) {
        final String dateStr = item['holiday_date']; // format: "2025-12-25"
        final String name = item['holiday_name'];

        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final int year = int.parse(parts[0]);
          final int month = int.parse(parts[1]);
          final int day = int.parse(parts[2]);

          final DateTime date = DateTime.utc(year, month, day);
          holidays[date] = name;

          // Simpan ke Firebase: key = yyyy-mm-dd
          await _holidayRef.child(dateStr).set(name);
        }
      }

      return holidays;
    } else {
      throw Exception('Gagal mengambil data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error mengambil data hari libur: $e');
    return {};
  }
}
