import 'dart:async';

import 'package:flutter/material.dart';
import 'package:libirlibir/login.dart';
import 'package:libirlibir/student/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../signup.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  void isLoggedIn(context) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    bool? log = prefs.getBool("isLoggedIn");
    String? type = prefs.getString("type");
    if (type == null || type == "institute") {
      return;
    }
    if (log != null && log == true) {
      Timer(const Duration(seconds: 2), () {
        String? number = prefs.getString("number");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Home(number: number!)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isLoggedIn(context);
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              child: const Text("Login")),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SignUp()));
              },
              child: const Text("Sign Up")),
        ],
      )),
    );
  }
}
