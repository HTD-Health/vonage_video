import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vonage_video/vonage_video.dart';
import 'package:vonage_video_example/tokens.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final vonage = Vonage();

  @override
  void initState() {
    super.initState();
    _connectToSession();
  }

  void _connectToSession() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await vonage.connect(
      publisherName: "Your Name",
      apiKey: TOKENS.apiKey,
      sessionId: TOKENS.sessionId,
      token: TOKENS.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedBuilder(
          animation: vonage,
          builder: (context, snapshot) {
            return Stack(
              children: [
                if (vonage.subscribers.isNotEmpty)
                  VonageSubscriberVideo(id: vonage.subscribers.first),
                if (vonage.isPublishing)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 120,
                      height: 200,
                      child: VonagePublisherVideo(),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton(
                    onPressed: () => vonage.toggleAudioPublishing(),
                    child: Icon(
                      vonage.audioEnabled ? Icons.volume_up : Icons.volume_off,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
