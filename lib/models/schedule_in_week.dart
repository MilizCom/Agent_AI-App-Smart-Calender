class ScheduleInWeek {
  Map<String, Map<String, String>> schedule;

  ScheduleInWeek({required this.schedule});

  Map<String, dynamic> toMap() => schedule;

  factory ScheduleInWeek.fromMap(Map<String, dynamic> map) {
    return ScheduleInWeek(
      schedule: Map<String, Map<String, String>>.from(map.map(
        (key, value) => MapEntry(
          key,
          Map<String, String>.from(value),
        ),
      )),
    );
  }
}
