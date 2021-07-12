import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_mynumber/mynumber_command.dart';

import 'mynumber_command_error.dart';
import 'mynumber_exception.dart';

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

  static Future<int> getLoginPinRetryCount() async {
    // SELECT FILE 公的個人認証AP
    var selectFile =
        await transceive(Uint8List.fromList(MynumberCommand.commandSelectFile));
    commandResultCheck(selectFile);

    // SELECT FILE 認証用PIN
    var selectFileAuthPin = await transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileAuthPin));
    commandResultCheck(selectFileAuthPin);

    // retry回数をGET
    var retryCountResult = await transceive(
        Uint8List.fromList(MynumberCommand.commandReadRetryCount));
    commandRetryCountResultCheck(retryCountResult);

    return _getRetryCountFromResult(retryCountResult);
  }

  static void commandResultCheck(List<int> result) {
    if (listEquals(result.getRange(result.length - 2, result.length).toList(),
        MynumberCommand.resultSuccess)) return;
    throw MynumberException(MynumberCommandError.UNEXPECTED_COMMAND);
  }

  static void commandRetryCountResultCheck(List<int> result) {
    if (result.first == MynumberCommand.retryResultSuccess) return;
    throw MynumberException(MynumberCommandError.UNEXPECTED_COMMAND);
  }

  static int _getRetryCountFromResult(List<int> result) {
    return int.parse(result.last.toRadixString(16).replaceAll("c", ""));
  }
}
