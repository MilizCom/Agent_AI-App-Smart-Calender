import 'package:flutter/material.dart';
import 'package:agent_ai_calender/services/firestoredb_service.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<MyProfilePage> {
  final FirestoreDatabase firestore = FirestoreDatabase();
  Map<String, dynamic> userData = {};
  Map<String, dynamic> schedules = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await firestore.getUserData();
    setState(() {
      userData = Map<String, dynamic>.from(data);
      schedules = Map<String, dynamic>.from(data['schedules'] ?? {});
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Background
                    Container(
                      height: constraints.maxHeight * 0.35,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFD6C9E7), Color(0xFFF4F2F9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),

                    // Scrollable content
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
                      child: Column(
                        children: [
                          // Avatar in Stack
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.deepPurple,
                                child: Icon(Icons.person,
                                    size: 50, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            margin: const EdgeInsets.only(top: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    userData['name'] ?? 'Nama Tidak Diketahui',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    userData['email'] ?? '-',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  if ((userData['pekerjaan'] ?? '').isNotEmpty)
                                    ListTile(
                                      leading: const Icon(Icons.work),
                                      title: const Text('Pekerjaan'),
                                      subtitle: Text(userData['pekerjaan']),
                                    ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Jadwal Kerja',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Divider(),
                                  ...schedules.entries.map((entry) {
                                    final day = entry.key;
                                    final mulai = entry.value['mulai'] ?? '-';
                                    final selesai =
                                        entry.value['selesai'] ?? '-';
                                    return ListTile(
                                      title: Text(
                                        '${day[0].toUpperCase()}${day.substring(1)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      trailing: Text('$mulai - $selesai'),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/profile');
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit Profil'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Back + Title
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Profil Saya',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
