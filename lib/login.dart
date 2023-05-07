import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libirlibir/signup.dart';
import 'package:libirlibir/student/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? label;
  bool isLoading = false;

  TextEditingController mobileController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  void login() async {
    String mobile = mobileController.text;
    setState(() {
      isLoading = true;
    });
    await checkInFirestore(mobile);
    setState(() {
      isLoading = false;
    });
  }

  verify(String mobile) async {
    setState(() {
      isLoading = true;
    });
    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (_credential) async {
          logUser(mobile);
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pop();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Home(number: mobile)));
        },
        codeSent: (String verificationId, [int? forceResendingToken]) {
          //show dialog to take input from the user
          setState(() {
            isLoading = false;
          });
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: const Text("Enter SMS Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          // initialValue: widget.otp,
                          controller: _codeController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Done"),
                        onPressed: () {
                          String smsCode = _codeController.text.trim();

                          var _credential = PhoneAuthProvider.credential(
                              verificationId: verificationId, smsCode: smsCode);
                          _auth.signInWithCredential(_credential).then((value) {
                            logUser(mobile);
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Home(number: mobile)));
                          }).catchError((e) {
                            print(e);
                          });
                        },
                      )
                    ],
                  ));
        },
        verificationFailed: (FirebaseAuthException error) {},
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  logUser(String number) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("type", "student");
    await prefs.setString("number", number);
  }

  checkInFirestore(String mobile) async {
    firestore
        .collection("maglib")
        .doc("users")
        .collection(mobile)
        .doc("details")
        .get()
        .then((value) async {
      if (value.exists) {
        verify(mobile);
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const SignUp()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  // initialValue: widget.number,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  controller: mobileController,
                  decoration: const InputDecoration(hintText: "Enter Number"),
                ),
                ElevatedButton(onPressed: login, child: const Text("Login"))
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
