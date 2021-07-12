import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_mynumber/flutter_nfc_mynumber.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Button'),
            onPressed: () async {
              try {
                var nfcAvailability = await FlutterNfcMynumber.nfcAvailability;
                print("nfcAvailability = $nfcAvailability");

                await FlutterNfcMynumber.startSession();

                await FlutterNfcMynumber.setIosAlertMessage("working on it...");

                var loginPinRetryCount =
                    await FlutterNfcMynumber.getLoginPinRetryCount();


                print("loginPinRetryCount = $loginPinRetryCount");
              } catch (e) {
                print("e = $e");
              }
              sleep(new Duration(seconds: 1));
              await FlutterNfcMynumber.finishSession();
            },
          ),
        ),
      ),
    );
  }
}
