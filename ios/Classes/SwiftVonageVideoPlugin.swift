import Flutter
import UIKit

public class SwiftVonageVideoPlugin: NSObject, FlutterPlugin {
  var tokboxController: TokboxController?

  init(messenger: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
      tokboxController = TokboxController(messenger: messenger, channel: channel)
      super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "vonage_video", binaryMessenger: registrar.messenger())
    let instance = SwiftVonageVideoPlugin(messenger: registrar.messenger(), channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(instance.tokboxController!, withId: "vonage_video_view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    tokboxController?.invokePlatformMethod(call: call, result: result)
  }
}
