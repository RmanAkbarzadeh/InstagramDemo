import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationHandler{

  static Future<bool> callOnFcmApiSendPushNotifications(String userToken,String message, String routeName) async {

    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to" : userToken,
      "collapse_key" : "type_a",
      "notification" : {
        "title": 'Instagram Demo',
        "body" : message,
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "status": "done",
        "screen": routeName,
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=AAAAZIWOMw8:APA91bGYSj_mP7eG6zJbuN00qzPq2I_9z791WZ04R8pu-qiF3DPdI8aK2C5QX2tW2O3Ds9CD4FABU9DITlQIQcXyNvKXeqDTsbWkS6wK90rcblHwBtNWF-hI0uONsv-Z-A5p4tn3Pysm' // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      print('ok push CFM');
      return true;
    } else {
      print('CFM error !');
      // on failure do sth
      return false;
    }
  }

  static Future<String> getToken(userId)async{

    final FirebaseFirestore _db = FirebaseFirestore.instance;

    var token;
    await _db.collection('users')
        .doc(userId)
        .get().then((snapshot){
          token = snapshot["token"];
    });

    return token;

  }

  static Future<void> showNotification(
      int notificationId,
      String notificationTitle,
      String notificationContent,
      String payload, {
        String channelId = '12345',
        String channelTitle = 'Android Channel',
        String channelDescription = 'Default Android Channel for notifications',
        Priority notificationPriority = Priority.max,
        Importance notificationImportance = Importance.max,
        required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
      }) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription,
      playSound: false,
      importance: notificationImportance,
      priority: notificationPriority,
    );
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationContent,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}