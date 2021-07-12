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

  static Future<int> getDocumentPinRetryCount() async {
    // SELECT FILE 公的個人認証AP
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFile));
    commandResultCheck(selectFile);

    // SELECT FILE 認証用PIN
    var selectFileAuthPin = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFilePinSync));
    commandResultCheck(selectFileAuthPin);

    // retry回数をGET
    var retryCountResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandReadRetryCount));
    commandRetryCountResultCheck(retryCountResult);

    return _getRetryCountFromResult(retryCountResult);
  }

  static Future<List<int>> getLoginCertificate() async {
    // SELECT FILE 公的個人認証AP
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFile));
    commandResultCheck(selectFile);

    // SELECT FILE 認証用証明書
    var selectFileAuthCertResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileAuthCert));
    commandResultCheck(selectFileAuthCertResult);

    // READ BINARY
    return await readBinary();
  }

  static Future<List<int>> getSignatureByLoginPassword(
      String loginPassword, String digestValue) async {
    // SELECT FILE 公的個人認証AP
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFile));
    commandResultCheck(selectFile);

    // SELECT FILE 認証用PIN
    var selectFileAuthPinResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileAuthPin));
    commandResultCheck(selectFileAuthPinResult);

    // VERIFY 認証用PIN
    var verifyUserCertificationResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignaturePin(loginPassword.codeUnits)));
    commandResultCheck(verifyUserCertificationResult);

    // SELECT FILE 認証用鍵
    var selectFileAuthKeyResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileAuthKey));
    commandResultCheck(selectFileAuthKeyResult);

    // COMPUTE DIGITAL SIGNATURE
    var commandSignatureDataResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignatureData(digestValue.codeUnits)));
    commandResultCheck(commandSignatureDataResult);
    return commandSignatureDataResult
        .getRange(0, commandSignatureDataResult.length - 2)
        .toList();
  }

  static Future<List<int>> getDocumentCertificate(
      String documentPassword) async {
    // SELECT FILE 公的個人認証AP
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFile));
    commandResultCheck(selectFile);

    // SELECT FILE 認証用PIN
    var selectFileAuthPin = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFilePinSync));
    commandResultCheck(selectFileAuthPin);

    // VERIFY 認証用PIN
    var verifyUserCertificationResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignaturePin(documentPassword.codeUnits)));
    commandResultCheck(verifyUserCertificationResult);

    // SELECT FILE CERT
    var selectFileCertResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileCert));
    commandResultCheck(selectFileCertResult);

    // READ BINARY
    return await readBinary();
  }

  static Future<List<int>> getSignatureByDocumentPassword(
      String documentPassword, String digestValue) async {
    // SELECT FILE 公的個人認証AP
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFile));
    commandResultCheck(selectFile);

    // SELECT FILE 認証用PIN
    var selectFileAuthPin = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFilePinSync));
    commandResultCheck(selectFileAuthPin);

    // VERIFY 認証用PIN
    var verifyUserCertificationResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignaturePin(documentPassword.codeUnits)));
    commandResultCheck(verifyUserCertificationResult);

    // SELECT FILE CERT
    var selectFileCertResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileKeySync));
    commandResultCheck(selectFileCertResult);

    // COMPUTE DIGITAL SIGNATURE
    var commandSignatureDataResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignatureData(digestValue.codeUnits)));
    commandResultCheck(commandSignatureDataResult);
    return commandSignatureDataResult
        .getRange(0, commandSignatureDataResult.length - 2)
        .toList();
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

  static Future<List<int>> readBinary() async {
    var outByte = <int>[];
    final response = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandReadBinary));
    if (listEquals(response, MynumberCommand.resultSuccess)) return response;
    final readLength = bytesToUnsignedShort(response[2], response[3], true) + 4;
    final blockNum = (readLength / blockLength.toDouble()).ceil();
    for (int i = 0; i < blockNum; i++) {
      var ret = await FlutterNfcMynumber.transceive(
          Uint8List.fromList(commandReadBlock(i)));
      commandResultCheck(ret);
      if (ret.length <= 2) {
        break;
      }
      outByte.addAll(ret.getRange(0, ret.length - 2));
    }
    return outByte.getRange(0, readLength).toList();
  }

  static List<int> commandReadBlock(int readIndex) {
    return [0x00, 0xB0, readIndex.toUnsigned(16), 0x00, 0x00];
  }

  static int bytesToUnsignedShort(int byte1, int byte2, bool bigEndian) {
    return bigEndian
        ? (((byte1 & 255) << 8) | (byte2 & 255))
        : (((byte2 & 255) << 8) | (byte1 & 255));
  }

  static List<int> commandSignaturePin(List<int> data) {
    var result = <int>[];
    result.addAll(MynumberCommand.commandPinVerify);
    result.add(data.length.toUnsigned(16));
    result.addAll(data);
    return result;
  }

  static List<int> commandSignatureData(List<int> data) {
    var result = <int>[];
    result.addAll(MynumberCommand.commandSignatureDataHeader);
    result.add(data.length.toUnsigned(16));
    result.addAll(data);
    result.add(0.toUnsigned(16));
    return result;
  }

  static int blockLength = 256;
}
