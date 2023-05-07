import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:libirlibir/institution/landingpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

class Enter extends StatelessWidget {
  Enter({Key? key}) : super(key: key);

  final TextEditingController collegeController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  void logg(context, String col, String pass) {
    firestore
        .collection("maglib")
        .doc("institute")
        .collection(col)
        .doc("details")
        .get()
        .then((value) async {
      if (value.exists) {
        if (pass == value['pass']) {
          logUser(col);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LandingPage()));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Wrong Passcode!")));
        }
      } else {
        firestore
            .collection("maglib")
            .doc("institute")
            .collection(col)
            .doc("details")
            .set({"pass": pass}, SetOptions(merge: true)).then((value) {
          logUser(col);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LandingPage()));
        });
      }
    });
  }

  logUser(String col) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("type", "institute");
    await prefs.setString("number", col);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            // initialValue: widget.number,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.center,
            controller: collegeController,
            decoration: const InputDecoration(hintText: "Enter College Number"),
          ),
          const SizedBox(
            height: 20.0,
          ),
          TextFormField(
            // initialValue: widget.number,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.center,
            controller: passController,
            decoration: const InputDecoration(hintText: "Enter passcode"),
          ),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
              onPressed: () {
                logg(context, collegeController.text, passController.text);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("boom.")));
              },
              child: const Text("Sign Up")),
        ],
      )),
    );
  }
}
