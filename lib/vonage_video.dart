import 'dart:io';

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

  Future<void> connect(String apiKey, String sessionId, String token) async {
    await _channel.invokeMethod<dynamic>(
      "connect",
      <String, String>{
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

class VonagePublisherVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String viewType = "vonage_video_view";
    if (Platform.isIOS)
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: "publisher",
        creationParamsCodec: const StandardMessageCodec(),
      );
    if (Platform.isAndroid)
      return AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: "publisher",
        creationParamsCodec: const StandardMessageCodec(),
      );
    throw ArgumentError.value("Unsupported platform");
  }
}

class VonageSubscriberVideo extends StatelessWidget {
  final String id;

  VonageSubscriberVideo({Key key, @required this.id}) : super(key: key) {
    print("Creating view for subscriber=${this.id}");
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = "vonage_video_view";
    if (Platform.isIOS)
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: id,
        creationParamsCodec: const StandardMessageCodec(),
      );
    if (Platform.isAndroid)
      return AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: id,
        creationParamsCodec: const StandardMessageCodec(),
      );
    throw ArgumentError.value("Unsupported platform");
  }
}
