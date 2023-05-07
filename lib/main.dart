import 'dart:async';

import 'package:libirlibir/institution/enter.dart';
import 'package:libirlibir/institution/landingpage.dart';
import 'package:libirlibir/signup.dart';
import 'package:libirlibir/student/home.dart';
import 'package:libirlibir/student/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHomePage> {
  bool logIn = false;

  void isLoggedIn(context) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    bool? log = prefs.getBool("isLoggedIn");
    String? type = prefs.getString("type");
    if (log == true) {
      Timer(const Duration(seconds: 2), () {
        String? number = prefs.getString("number");
        if (type == "institute") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LandingPage()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Home(number: number!)));
        }
      });
    } else if (log == null || log == false) {
      setState(() {
        logIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isLoggedIn(context);
    return Scaffold(
      body: logIn
          ? Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Enter()));
                    },
                    child: const Text("Login as an Institute")),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Splash()));
                    },
                    child: const Text("Login as a Student")),
              ],
            ))
          : const Center(child: Text("magLib")),
    );
  }
}
