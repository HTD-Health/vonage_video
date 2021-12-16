import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VonageVideoScale {
  const VonageVideoScale(this._value);

  static const FIT = VonageVideoScale("VideoStyleFit");
  static const FILL = VonageVideoScale("VideoStyleFill");

  final String _value;

  @override
  String toString() => _value;
}

class _CreationParams {
  final String id;
  final VonageVideoScale scale;

  _CreationParams({required this.id, required this.scale});

  Map<String, String> toMap() => {
    "id": id,
    "scale": scale.toString(),
  };
}

class VonagePublisherVideo extends StatelessWidget {
  const VonagePublisherVideo({
    Key? key,
    this.scale = VonageVideoScale.FILL,
  }) : super(key: key);

  final VonageVideoScale scale;

  @override
  Widget build(BuildContext context) {
    final String viewType = "vonage_video_view";
    if (Platform.isIOS)
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: _CreationParams(id: "publisher", scale: scale).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    if (Platform.isAndroid)
      return AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: _CreationParams(id: "publisher", scale: scale).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    throw ArgumentError.value("Unsupported platform");
  }
}

class VonageSubscriberVideo extends StatelessWidget {
  const VonageSubscriberVideo({
    Key? key,
    required this.id,
    this.scale = VonageVideoScale.FILL,
  }) : super(key: key);

  final String id;
  final VonageVideoScale scale;

  @override
  Widget build(BuildContext context) {
    final String viewType = "vonage_video_view";
    if (Platform.isIOS)
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: _CreationParams(id: id, scale: scale).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    if (Platform.isAndroid)
      return AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: _CreationParams(id: id, scale: scale).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    throw ArgumentError.value("Unsupported platform");
  }
}
