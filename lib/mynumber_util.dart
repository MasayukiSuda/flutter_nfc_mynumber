import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'flutter_nfc_mynumber.dart';
import 'mynumber_command.dart';
import 'mynumber_command_error.dart';
import 'mynumber_exception.dart';

class MynumberUtil {
  static Future<int> getLoginPinRetryCount() async {
    // SELECT FILE 公的個人認証AP
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFile));
    commandResultCheck(selectFile);

    // SELECT FILE 認証用PIN
    var selectFileAuthPin = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileAuthPin));
    commandResultCheck(selectFileAuthPin);

    // retry回数をGET
    var retryCountResult = await FlutterNfcMynumber.transceive(
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
