import 'package:agent_ai_calender/components/debug_show.dart';
import 'package:agent_ai_calender/components/layouts/appbar.dart';
import 'package:agent_ai_calender/components/styles/button_style.dart';
import 'package:agent_ai_calender/components/styles/input_decoration.dart';
import 'package:agent_ai_calender/models/auth_model.dart';
import 'package:agent_ai_calender/models/height_screen.dart';
import 'package:agent_ai_calender/services/firestoredb_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final FirestoreDatabase firestore = FirestoreDatabase();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> registering(
    BuildContext context,
    DebugShowComponent debugShow,
  ) async {
    if (_formKey.currentState!.validate() &&
        passwordController.text == confirmPasswordController.text) {
      final userData = UserAuth(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final res = await firestore.registerUser(userData);
      if (res.statusCode == 200) {
        Navigator.pop(context);
      } else {
        debugShow.showBottom(res.body);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarLayout().getAppBar('Register'),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          children: [
            Container(
              height: HeightScreen(context).getHeight(),
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        spacing: 8.0,
                        children: [
                          TextFormField(
                            controller: nameController,
                            validator: (value) {
                              return value == ''
                                  ? 'Name tidak boleh kosong'
                                  : null;
                            },
                            decoration: StyleTextField().decoration(
                              'Name',
                              bgColor: Colors.white,
                            ),
                          ),
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              return value == ''
                                  ? 'Email tidak boleh kosong'
                                  : null;
                            },
                            decoration: StyleTextField().decoration(
                              'Email',
                              bgColor: Colors.white,
                            ),
                          ),
                          TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              return value == ''
                                  ? 'Password tidak boleh kosong'
                                  : null;
                            },
                            decoration: StyleTextField().decoration(
                              'Password',
                              bgColor: Colors.white,
                            ),
                            obscureText: true,
                          ),
                          TextFormField(
                            controller: confirmPasswordController,
                            validator: (value) {
                              return value == ''
                                  ? 'Konfirmasi ulang password Anda'
                                  : null;
                            },
                            decoration: StyleTextField().decoration(
                              'Confirm Password',
                              bgColor: Colors.white,
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      onPressed: () => registering(
                        context,
                        DebugShowComponent(context),
                      ),
                      style: StyleButton().decoration(),
                      child: const Text(
                        'Daftar',
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
