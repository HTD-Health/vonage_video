# Flutter Vonage Video API

An unofficial plugin for handling Vonage Video API using Dart & Flutter code.

## What is Vonage Video API?

From [Vonage Video API Development Center](https://tokbox.com/developer/):

*The Vonage Video API (formerly TokBox OpenTok) makes it easy to embed high-quality interactive video, voice, messaging, and screen sharing into web and mobile apps.*

## Installation
Add this plugin as a dependency to `pubspec.yaml`.

## Usage

### Connecting to session
Instantiate a `Vonage` object. It is used to communicate with platform-specific Vonage API. To connect to a session, you must first request permissions for camera and mic (for example, using `permission_handler` package), and then call `connect` method:
```dart
import 'package:vonage_video/vonage_video.dart';
import 'package:permission_handler/permission_handler.dart';

final vonage = Vonage();

await Permission.camera.request();
await Permission.microphone.request();

await vonage.connect(
    publisherName: "Your Name",
    apiKey: "Your API key",
    sessionId: "Your Session ID",
    token: "Your Token",
);
```
After connecting, you will automatically start publishing video and audio to the session.

### Showing camera previews
Each subscriber is available via class field `List<VonageSubscriber> Vonage.subscribers`. Those object contain unique subscriber ID and the name of the stream: 
```dart
class VonageSubscriber {
  final String id;
  final String name;
}
```
There are two widgets for showing previews. First is `VonagePublisherVideo` which shows preview of your own video, second is `VonageSubscriberVideo` which show video of other participants. Simply iterate over the list of subscribers and insert those widgets into your layout:
```dart
for (final subscriber in vonage.subscribers)
    VonageSubscriberVideo(id: subscriber.id)
```
To show your own preview, you need to check whether you are already pubishing or not by checking the flag in `Vonage` object:
```dart
if (vonage.isPublishing) VonagePublisherVideo()
else SomePlaceholder();
```

### Mute/unmute
Use `toggleAudioPublishing()` and `toggleVideoPublishing()` to flip your audio and video publishing status. Current status can be checked via `audioEnabled` and `videoEnabled` booleans.

### Updating layout
`Vonage` implements `ChangeNotifier` interface and notifies listeners when its properties change:
- When subscriber list changes (someone enters or leaves the session)
- You start/stop publishing to the stream
- You toggle your audio or video publishing status

You may want to wrap your entire layout e.g. in `AnimatedBuilder` to update your screen properly when changes occur:
```dart
AnimatedBuilder(
    animation: vonage,
    builder: (context, snapshot) {
        /// return your layout here  
    },
)
```