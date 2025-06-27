import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
}