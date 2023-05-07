import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:libirlibir/login.dart';
import 'package:libirlibir/main.dart';
import 'package:libirlibir/student/books.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.number}) : super(key: key);
  final String number;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HashMap<String, DateTime> hs = HashMap();

  @override
  initState() {
    super.initState();
    getData();
  }

  getData() async {
    firestore
        .collection("maglib")
        .doc("users")
        .collection(widget.number)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.id != "details") {
          hs.putIfAbsent(element.id, () => DateTime.parse(element['due']));
          // print(DateTime.parse(element['due']));
        }
      });
    });
  }

  void checkDues(context) {
    DateTime dt = DateTime.now();
    int dues = 0;
    for (String s in hs.keys) {
      dues += dt.difference(hs[s]!).inDays;
      // print("dey" + hs[s].toString());
    }
    dues = dues ~/ 28 * 50;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(dues.toString()),
            ));
  }

  void books(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Books(hs: hs)));
  }

  void signout(context) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool("isLoggedIn", false);
    await prefs.setString("type", "");
    await prefs.setString("number", "");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Text(widget.number),
          const SizedBox(
            height: 20.0,
          ),
          TextButton(
              onPressed: () => checkDues(context),
              child: const Text("Check dues")),
          const SizedBox(
            height: 20.0,
          ),
          TextButton(
              onPressed: () => books(context),
              child: const Text("Issued Books")),
          const SizedBox(
            height: 20.0,
          ),
          TextButton(
              onPressed: () => signout(context),
              child: const Text("Sign out?")),
        ],
      )),
    );
  }
}
