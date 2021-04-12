import Flutter
import UIKit
import OpenTok

class TokboxController: NSObject, FlutterPlatformViewFactory {
    private var channel: FlutterMethodChannel
    private var session: OTSession?
    private var publisher: OTPublisher?
    private var subscribers = Dictionary<String, OTSubscriber>()
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
        self.messenger = messenger
        self.channel = channel
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        print(args);
        let viewId = args as! String
        if (viewId == "publisher") {
            return TokboxNativeView(view: publisher!.view!)
        }
        return TokboxNativeView(view: subscribers[viewId]!.view!)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func invokePlatformMethod(call: FlutterMethodCall, result: FlutterResult) -> Void {
        switch (call.method) {
            case "connect": connect(call: call, result: result); break
            case "disconnect": disconnect(result: result); break
            case "publish": publish(call: call, result: result); break
            case "setAudioPublishing": noop(result: result); break
            case "setVideoPublishing": noop(result: result); break
            default: result(FlutterMethodNotImplemented)
        }
    }
    
    private func connect(call: FlutterMethodCall, result: FlutterResult) -> Void {
        let params = call.arguments as! Dictionary<String, String>
        session = OTSession(apiKey: params["apiKey"]!, sessionId: params["sessionId"]!, delegate: self)
        var error: OTError?
        session?.connect(withToken: params["token"]!, error: &error)
        result("success")
    }
    
    private func disconnect(result: FlutterResult) -> Void {
        var error: OTError?
        session?.disconnect(&error)
        result("success")
    }
    
    private func noop(result: FlutterResult) -> Void {
        result("success")
    }
    
    private func publish(call: FlutterMethodCall, result: FlutterResult) -> Void {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        publisher = OTPublisher(delegate: self, settings: settings)
        var error: OTError?
        session?.publish(publisher!, error: &error)
        result("success")
    }
}

// MARK: - OTSessionDelegate callbacks
extension TokboxController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")
        channel.invokeMethod("sessionConnected", arguments: nil)
    }

    func sessionDidDisconnect(_ session: OTSession) {
       print("The client disconnected from the OpenTok session.")
    }

    func session(_ session: OTSession, didFailWithError error: OTError) {
       print("The client failed to connect to the OpenTok session: \(error).")
    }

    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("A stream was created in the session.")
        let subscriber = OTSubscriber(stream: stream, delegate: self)
        var error: OTError?
        session.subscribe(subscriber!, error: &error)
        subscribers[stream.streamId] = subscriber!
        channel.invokeMethod("subscribersListUpdated", arguments: Array(subscribers.keys))
    }

    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
        subscribers.removeValue(forKey: stream.streamId)
        channel.invokeMethod("subscribersListUpdated", arguments: Array(subscribers.keys))
    }
}

// MARK: - OTPublisherDelegate callbacks
extension TokboxController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
       print("The publisher failed: \(error)")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        channel.invokeMethod("publisherStreamCreated", arguments: nil)
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        channel.invokeMethod("publisherStreamDestroyed", arguments: nil)
    }
}

// MARK: - OTSubscriberDelegate callbacks
extension TokboxController: OTSubscriberDelegate {
   public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
       print("The subscriber did connect to the stream.")
   }

   public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
       print("The subscriber failed to connect to the stream.")
   }
}

// MARK: - View factory classes
class TokboxNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(view: UIView) {
        self._view = view
        super.init()
    }

    func view() -> UIView {
        return _view
    }
}
