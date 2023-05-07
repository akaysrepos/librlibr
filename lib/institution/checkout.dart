import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libirlibir/login.dart';

class Check extends StatelessWidget {
  const Check(
      {Key? key,
      required this.number,
      required this.books,
      required this.rebooks})
      : super(key: key);
  final String number;
  final HashSet<String> books;
  final HashSet<String> rebooks;

  checkout() {
    DateTime dt = DateTime.now().add(const Duration(days: 30));
    String date = DateFormat('yyyy-MM-dd').format(dt).toString();
    var f = firestore.collection("maglib").doc("users").collection(number);
    for (String s in books) {
      f.doc(s).set({"due": date}, SetOptions(merge: true)).then((value) {});
    }
    for (String s in rebooks) {
      f.doc(s).set({"due": date}, SetOptions(merge: true)).then((value) {});
    }
  }

  List<Widget> bookList() {
    List<Widget> list = [];
    list.add(const Text("Issue:"));
    for (String s in books) {
      list.add(Text(s));
    }
    list.add(const Text(""));
    list.add(const Text("re-Issue:"));
    for (String s in rebooks) {
      list.add(Text(s));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bookList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: checkout,
        child: const Icon(Icons.done),
      ),
    );
  }
}
