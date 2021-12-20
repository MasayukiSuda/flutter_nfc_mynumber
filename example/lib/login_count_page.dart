import 'package:flutter/material.dart';
import 'package:flutter_nfc_mynumber/flutter_nfc_mynumber.dart';
import 'package:flutter_nfc_mynumber/mynumber_util.dart';

import 'space.dart';

class LoginCountPage extends StatefulWidget {
  @override
  _LoginCountPage createState() => _LoginCountPage();
}

class _LoginCountPage extends State<LoginCountPage> {
  String _authPinRetryCount = "-";
  String _signingPinRetryCount = "-";
  String _ticketInputAssistanceCount = "-";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン回数を試す'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "署名用電子証明書\n（公的個人認証 署名用）",
              textAlign: TextAlign.center,
            ),
            SpaceBox.height(16),
            Text("残り回数 $_signingPinRetryCount 回"),
            SpaceBox.height(56),
            Text(
              "利用者証明用電子証明書\n（公的個人認証 利用者証明用）",
              textAlign: TextAlign.center,
            ),
            SpaceBox.height(16),
            Text("残り回数 $_authPinRetryCount 回"),
            SpaceBox.height(56),
            Text(
              "券面事項入力補助用",
              textAlign: TextAlign.center,
            ),
            SpaceBox.height(16),
            Text("残り回数 $_ticketInputAssistanceCount 回"),
            SpaceBox.height(56),
            ElevatedButton(
              child: const Text('マイナンバーカードを読み込む'),
              onPressed: () async {
                var nfcAvailability = await FlutterNfcMynumber.nfcAvailability;
                print("nfcAvailability = $nfcAvailability");

                try {
                  await FlutterNfcMynumber.startSession();

                  await FlutterNfcMynumber.setIosAlertMessage(
                      "working on it...");

                  var authPinRetryCount =
                      await MynumberUtil.getAuthPinRetryCount();

                  var signingPinRetryCount =
                      await MynumberUtil.getSigningPinRetryCount();

                  var ticketInputAssistanceCount =
                      await MynumberUtil.getTicketInputAssistanceRetryCount();

                  setState(() {
                    _signingPinRetryCount = signingPinRetryCount.toString();
                    _authPinRetryCount = authPinRetryCount.toString();
                    _ticketInputAssistanceCount =
                        ticketInputAssistanceCount.toString();
                  });
                } catch (e) {
                  print("error $e");
                }

                await FlutterNfcMynumber.finishSession();
              },
            ),
          ],
        ),
      ),
    );
  }
}
