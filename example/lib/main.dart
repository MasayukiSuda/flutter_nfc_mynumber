import 'package:flutter/material.dart';
import 'package:flutter_nfc_mynumber_example/mynumber_page.dart';

import 'basic_info_page.dart';
import 'login_count_page.dart';
import 'space.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _MyAppState(),
    );
  }
}

class _MyAppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter nfc Mynumber example'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('ログイン回数を取得'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginCountPage(),
                    ));
              },
            ),
            SpaceBox.height(16),
            ElevatedButton(
              child: const Text('マイナンバーを取得'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MynumberPage(),
                    ));
              },
            ),
            SpaceBox.height(16),
            ElevatedButton(
              child: const Text('基本４情報を取得'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BasicInfoPage(),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
