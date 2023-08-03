import 'package:firebase_messaging/firebase_messaging.dart';

// Get the token for the device
acharToken()async{
  String? deviceToken = await FirebaseMessaging.instance.getToken();
}
