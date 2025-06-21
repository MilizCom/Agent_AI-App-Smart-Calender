import 'package:agent_ai_calender/components/debug_show.dart';
import 'package:agent_ai_calender/components/layouts/appbar.dart';
import 'package:agent_ai_calender/components/styles/button_style.dart';
import 'package:agent_ai_calender/components/styles/input_decoration.dart';
import 'package:agent_ai_calender/components/time_picker.dart';
import 'package:agent_ai_calender/services/firestoredb_service.dart';
import 'package:agent_ai_calender/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreDatabase firestore = FirestoreDatabase();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pekerjaanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> _userData = {};
  final Map<String, Map<dynamic, dynamic>> schedules = {
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
  Map<String, dynamic> selectedSchedules = {};
  final TimePickerComponent timePicker = TimePickerComponent();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pekerjaanController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    _userData = await firestore.getUserData();
    setState(() {
      nameController.text = _userData['name'] ?? '';
      emailController.text = _userData['email'];
    });
  }

  Future<void> fillData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (isScheduleComplete()) {
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
      } else {
        DebugShowComponent(context).showBottom('Schedule belum lengkap');
      }
    }
  }

  bool isScheduleComplete() {
    for (final entry in schedules.entries) {
      final mulai = entry.value['mulai'];
      final selesai = entry.value['selesai'];
      if (mulai == null ||
          mulai.isEmpty ||
          selesai == null ||
          selesai.isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarLayout().getAppBar('Isi Data Anda'),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 8.0,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: StyleTextField().decoration('Name',
                          bgColor: Colors.white, enabled: false),
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: StyleTextField().decoration('Email',
                          bgColor: Colors.white, enabled: false),
                    ),
                    TextFormField(
                      controller: pekerjaanController,
                      validator: (value) {
                        return value == ''
                            ? 'Pekerjaan tidak boleh kosong'
                            : null;
                      },
                      decoration: StyleTextField().decoration(
                        'Pekerjaan',
                        bgColor: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Waktu Kerja',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Column(
                      children: schedules.keys.map((day) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${day[0].toUpperCase()}${day.substring(1)}:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                timePicker.timeInput(
                                  context: context,
                                  label: schedules[day]!['mulai'] != ''
                                      ? schedules[day]!['mulai']!
                                      : 'Mulai',
                                  onSelected: (value) {
                                    setState(() {
                                      schedules[day]!['mulai'] = value;
                                    });
                                  },
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('s/d'),
                                ),
                                timePicker.timeInput(
                                  context: context,
                                  label: schedules[day]!['selesai'] != ''
                                      ? schedules[day]!['selesai']!
                                      : 'Selesai',
                                  onSelected: (value) {
                                    setState(() =>
                                        schedules[day]!['selesai'] = value);
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => fillData(context),
                      style: StyleButton().decoration(),
                      child: const Text(
                        'Lanjut',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
