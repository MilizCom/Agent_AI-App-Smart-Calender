import 'package:agent_ai_calender/models/auth_model.dart';
import 'package:agent_ai_calender/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreDatabase {
  Future<Map> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      print(userData);
      if (userData.exists) {
        return userData.data() as Map<String, dynamic>;
      }
    }
    return {};
  }

  Future<bool> saveToFireStore(UserAuth userData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.displayName == null) {
          await user.updateDisplayName(userData.name);
        }
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email,
        });
        print('Successfully saved to Firestore');
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving to Firestore: $e');
      return false;
    }
  }

  Future<http.Response> registerUser(UserAuth userData) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userData.email,
        password: userData.password,
      );
      bool registered = await saveToFireStore(userData);
      if (userCredential.user != null && registered) {
        return http.Response(
          '{name: ${userData.name}, email: ${userData.email}}',
          200,
        );
      }
      return http.Response('Failed to register user', 400);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return http.Response('The password provided is too weak.', 400);
      } else if (e.code == 'email-already-in-use') {
        return http.Response('The account already exists for that email.', 400);
      }
      return http.Response('Unknown error: ${e.code}', 400);
    } catch (e) {
      return http.Response('Failed error: $e', 400);
    }
  }

  Future<http.Response> loginUser(UserAuth userData) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userData.email,
        password: userData.password,
      );

      if (userCredential.user == null) {
        return http.Response('User not authenticated', 401);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      // ❌ Jangan panggil saveToFireStore di sini
      return http.Response('Login successful', 200);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return http.Response('No user found for that email.', 400);
      } else if (e.code == 'wrong-password') {
        return http.Response('Wrong password provided for that user.', 400);
      } else if (e.code == 'invalid-email') {
        return http.Response('The email address is not valid.', 400);
      }
      return http.Response('Unknown error: ${e.code}', 400);
    } catch (e) {
      return http.Response('Failed error: $e', 400);
    }
  }

  Future<http.Response> storeData(UserData userData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return http.Response('User not authenticated', 401);
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': userData.name,
        'email': userData.email,
        'pekerjaan': userData.pekerjaan,
        'schedules': userData.schedules,
      });
      return http.Response('Data stored successfully', 200);
    } catch (e) {
      return http.Response('Failed to store data: $e', 400);
    }
  }
}
