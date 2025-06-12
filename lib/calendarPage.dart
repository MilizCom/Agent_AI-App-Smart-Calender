// file: CalenderPage.dart

import 'dart:async';

import 'package:agent_ai_calender/getterHarilibur.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'agendaService.dart';
import 'agendaModel.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _holidayDescription = '';
  Map<DateTime, String> _holidays = {};
  final Map<DateTime, List<AgendaItem>> _cachedAgendas = {};
  final AgendaService _agendaService = AgendaService();
  StreamSubscription<List<AgendaItem>>? _agendaSubscription;

  @override
  void initState() {
    super.initState();
    _loadHolidays();
    _preloadUpcomingAgendas();
    _selectedDay = _focusedDay;
    _updateHolidayDescription(_selectedDay!);
  }

  void _subscribeToAgenda(DateTime day) {
    final normalized = _normalize(day);
    _agendaSubscription?.cancel(); // Cancel subscription sebelumnya jika ada
    _agendaSubscription =
        _agendaService.listenAgendaForDay(day).listen((items) {
      setState(() {
        _cachedAgendas[normalized] = items;
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
      if (data.isNotEmpty) {
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

  List<AgendaItem> _getAgendaForDay(DateTime day) {
    final normalized = _normalize(day);
    return _cachedAgendas[normalized] ?? [];
  }

  Future<void> _showEditAgendaDialog(DateTime date) async {
    final normalized = _normalize(date);
    final List<AgendaItem> current =
        List.from(_cachedAgendas[normalized] ?? []);

    final TextEditingController controller = TextEditingController();
    Color selectedColor = Colors.green;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tambah Agenda', style: TextStyle(fontSize: 18)),
                  TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(labelText: 'Deskripsi agenda'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Pilih warna: "),
                      Wrap(
                        spacing: 6,
                        children: [
                          Colors.green,
                          Colors.blue,
                          Colors.red,
                          Colors.orange,
                          Colors.purple,
                        ].map((color) {
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedColor = color;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: color,
                              radius: 12,
                              child: selectedColor == color
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        current
                            .add(AgendaItem(title: text, color: selectedColor));
                        await _agendaService.saveAgendaForDay(
                            normalized, current);
                        setState(() {
                          _cachedAgendas[normalized] = current;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                  if (current.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await _agendaService.saveAgendaForDay(normalized, []);
                        setState(() {
                          _cachedAgendas.remove(normalized);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Hapus Semua Agenda',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender & Agenda')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _updateHolidayDescription(selectedDay);
              });

              _subscribeToAgenda(selectedDay); // Mulai berlangganan agenda

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
            eventLoader: _getAgendaForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              holidayDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              holidayTextStyle: TextStyle(color: Colors.white),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(3).map((e) {
                    final agenda = e as AgendaItem;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: agenda.color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
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
                      ..._getAgendaForDay(_selectedDay!)
                          .map((e) => Text('- ${e.title}')),
                      if (_getAgendaForDay(_selectedDay!).isEmpty)
                        const Text('(Belum ada agenda)'),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditAgendaDialog(_selectedDay!),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Agenda'),
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _agendaSubscription?.cancel();
    super.dispose();
  }
}
