// import 'dart:async';

// import 'package:agent_ai_calender/bin/get_holiday.dart';
// import 'package:agent_ai_calender/components/layouts/appbar.dart';
// import 'package:agent_ai_calender/models/agenda_model.dart';
// // import 'package:agent_ai_calender/services/calendar_service.dart';
// import 'package:agent_ai_calender/services/realtimedb_service.dart';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalendarPage extends StatefulWidget {
//   const CalendarPage({super.key});

//   @override
//   State<CalendarPage> createState() => _CalendarPage2State();
// }

// class _CalendarPage2State extends State<CalendarPage> {
//   CalendarService service = CalendarService();
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   Map<DateTime, String> holidays = {};
//   Map<DateTime, AgendaItem> cachedAgendas = {};
//   String holidayDescription = '';
//   final RealtimeDatabase agendaService = RealtimeDatabase();
//   StreamSubscription<AgendaItem?>? agendaSubscription;

//   @override
//   void initState() {
//     super.initState();
//     loadHolidays();
//   }

//   void subscribeToAgenda(DateTime day) {
//     final normalized = service.normalize(day);
//     agendaSubscription?.cancel();
//     agendaSubscription = agendaService.listenAgendaForDay(day).listen((item) {
//       if (item != null) {
//         setState(() {
//           cachedAgendas[normalized] = item;
//         });
//       }
//     });
//   }

//   Future<void> loadHolidays() async {
//     final data = await getHolidaysFromApi();
//     setState(() {
//       holidays = data;
//     });
//     await service.preloadUpcomingAgendas(cachedAgendas);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppbarLayout().getAppBar('Calendar'),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TableCalendar(
//               firstDay: DateTime.utc(2000, 1, 1),
//               lastDay: DateTime.utc(2100, 12, 31),
//               focusedDay: _focusedDay,
//               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//               onDaySelected: (selectedDay, focusedDay) {
//                 setState(() {
//                   _selectedDay = selectedDay;
//                   _focusedDay = focusedDay;
//                   holidayDescription = service.updateHolidayDescription(
//                     selectedDay,
//                     holidays,
//                   );
//                 });

//                 subscribeToAgenda(selectedDay);

//                 if (service.isHoliday(selectedDay, holidays)) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         holidayDescription,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       backgroundColor: Colors.red,
//                       duration: const Duration(seconds: 2),
//                     ),
//                   );
//                 }
//               },
//               holidayPredicate: (day) {
//                 return service.isHoliday(day, holidays);
//               },
//               eventLoader: (day) {
//                 return service.getAgendaForDay(day, cachedAgendas) != null
//                     ? [1]
//                     : [];
//               },
//               calendarStyle: const CalendarStyle(
//                 todayDecoration: BoxDecoration(
//                   color: Colors.blue,
//                   shape: BoxShape.circle,
//                 ),
//                 selectedDecoration: BoxDecoration(
//                   color: Colors.orange,
//                   shape: BoxShape.circle,
//                 ),
//                 holidayDecoration: BoxDecoration(
//                   color: Colors.redAccent,
//                   shape: BoxShape.circle,
//                 ),
//                 holidayTextStyle: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: _selectedDay == null
//                 ? const Text('Pilih tanggal untuk melihat detail.',
//                     style: TextStyle(fontSize: 16))
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         holidayDescription,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 12),
//                       const Text('Agenda:',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16)),
//                       if (service.getAgendaForDay(
//                               _selectedDay!, cachedAgendas) !=
//                           null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                                 '- Judul: ${service.getAgendaForDay(_selectedDay!, cachedAgendas)!.title}'),
//                             Text(
//                                 '- Mulai: ${service.getAgendaForDay(_selectedDay!, cachedAgendas)!.mulai}'),
//                             Text(
//                                 '- Selesai: ${service.getAgendaForDay(_selectedDay!, cachedAgendas)!.selesai}'),
//                           ],
//                         )
//                       else
//                         const Text('(Belum ada agenda)'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.pushNamed(context, '/prompt'),
//         tooltip: 'Prompt',
//         child: const Icon(Icons.chat_bubble),
//       ),
//     );
//   }
// }
