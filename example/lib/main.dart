import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vonage_video/vonage.dart';
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

  @override
  void dispose() {
    super.dispose();
    vonage.disconnect();
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
        body: SafeArea(
          child: AnimatedBuilder(
            animation: vonage,
            builder: (context, snapshot) {
              return Stack(
                children: [
                  if (vonage.subscribers.isNotEmpty)
                    Positioned.fill(
                      left: 0,
                      top: 0,
                      child: Column(
                        children: [
                          for (final sub in vonage.subscribers)
                            Expanded(child: _subscriberView(sub)),
                        ],
                      ),
                    ),
                  if (vonage.isPublishing)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 120,
                        height: 200,
                        child: VonagePublisherVideo(scale: VonageVideoScale.FILL),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FloatingActionButton(
                            onPressed: () => vonage.toggleVideoPublishing(),
                            child: Icon(
                              vonage.videoEnabled
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FloatingActionButton(
                            onPressed: () => vonage.toggleAudioPublishing(),
                            child: Icon(
                              vonage.audioEnabled
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _subscriberView(VonageSubscriber subscriber) {
    return Stack(
      children: [
        VonageSubscriberVideo(id: subscriber.id, scale: VonageVideoScale.FILL),
        Container(
          color: Color.fromRGBO(0, 0, 0, 0.7),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              subscriber.name,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
