import 'package:flutter/material.dart';
import 'package:agent_ai_calender/components/debug_show.dart';
import 'package:agent_ai_calender/components/layouts/appbar.dart';
import 'package:agent_ai_calender/components/styles/input_decoration.dart';
import 'package:agent_ai_calender/components/time_picker.dart';
import 'package:agent_ai_calender/services/firestoredb_service.dart';
import 'package:agent_ai_calender/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreDatabase firestore = FirestoreDatabase();
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pekerjaanController = TextEditingController();

  final Map<String, Map<String, String>> schedules = {
    for (var day in [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu'
    ])
      day: {'mulai': '', 'selesai': ''}
  };

  final TimePickerComponent timePicker = TimePickerComponent();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pekerjaanController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final data = await firestore.getUserData();
    if (mounted) {
      setState(() {
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        pekerjaanController.text = data['pekerjaan'] ?? '';
        if (data['schedules'] != null && data['schedules'] is Map) {
          final savedSchedules = Map<String, dynamic>.from(data['schedules']);
          for (final day in schedules.keys) {
            if (savedSchedules[day] is Map) {
              final dayMap = Map<String, dynamic>.from(savedSchedules[day]);
              schedules[day]!['mulai'] = dayMap['mulai'] ?? '';
              schedules[day]!['selesai'] = dayMap['selesai'] ?? '';
            }
          }
        }
      });
    }
  }

  bool _isScheduleComplete() {
    for (final day in schedules.values) {
      if (day['mulai']!.isEmpty || day['selesai']!.isEmpty) return false;
    }
    return true;
  }

  Future<void> _submitProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!_isScheduleComplete()) {
        DebugShowComponent(context).showBottom('Schedule belum lengkap');
        return;
      }

      final userData = UserData(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        pekerjaan: pekerjaanController.text.trim(),
        schedules: schedules,
      );

      final res = await firestore.storeData(userData);
      if (res.statusCode == 200) {
        Navigator.pushNamed(context, '/calendar');
      } else {
        DebugShowComponent(context).showBottom(res.body);
      }
    }
  }

  Widget _buildScheduleRow(String day) {
    final label = '${day[0].toUpperCase()}${day.substring(1)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFFD6C9E7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: timePicker.timeInput(
                    context: context,
                    label: schedules[day]!['mulai']!.isNotEmpty
                        ? schedules[day]!['mulai']!
                        : 'Mulai',
                    onSelected: (value) {
                      setState(() {
                        schedules[day]!['mulai'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Text('s/d',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: timePicker.timeInput(
                    context: context,
                    label: schedules[day]!['selesai']!.isNotEmpty
                        ? schedules[day]!['selesai']!
                        : 'Selesai',
                    onSelected: (value) {
                      setState(() {
                        schedules[day]!['selesai'] = value;
                      });
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      appBar: AppbarLayout().getAppBar('Profil Pengguna'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // === Identitas Pengguna ===
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFFD6C9E7),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        enabled: false,
                        decoration: StyleTextField().decoration(
                          'Nama',
                          bgColor: Colors.white,
                          icon: Icons.person,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: StyleTextField().decoration(
                          'Email',
                          bgColor: Colors.white,
                          icon: Icons.email,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: pekerjaanController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Pekerjaan tidak boleh kosong'
                            : null,
                        decoration: StyleTextField().decoration(
                          'Pekerjaan',
                          bgColor: Colors.white,
                          icon: Icons.work,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // === Header Jadwal + Scrollable Jadwal ===
              Row(
                children: const [
                  Icon(Icons.schedule, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(
                    'Waktu Kerja Mingguan',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // === Scroll hanya untuk daftar jadwal ===
              Expanded(
                child: ListView.builder(
                  itemCount: schedules.keys.length,
                  itemBuilder: (context, index) {
                    final day = schedules.keys.elementAt(index);
                    return _buildScheduleRow(day);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // === Tombol Simpan ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Simpan dan Lanjut',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _submitProfile(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
