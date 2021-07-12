import CoreNFC
import Flutter
import UIKit

@available(iOS 13.0, *)
public class SwiftFlutterNfcMynumberPlugin: NSObject, FlutterPlugin, NFCTagReaderSessionDelegate {

    var session: NFCTagReaderSession?
    var result: FlutterResult?
    var tag: NFCTag?
    var multipleTagMessage: String?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_nfc_mynumber", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterNfcMynumberPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getNFCAvailability": getNFCAvailability(result: result)
        case "startSession": startSession(call: call, result: result)
        case "transceive": transceive(call: call, result: result)
        case "finishSession": finishSession(call: call, result: result)
        case "setIosAlertMessage": setIosAlertMessage(call: call, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
    
    private func getNFCAvailability(result: @escaping FlutterResult){
        if NFCReaderSession.readingAvailable {
            result("available")
        } else {
            result("disabled")
        }
    }
    
    private func startSession(call: FlutterMethodCall, result: @escaping FlutterResult){
        if session != nil {
            result(FlutterError(code: "406", message: "Cannot invoke poll in a active session", details: nil))
        } else {
            let arguments = call.arguments as! [String: Any?]
            session = NFCTagReaderSession(pollingOption: NFCTagReaderSession.PollingOption.iso14443, delegate: self)
            if let alertMessage = arguments["iosAlertMessage"] as? String {
                session?.alertMessage = alertMessage
            }
            if let multipleTagMessage = arguments["iosMultipleTagMessage"] as? String {
                self.multipleTagMessage = multipleTagMessage
            }
            //result("sessionStart")
            self.result = result
            session?.begin()
        }
    }
    
    private func finishSession(call: FlutterMethodCall, result: @escaping FlutterResult){
        self.result?(FlutterError(code: "406", message: "Session not active", details: nil))
        self.result = nil

        if let session = session {
            let arguments = call.arguments as! [String: Any?]
            let alertMessage = arguments["iosAlertMessage"] as? String
            let errorMessage = arguments["iosErrorMessage"] as? String

            if let errorMessage = errorMessage {
                session.invalidate(errorMessage: errorMessage)
            } else {
                if let alertMessage = alertMessage {
                    session.alertMessage = alertMessage
                }
                session.invalidate()
            }
            self.session = nil
        }

        tag = nil
        result(nil)
    }
    
    private func transceive(call: FlutterMethodCall, result: @escaping FlutterResult){
        if tag != nil {
            let req = (call.arguments as? [String: Any?])?["data"]
            if req != nil || req is FlutterStandardTypedData {
                var data: Data?
                switch req {
                case let binReq as FlutterStandardTypedData:
                    data = binReq.data
                default:
                    data = nil
                }

                switch tag {
                case let .iso7816(tag):
                    var apdu: NFCISO7816APDU?
                    if data != nil {
                        apdu = NFCISO7816APDU(data: data!)
                    }
                    if apdu != nil {
                        tag.sendCommand(apdu: apdu!, completionHandler: { (response: Data, sw1: UInt8, sw2: UInt8, error: Error?) in
                            if let error = error {
                                result(FlutterError(code: "500", message: "Communication error", details: error.localizedDescription))
                            } else {
                                var response = response
                                response.append(contentsOf: [sw1, sw2])
                                result(response)
                            }
                        })
                    } else {
                        result(FlutterError(code: "400", message: "Command format error", details: nil))
                    }
                default:
                    result(FlutterError(code: "405", message: "Transceive not supported on this type of card", details: nil))
                }
            } else {
                result(FlutterError(code: "400", message: "Bad argument", details: nil))
            }
        } else {
            result(FlutterError(code: "406", message: "No tag polled", details: nil))
        }
    }
    
    private func setIosAlertMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        if let session = session {
            if let alertMessage = call.arguments as? String {
                session.alertMessage = alertMessage
            }
            result(nil)
        } else {
            result(FlutterError(code: "406", message: "Session not active", details: nil))
        }
    }
    
    // from NFCTagReaderSessionDelegate
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    // from NFCTagReaderSessionDelegate
    public func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if result != nil {
            NSLog("Got error when reading NFC: %@", error.localizedDescription)
            result?(FlutterError(code: "500", message: "Invalidate session with error", details: error.localizedDescription))
            result = nil
            session = nil
            tag = nil
        }
    }
    
    // from NFCTagReaderSessionDelegate
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            // Restart polling in 500ms
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            if multipleTagMessage != nil {
                session.alertMessage = multipleTagMessage!
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) {
                session.restartPolling()
            }
            return
        }
        
        let firstTag = tags.first!

        //var result: [String: Any] = [:]

        session.connect(to: firstTag, completionHandler: { (error: Error?) in
            if let error = error {
                self.result?(FlutterError(code: "500", message: "Error connecting to card", details: error.localizedDescription))
                self.result = nil
                return
            }
            self.tag = firstTag
            
            var ndefTag: NFCNDEFTag?
            switch self.tag {
            case let .iso7816(tag):
                ndefTag = tag
            default:
                ndefTag = nil
            }
            
            if ndefTag != nil {
                ndefTag!.queryNDEFStatus(completionHandler: { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                    if error != nil {
                        NSLog("queryNDEFStatus error = " + error.debugDescription)
                    }
                    self.result?("startSession")
                    self.result = nil
                })
            } else {
                self.result?("startSession")
                self.result = nil
            }
        })
    }
}
