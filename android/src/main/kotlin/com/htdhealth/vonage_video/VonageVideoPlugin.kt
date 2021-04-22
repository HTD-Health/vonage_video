package com.htdhealth.vonage_video

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

/** VonageVideoPlugin */
class VonageVideoPlugin: FlutterPlugin {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private val tokboxProvider = TokboxProvider()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    flutterPluginBinding.platformViewRegistry.registerViewFactory("vonage_video_view", tokboxProvider)
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vonage_video")
    channel.setMethodCallHandler(tokboxProvider)
    tokboxProvider.channel = channel
    tokboxProvider.context = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    tokboxProvider.disconnectFromSession();
    channel.setMethodCallHandler(null)
  }
}
