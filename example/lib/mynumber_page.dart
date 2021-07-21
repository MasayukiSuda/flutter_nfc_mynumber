import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_mynumber/flutter_nfc_mynumber.dart';
import 'package:flutter_nfc_mynumber/mynumber_util.dart';

import 'space.dart';

class MynumberPage extends StatefulWidget {
  @override
  _MynumberPage createState() => _MynumberPage();
}

class _MynumberPage extends State<MynumberPage> {
  TextEditingController _realNameTextController = TextEditingController();

  String _mynumberCard = "-";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイナンバーを表示する'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "券面事項入力補助用\nパスワード（４桁）",
              textAlign: TextAlign.center,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 80),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                controller: _realNameTextController,
              ),
            ),
            SpaceBox.height(16),
            Text(
              "マイナンバー\n$_mynumberCard",
              textAlign: TextAlign.center,
            ),
            SpaceBox.height(16),
            ElevatedButton(
              child: const Text('マイナンバーカードを読み込む'),
              onPressed: () async {
                var valueText = _realNameTextController.value.text;
                if (valueText.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('パスワードを入力してください'),
                  ));
                  return;
                }

                var nfcAvailability = await FlutterNfcMynumber.nfcAvailability;
                print("nfcAvailability = $nfcAvailability");

                try {
                  await FlutterNfcMynumber.startSession();

                  var mynumber = await MynumberUtil.getMyNumber(valueText);
                  setState(() {
                    _mynumberCard = mynumber;
                  });
                } catch (e) {
                  print("error $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('エラーが出ました。パスワードとマイナンバーをご確認ください。'),
                  ));
                }
                await FlutterNfcMynumber.finishSession();
              },
            )
          ],
        ),
      ),
    );
  }
}
