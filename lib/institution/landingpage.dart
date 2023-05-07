import 'package:flutter/material.dart';
import 'package:libirlibir/institution/Issue.dart';
import 'package:libirlibir/institution/verify.dart';
import 'package:libirlibir/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  void signout(context) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool("isLoggedIn", false);
    await prefs.setString("type", "");
    await prefs.setString("number", "");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
            TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Verify())),
                child: const Text("Verify")),
            const SizedBox(
              height: 20.0,
            ),
            TextButton(
                onPressed: () => signout(context),
                child: const Text("Sign out?")),
          ])),
    );
  }
}
