# flutter_nfc_mynumber
Flutter plugin for accessing the Japanese Mynumber features on Android and iOS.

## Setup

**Android Setup**

* Add [android.permission.NFC](https://developer.android.com/reference/android/Manifest.permission.html#NFC) to your `AndroidMenifest.xml`.

**iOS Setup**

* Add [Near Field Communication Tag Reader Session Formats Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_nfc_readersession_formats) to your entitlements.

* Add [NFCReaderUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nfcreaderusagedescription) to your `Info.plist`.

* Add [com.apple.developer.nfc.readersession.iso7816.select-identifiers](https://developer.apple.com/documentation/bundleresources/information_property_list/select-identifiers) to your `Info.plist`.

* Add the following 4 items to [com.apple.developer.nfc.readersession.iso7816.select-identifiers](https://developer.apple.com/documentation/bundleresources/information_property_list/select-identifiers)

1. `D392F000260100000001`
1. `D3921000310001010408`
1. `D3921000310001010100`
1. `D3921000310001010401`


## Usage

```Dart
import 'package:flutter_nfc_mynumber/flutter_nfc_mynumber.dart';
import 'package:flutter_nfc_mynumber/mynumber_util.dart';

var nfcAvailability = await FlutterNfcMynumber.nfcAvailability;
if (availability != NFCAvailability.available) {
    // oh-no
}

try{
  await FlutterNfcMynumber.startSession();

  await FlutterNfcMynumber.setIosAlertMessage("connecting...");

  // get retry count
  await MynumberUtil.getAuthPinRetryCount();
  await MynumberUtil.getSigningPinRetryCount();

  // get signature value
  await MynumberUtil.getSignatureByAuthPassword("password", "digestValue");
  await MynumberUtil.getSignatureBySigningPassword("password", "digestValue");

  // send original APDU command.
  await FlutterNfcMynumber.transceive(Uint8List.fromList([0x00, 0xB0, 0x00, 0x00, 0x04]))
} catch (e) {}

await FlutterNfcMynumber.finishSession();
```

A more complicated example can be seen in example dir.

## Special Thanks to
- [flutter-nfc-manager](https://github.com/okadan/flutter-nfc-manager)
- [flutter_nfc_kit](https://github.com/nfcim/flutter_nfc_kit)



