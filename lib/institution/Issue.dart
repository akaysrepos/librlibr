import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:libirlibir/institution/checkout.dart';

class Issue extends StatefulWidget {
  const Issue({Key? key, required this.number}) : super(key: key);
  final String number;

  @override
  _IssueState createState() => _IssueState();
}

class _IssueState extends State<Issue> {
  TextEditingController phoneController = TextEditingController();
  HashSet<String> books = HashSet();
  HashSet<String> rebooks = HashSet();

  reStartBarcodeScanStream() async {
    try {
      FlutterBarcodeScanner.getBarcodeStreamReceiver(
              '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
          .listen((barcode) {
        if (barcode.toString() != "-1" && rebooks.add(barcode.toString())) {
          FlutterBeep.beep();
        }
        // print(barcode);
        // books.contains(barcode.toString())
        //     ? setState(() => {books.add(barcode.toString())})
        //     : null;
      });
    } on PlatformException {
      print('Failed to get platform version.');
    }
  }

  startBarcodeScanStream() async {
    try {
      FlutterBarcodeScanner.getBarcodeStreamReceiver(
              '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
          .listen((barcode) {
        if (barcode.toString() != "-1" && books.add(barcode.toString())) {
          FlutterBeep.beep();
        }
        // print(barcode);
        // books.contains(barcode.toString())
        //     ? setState(() => {books.add(barcode.toString())})
        //     : null;
      });
    } on PlatformException {
      print('Failed to get platform version.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // TextButton(
          //     onPressed: startBarcodeScanStream, child: const Text("Scan")),
          // ListView(
          //   shrinkWrap = true,
          //   children: books.map((e) => Text(e)).toList(),
          // ),
          const SizedBox(
            height: 20.0,
          ),
          TextButton(
              onPressed: startBarcodeScanStream, child: const Text("Issue")),
          const SizedBox(
            height: 20.0,
          ),
          TextButton(onPressed: () {}, child: const Text("Check Dues")),
          const SizedBox(
            height: 20.0,
          ),
          TextButton(
              onPressed: reStartBarcodeScanStream,
              child: const Text("Re-Issue")),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: ((context) => Check(
                  number: widget.number, books: books, rebooks: rebooks))));
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
