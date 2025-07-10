import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../bin/get_holiday.dart';
import '../services/realtimedb_service.dart';
import '../models/agenda_model.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _holidayDescription = '';
  Map<DateTime, String> _holidays = {};
  final Map<DateTime, AgendaItem?> _cachedAgendas = {};
  final RealtimeDatabase _agendaService = RealtimeDatabase();
  StreamSubscription<AgendaItem?>? _agendaSubscription;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadHolidays();
    _preloadUpcomingAgendas();
    _updateHolidayDescription(_selectedDay!);
    _subscribeToAgenda(_selectedDay!);
  }

  DateTime _normalize(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  bool _isHoliday(DateTime day) =>
      _holidays.keys.any((holiday) => isSameDay(holiday, day));

  void _updateHolidayDescription(DateTime day) {
    if (_isHoliday(day)) {
      _holidayDescription = _holidays.entries
          .firstWhere((entry) => isSameDay(entry.key, day))
          .value;
    } else {
      _holidayDescription = 'Hari ini bukan hari libur.';
    }
  }

  AgendaItem? _getAgendaForDay(DateTime day) {
    final normalized = _normalize(day);
    return _cachedAgendas[normalized];
  }

  void _subscribeToAgenda(DateTime day) {
    final normalized = _normalize(day);
    _agendaSubscription?.cancel();
    _agendaSubscription = _agendaService.listenAgendaForDay(day).listen((item) {
      setState(() {
        _cachedAgendas[normalized] = item;
      });
    });
  }

  Future<void> _loadHolidays() async {
    final data = await getHolidaysFromApi();
    setState(() {
      _holidays = data;
    });
  }

  Future<void> _preloadUpcomingAgendas() async {
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = today.add(Duration(days: i));
      final agenda = await _agendaService.getAgendaForDay(date);
      if (agenda != null) {
        setState(() {
          _cachedAgendas[_normalize(date)] = agenda;
        });
      }
    }
  }

  Future<void> _deleteAgenda(DateTime day) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Agenda'),
        content: const Text('Apakah Anda yakin ingin menghapus agenda ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await _agendaService.deleteAgendaForDay(day);
      setState(() {
        _cachedAgendas.remove(_normalize(day));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agenda berhasil dihapus')),
      );
    }
  }

  @override
  void dispose() {
    _agendaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedAgenda = _getAgendaForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender & Agenda'),
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle), // ikon profil
            onPressed: () {
              Navigator.pushNamed(context, '/profilePage');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _selectedDay = _focusedDay;
                _updateHolidayDescription(_selectedDay!);
                _subscribeToAgenda(_selectedDay!);
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    _updateHolidayDescription(selected);
                  });
                  _subscribeToAgenda(selected);

                  if (_isHoliday(selected)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_holidayDescription,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onPageChanged: (focused) {
                  setState(() => _focusedDay = _normalize(focused));
                },
                holidayPredicate: _isHoliday,
                eventLoader: (day) => _getAgendaForDay(day) != null ? [1] : [],
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                daysOfWeekHeight: 24.0,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800]),
                  weekendStyle: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700]),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.deepPurple, width: 1.0),
                  ),
                  todayTextStyle:
                      const TextStyle(fontSize: 12, color: Colors.black),
                  selectedDecoration: const BoxDecoration(
                      color: Colors.deepPurple, shape: BoxShape.circle),
                  selectedTextStyle:
                      const TextStyle(fontSize: 12, color: Colors.white),
                  outsideTextStyle:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                  holidayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 1.0),
                  ),
                  holidayTextStyle:
                      const TextStyle(fontSize: 12, color: Colors.red),
                  cellMargin: const EdgeInsets.all(2.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_holidayDescription,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  const Text('Agenda:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (selectedAgenda != null) ...[
                    Text('- Judul: ${selectedAgenda.title}'),
                    Text('- Mulai: ${selectedAgenda.mulai}'),
                    Text('- Selesai: ${selectedAgenda.selesai}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/edit_agenda',
                              arguments: {
                                'date': _selectedDay!,
                                'agenda': selectedAgenda
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text('Hapus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _deleteAgenda(_selectedDay!),
                        ),
                      ],
                    ),
                  ] else
                    const Text('(Belum ada agenda)'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addAgenda',
            tooltip: 'Tambah Agenda',
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add_agenda', arguments: {
                'selectedDate': _selectedDay ?? DateTime.now(),
              });
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'prompt',
            tooltip: 'Prompt',
            child: const Icon(Icons.chat_bubble),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              Navigator.pushNamed(context, '/prompt');
            },
          ),
        ],
      ),
    );
  }
}
