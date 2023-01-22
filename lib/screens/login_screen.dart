import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'home_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _otpEditingController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email;
  late String _otp;
  int _failedAttempts = 0;
  var code;
  bool _isLoading = false;
  bool _isOTPScreen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ikokas Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,

              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter email',
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 16.0),
            Visibility(
              visible: _isOTPScreen,
                child: PinCodeTextField(
                  length: 6,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  //animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    //activeFillColor: Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  //backgroundColor: Colors.blue.shade50,
                  //enableActiveFill: true,
                  controller: _otpEditingController,
                  onCompleted: (v) {
                    _isLoading = false;
                    if(_otpEditingController.text.toString() == code.toString()){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                  } else {
                      showInSnackBar("OTP incorrect.");
                      _otpEditingController.clear();
                      if(_failedAttempts<=3){
                        setState(() {
                          _failedAttempts++;
                          _isOTPScreen = true;
                          });
                      } else {
                        setState(() {
                          _isOTPScreen = false;
                        });
                        showInSnackBar("3 failed attempt, please genrate new otp");
                      }
                    }
                  },
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      //currentText = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  }, appContext: context,
                )
            ),
            _isLoading ?
                CircularProgressIndicator()
            :
            RaisedButton(
              onPressed: () async {
                _sendOTP(_emailController.text.toString());
                setState(() {
                  _isLoading = true;
                });
              },
              child: _failedAttempts<3?
              Text('Login'):
              Text('Request for new OTP'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _sendOTP(String _email) async {
    setState(() {
      _isLoading = true;
    });

    var rng = new Random();
    code = rng.nextInt(900000) + 100000;

    final response = await FirebaseFunctions.instance.httpsCallable('sendOTP')
        .call({'email': _email, 'otp': code});

      if (response.data['status'] == 'success') {
        showInSnackBar("Please check your mail for OTP.");
        setState(() {
          code = code;
          _isLoading = false;
          _isOTPScreen = true;
        });
      } else {
        showInSnackBar("Please check");
        setState(() {
          _isLoading = false;
        });
      }
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(content: Text(value));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}


