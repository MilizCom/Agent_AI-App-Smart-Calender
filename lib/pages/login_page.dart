import 'package:agent_ai_calender/components/debug_show.dart';
import 'package:agent_ai_calender/components/styles/button_style.dart';
import 'package:agent_ai_calender/components/styles/leading_input.dart';
import 'package:agent_ai_calender/models/auth_model.dart';
import 'package:agent_ai_calender/models/height_screen.dart';
import 'package:agent_ai_calender/services/firestoredb_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirestoreDatabase firestore = FirestoreDatabase();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool togled = false;

  Future<void> signingIn(
      BuildContext context, DebugShowComponent debugShow) async {
    if (_formKey.currentState!.validate()) {
      final userData = UserAuth(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final res = await firestore.loginUser(userData);

      if (res.statusCode == 200) {
        // Ambil data user setelah login
        final profileData = await firestore.getUserData();

        final isProfileComplete = profileData['pekerjaan'] != null &&
            profileData['pekerjaan'].toString().isNotEmpty &&
            profileData['schedules'] != null &&
            (profileData['schedules'] as Map).isNotEmpty;

        if (isProfileComplete) {
          Navigator.pushNamed(context, '/calendar');
        } else {
          Navigator.pushNamed(context, '/profile');
        }
      } else {
        debugShow.showBottom(res.body);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          children: [
            Container(
              height: HeightScreen(context).getHeight(),
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/images/Logo.png',
                  ),
                  Form(
                    key: _formKey,
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.grey[400],
                      ),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        // KOspacing: 8.0,
                        children: [
                          TextFieldWithLeading().build(
                            'Email',
                            controller: emailController,
                            bgColor: Colors.white,
                            validator: 'Email tidak boleh kosong',
                            icon: Icons.email,
                          ),
                          TextFieldWithLeading().build(
                            'Password',
                            controller: passwordController,
                            bgColor: Colors.white,
                            validator: 'Password tidak boleh kosong',
                            icon: Icons.lock,
                            obscureText: togled ? false : true,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: togled,
                                onChanged: (value) {
                                  setState(() {
                                    togled = !togled;
                                  });
                                },
                              ),
                              Text('Show Password'),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Belum punya akun? ",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: Text(
                                  "Daftar disini!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        signingIn(context, DebugShowComponent(context));
                      },
                      style: StyleButton().decoration(),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
