class UserData {
  final String name;
  final String email;
  final String pekerjaan;
  final Map<String, Map<dynamic, dynamic>> schedules;

  UserData({
    required this.name,
    required this.email,
    required this.pekerjaan,
    required this.schedules,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      pekerjaan: map['pekerjaan'] ?? '',
      schedules: map['schedules'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'pekerjaan': pekerjaan,
      'schedules': schedules,
    };
  }
}
