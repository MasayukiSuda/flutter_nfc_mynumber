#import "FlutterNfcMynumberPlugin.h"
#if __has_include(<flutter_nfc_mynumber/flutter_nfc_mynumber-Swift.h>)
#import <flutter_nfc_mynumber/flutter_nfc_mynumber-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_nfc_mynumber-Swift.h"
#endif

@implementation FlutterNfcMynumberPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNfcMynumberPlugin registerWithRegistrar:registrar];
}
@end
