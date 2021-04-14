import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
