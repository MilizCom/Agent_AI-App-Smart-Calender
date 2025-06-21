import 'package:agent_ai_calender/pages/calendar_page.dart';
import 'package:agent_ai_calender/pages/login_page.dart';
import 'package:agent_ai_calender/pages/profile_page.dart';
import 'package:agent_ai_calender/pages/prompt_page.dart';
import 'package:agent_ai_calender/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child,
        );
      },
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/calendar': (context) => CalendarPage(),
        '/profile': (context) => ProfilePage(),
        '/prompt': (context) => PromptPage(),
      },
      home: isLoggedIn ? CalendarPage() : LoginPage(),
    );
  }
}
