import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Vonage with ChangeNotifier {
  static const _channel = MethodChannel("vonage_video");
  var _subscribers = <String>[];
  bool isPublishing = false;
  bool videoEnabled = true;
  bool audioEnabled = true;

  List<String> get subscribers => _subscribers;

  Vonage() {
    _channel.setMethodCallHandler(_handler);
  }

  Future<void> connect({
    @required String publisherName,
    @required String apiKey,
    @required String sessionId,
    @required String token,
  }) async {
    await _channel.invokeMethod<dynamic>(
      "connect",
      <String, String>{
        "publisherName": publisherName,
        "apiKey": apiKey,
        "sessionId": sessionId,
        "token": token,
      },
    );
  }

  Future<void> toggleVideoPublishing() async {
    videoEnabled = !videoEnabled;
    notifyListeners();
    await _channel.invokeMethod<dynamic>("setVideoPublishing", videoEnabled);
  }

  Future<void> toggleAudioPublishing() async {
    audioEnabled = !audioEnabled;
    notifyListeners();
    await _channel.invokeMethod<dynamic>("setAudioPublishing", audioEnabled);
  }

  Future<void> disconnect() async {
    await _channel.invokeMethod<dynamic>("disconnect");
  }

  Future<void> publish() async {
    await _channel.invokeMethod<dynamic>("publish", null);
  }

  Future<void> _handler(MethodCall call) async {
    print("Platform called: ${call.method}");
    switch (call.method) {
      case "sessionConnected":
        publish();
        break;
      case "publisherStreamCreated":
        isPublishing = true;
        notifyListeners();
        break;
      case "publisherStreamDestroyed":
        isPublishing = false;
        notifyListeners();
        break;
      case "subscribersListUpdated":
        _updateSubscribersList(call.arguments);
        notifyListeners();
    }
  }

  void _updateSubscribersList(dynamic args) {
    try {
      List ids = args as List;
      _subscribers = ids.map((e) => e.toString()).toList();
      print(subscribers);
    } catch (ex) {
      print(ex);
    }
  }
}
