// import 'package:agent_ai_calender/models/agenda_model.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalendarService {
//   bool isHoliday(DateTime day, Map<DateTime, String> holidays) {
//     return holidays.keys.any((holiday) => isSameDay(holiday, day));
//   }

//   DateTime normalize(DateTime date) {
//     return DateTime.utc(date.year, date.month, date.day);
//   }

//   AgendaItem? getAgendaForDay(
//     DateTime day,
//     Map<DateTime, AgendaItem> cachedAgendas,
//   ) {
//     final normalized = normalize(day);
//     return cachedAgendas[normalized];
//   }

//   String updateHolidayDescription(
//     DateTime day,
//     Map<DateTime, String> holidays,
//   ) {
//     if (isHoliday(day, holidays)) {
//       return holidays.entries
//           .firstWhere((entry) => isSameDay(entry.key, day))
//           .value;
//     } else {
//       return 'Hari ini bukan hari libur.';
//     }
//   }

//   Future<AgendaItem?> preloadUpcomingAgendas(
//     Map<DateTime, AgendaItem> cachedAgendas,
//   ) async {
//     final today = DateTime.now();
//     for (int i = 0; i < 30; i++) {
//       final date = DateTime(today.year, today.month, today.day + i);
//       final data = getAgendaForDay(date, cachedAgendas);
//       if (data != null) {
//         return cachedAgendas[normalize(date)] = data;
//       }
//     }
//     return null;
//   }
// }
