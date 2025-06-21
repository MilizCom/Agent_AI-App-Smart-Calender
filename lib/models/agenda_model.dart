class AgendaItem {
  final String title;
  final String mulai;
  final String selesai;

  AgendaItem({
    required this.title,
    required this.mulai,
    required this.selesai,
  });

  factory AgendaItem.fromMap(Map<String, dynamic> map) {
    return AgendaItem(
      title: map['title'] ?? '',
      mulai: map['mulai'] ?? '',
      selesai: map['selesai'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mulai': mulai,
      'selesai': selesai,
    };
  }
}
