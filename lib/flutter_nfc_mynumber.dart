import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Availability of the NFC reader.
enum NFCAvailability {
  not_supported,
  disabled,
  available,
}

class FlutterNfcMynumber {
  static const MethodChannel _channel =
      const MethodChannel('flutter_nfc_mynumber');

  /// get the availablility of NFC reader on this device
  static Future<NFCAvailability> get nfcAvailability async {
    final String availability =
        await _channel.invokeMethod('getNFCAvailability');
    return NFCAvailability.values
        .firstWhere((it) => it.toString() == "NFCAvailability.$availability");
  }

  // start polling
  static Future<void> startSession({
    String iosAlertMessage = "Hold your iPhone near the card",
    String iosMultipleTagMessage =
        "More than one tags are detected, please leave only one tag and try again.",
  }) async {
    final String start = await _channel.invokeMethod('startSession', {
      'iosAlertMessage': iosAlertMessage,
      'iosMultipleTagMessage': iosMultipleTagMessage,
    });
    print("startSession $start");
  }

  // Transceive data with the card / tag in the format of APDU (iso7816) or raw commands (other technologies).
  static Future<Uint8List> transceive(Uint8List capdu) async {
    return await _channel.invokeMethod('transceive', {'data': capdu});
  }

  static Future<void> finishSession(
      {String? iosAlertMessage, String? iosErrorMessage}) async {
    return await _channel.invokeMethod('finishSession', {
      'iosErrorMessage': iosErrorMessage,
      'iosAlertMessage': iosAlertMessage,
    });
  }

  /// iOS only, change currently displayed NFC reader session alert message with [message].
  /// There must be a valid session when invoking.
  /// On Android, call to this function does nothing.
  static Future<void> setIosAlertMessage(String message) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod('setIosAlertMessage', message);
    }
  }
}
