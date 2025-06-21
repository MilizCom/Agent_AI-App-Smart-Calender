import 'dart:async';

import 'package:agent_ai_calender/bin/get_holiday.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/realtimedb_service.dart';
import '../models/agenda_model.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalendarPage> {
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
    _loadHolidays();
    _preloadUpcomingAgendas();
    _selectedDay = _focusedDay;
    _updateHolidayDescription(_selectedDay!);
    _subscribeToAgenda(_selectedDay!);
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
      final date = DateTime(today.year, today.month, today.day + i);
      final data = await _agendaService.getAgendaForDay(date);
      if (data != null) {
        setState(() {
          _cachedAgendas[_normalize(date)] = data;
        });
      }
    }
  }

  bool _isHoliday(DateTime day) {
    return _holidays.keys.any((holiday) => isSameDay(holiday, day));
  }

  void _updateHolidayDescription(DateTime day) {
    if (_isHoliday(day)) {
      _holidayDescription = _holidays.entries
          .firstWhere((entry) => isSameDay(entry.key, day))
          .value;
    } else {
      _holidayDescription = 'Hari ini bukan hari libur.';
    }
  }

  DateTime _normalize(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  AgendaItem? _getAgendaForDay(DateTime day) {
    _subscribeToAgenda(day);
    final normalized = _normalize(day);
    return _cachedAgendas[normalized];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender & Agenda'),
        backgroundColor: Colors.grey[200],
        actions: [
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
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                daysOfWeekHeight: 24.0,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[700],
                  ),
                ),
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = DateTime.utc(
                      focusedDay.year,
                      focusedDay.month,
                      focusedDay.day,
                    );
                  });
                },
                calendarStyle: CalendarStyle(
                  cellMargin: EdgeInsets.all(2.0),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepPurple,
                      width: 1.0,
                    ),
                  ),
                  todayTextStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  outsideDaysVisible: true,
                  outsideTextStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                  holidayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red,
                      width: 1.0,
                    ),
                  ),
                  holidayTextStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _updateHolidayDescription(selectedDay);
                  });

                  _subscribeToAgenda(selectedDay);

                  if (_isHoliday(selectedDay)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _holidayDescription,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                holidayPredicate: _isHoliday,
                eventLoader: (day) {
                  _subscribeToAgenda(day);
                  return _getAgendaForDay(day) != null ? [1] : [];
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedDay == null
                  ? const Text('Pilih tanggal untuk melihat detail.',
                      style: TextStyle(fontSize: 16))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _holidayDescription,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        const Text('Agenda:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        if (_getAgendaForDay(_selectedDay!) != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '- Judul: ${_getAgendaForDay(_selectedDay!)!.title}'),
                              Text(
                                  '- Mulai: ${_getAgendaForDay(_selectedDay!)!.mulai}'),
                              Text(
                                  '- Selesai: ${_getAgendaForDay(_selectedDay!)!.selesai}'),
                            ],
                          )
                        else
                          const Text('(Belum ada agenda)'),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', false);
          Navigator.pushNamed(context, '/prompt');
        },
        tooltip: 'Prompt',
        child: const Icon(Icons.chat_bubble),
      ),
    );
  }

  @override
  void dispose() {
    _agendaSubscription?.cancel();
    super.dispose();
  }
}
