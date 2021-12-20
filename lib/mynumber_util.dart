import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'flutter_nfc_mynumber.dart';
import 'model/basic_info.dart';
import 'mynumber_command.dart';
import 'mynumber_command_error.dart';
import 'mynumber_exception.dart';

class MynumberUtil {
  static Future<int> getAuthPinRetryCount() async {
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

  static Future<int> getSigningPinRetryCount() async {
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

  static Future<List<int>> getAuthCertificate() async {
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

  static Future<List<int>> getSignatureByAuthPassword(
      String password, Uint8List digestValue) async {
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
        Uint8List.fromList(commandSignaturePin(password.codeUnits)));
    commandResultCheck(verifyUserCertificationResult,
        MynumberCommandError.WRONG_USER_AUTH_PASSWORD);

    // SELECT FILE 認証用鍵
    var selectFileAuthKeyResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileAuthKey));
    commandResultCheck(selectFileAuthKeyResult);

    // COMPUTE DIGITAL SIGNATURE
    var commandSignatureDataResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignatureData(digestValue)));
    commandResultCheck(commandSignatureDataResult);
    return commandSignatureDataResult
        .getRange(0, commandSignatureDataResult.length - 2)
        .toList();
  }

  static Future<List<int>> getSigningCertificate(String password) async {
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
        Uint8List.fromList(commandSignaturePin(password.codeUnits)));
    commandResultCheck(verifyUserCertificationResult,
        MynumberCommandError.WRONG_SIGNATURE_PASSWORD);

    // SELECT FILE CERT
    var selectFileCertResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileCert));
    commandResultCheck(selectFileCertResult);

    // READ BINARY
    return await readBinary();
  }

  static Future<List<int>> getSignatureBySigningPassword(
      String password, Uint8List digestValue) async {
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
        Uint8List.fromList(commandSignaturePin(password.codeUnits)));
    commandResultCheck(verifyUserCertificationResult,
        MynumberCommandError.WRONG_SIGNATURE_PASSWORD);

    // SELECT FILE CERT
    var selectFileCertResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileKeySync));
    commandResultCheck(selectFileCertResult);

    // COMPUTE DIGITAL SIGNATURE
    var commandSignatureDataResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignatureData(digestValue)));
    commandResultCheck(commandSignatureDataResult);
    return commandSignatureDataResult
        .getRange(0, commandSignatureDataResult.length - 2)
        .toList();
  }

  static Future<String> getMyNumber(String password) async {
    // SELECT FILE 券面入力補助AP (DF)
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandTicketInputAssistance));
    commandResultCheck(selectFile);

    // SELECT FILE 券面入力補助用PIN (EF)
    var selectFileAuthPin = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandTicketInputAssistancePin));
    commandResultCheck(selectFileAuthPin);

    // VERIFY 認証用PIN
    var verifyUserCertificationResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignaturePin(password.codeUnits)));
    commandResultCheck(verifyUserCertificationResult,
        MynumberCommandError.WRONG_TICKET_INPUT_PASSWORD);

    // SELECT FILE CERT
    var selectFileCertResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandSelectFileCert));
    commandResultCheck(selectFileCertResult);

    var mynumber = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandReadMynumber));
    commandResultCheck(mynumber);

    return mynumber
        .getRange(3, 15)
        .toList()
        .map((e) => e.toRadixString(16).substring(1, 2))
        .join();
  }

  static Future<BasicInfo> getBasicInfo(String password) async {
    // SELECT FILE 券面入力補助AP (DF)
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandTicketInputAssistance));
    commandResultCheck(selectFile);
    print("selectFile = $selectFile");

    // SELECT FILE 券面入力補助用PIN (EF)
    var selectFileAuthPin = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandTicketInputAssistancePin));
    commandResultCheck(selectFileAuthPin);
    print("selectFileAuthPin = $selectFileAuthPin");

    // VERIFY 認証用PIN
    var verifyUserCertificationResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(commandSignaturePin(password.codeUnits)));
    commandResultCheck(verifyUserCertificationResult,
        MynumberCommandError.WRONG_TICKET_INPUT_PASSWORD);
    print("verifyUserCertificationResult = $verifyUserCertificationResult");

    // SELECT FILE: 基本4情報 (EF)
    var selectBasicInfo = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandBasicInfo));
    commandResultCheck(selectBasicInfo);
    print("selectBasicInfo = $selectBasicInfo");

    var basicInfoReadBinaryLength = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandBasicInfoReadBinaryLength));
    commandResultCheck(basicInfoReadBinaryLength);
    print("basicInfoReadBinaryLength = $basicInfoReadBinaryLength");

    return await commandReadBasicInfo();
  }

  static Future<int> getTicketInputAssistanceRetryCount() async {
    // SELECT FILE 券面入力補助AP (DF)
    var selectFile = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandTicketInputAssistance));
    commandResultCheck(selectFile);
    print("selectFile = $selectFile");

    // SELECT FILE 券面入力補助用PIN (EF)
    var selectFileAuthPin = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandTicketInputAssistancePin));
    commandResultCheck(selectFileAuthPin);
    print("selectFileAuthPin = $selectFileAuthPin");

    // retry回数をGET
    var retryCountResult = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandReadRetryCount));
    commandRetryCountResultCheck(retryCountResult);

    return _getRetryCountFromResult(retryCountResult);
  }

  static void commandResultCheck(List<int> result,
      [MynumberCommandError error = MynumberCommandError.UNEXPECTED_COMMAND]) {
    if (listEquals(result.getRange(result.length - 2, result.length).toList(),
        MynumberCommand.resultSuccess)) return;
    throw MynumberException(error);
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

  static Future<BasicInfo> commandReadBasicInfo() async {
    var basicInfoReadBinary = await FlutterNfcMynumber.transceive(
        Uint8List.fromList(MynumberCommand.commandBasicInfoReadBinary));
    commandResultCheck(basicInfoReadBinary);

    var nameIndex = _indexOfCommand(
        basicInfoReadBinary, MynumberCommand.commandBasicInfoHeaderName);
    var addressIndex = _indexOfCommand(
        basicInfoReadBinary, MynumberCommand.commandBasicInfoHeaderAddress);
    var birthdayIndex = _indexOfCommand(
        basicInfoReadBinary, MynumberCommand.commandBasicInfoHeaderBirthday);
    var genderIndex = _indexOfCommand(
        basicInfoReadBinary, MynumberCommand.commandBasicInfoHeaderGender);

    var name =
        basicInfoReadBinary.getRange(nameIndex + 3, addressIndex).toList();
    var address =
        basicInfoReadBinary.getRange(addressIndex + 3, birthdayIndex).toList();
    var birthday =
        basicInfoReadBinary.getRange(birthdayIndex + 3, genderIndex).toList();
    var genderInfo = basicInfoReadBinary[genderIndex + 3].toRadixString(16);

    var gender;
    switch (genderInfo) {
      case "31":
        gender = Gender.MEN;
        break;
      case "32":
        gender = Gender.WOMEN;
        break;
      case "33":
        gender = Gender.OTHER;
        break;
      default:
        gender = Gender.MEN;
    }

    return BasicInfo(
        utf8.decode(name), utf8.decode(address), utf8.decode(birthday), gender);
  }

  static int _indexOfCommand(List<int> list, List<int> command) {
    var counter = 0;
    for (int value in list) {
      if (value == command[0]) {
        var isSame = true;
        command.asMap().forEach((int i, int commandValue) {
          if (list[counter + i] != commandValue) {
            isSame = false;
          }
        });
        if (isSame) {
          break;
        }
      }
      counter++;
    }
    if (counter == list.length) {
      return -1;
    }
    return counter;
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
