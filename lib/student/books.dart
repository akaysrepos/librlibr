import 'dart:collection';

import 'package:flutter/material.dart';

class Books extends StatelessWidget {
  const Books({Key? key, required this.hs}) : super(key: key);
  final HashMap<String, DateTime> hs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
            itemCount: hs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(hs.keys.elementAt(index)),
                trailing: Text(hs.values.elementAt(index).toString()),
              );
            }));
  }
}
