class UserAuth {
  final String? name;
  final String email;
  final String password;

  UserAuth({this.name, required this.email, required this.password});

  factory UserAuth.fromMap(Map<String, dynamic> map) {
    return UserAuth(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}