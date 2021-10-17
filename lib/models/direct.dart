import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_screen.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:provider/provider.dart';

import 'notification_handler.dart';

class AppDirects with ChangeNotifier {


  Stream<DocumentSnapshot<Map<String, dynamic>>> getDirectList()  {
    final _currentUser = FirebaseAuth.instance.currentUser;
    final response = FirebaseFirestore.instance
        .collection("direct")
        .doc(_currentUser!.uid)
        .snapshots();
    return response;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessage(String anotherUserId) {
    final _currentUser = FirebaseAuth.instance.currentUser;
    final response = FirebaseFirestore.instance
        .collection("direct")
        .doc(_currentUser!.uid)
        .collection(anotherUserId)
        .orderBy("createdAt", descending: true)
        .snapshots();
    return response;
  }

  void sendMessage(String anotherUserId, String message,BuildContext context) async {
    final _currentUser = FirebaseAuth.instance.currentUser;
    if(message.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter an Message !")));
      return;
    }
    String username = await Provider.of<AppUsers>(context,listen: false).getUserName(_currentUser!.uid);
    await FirebaseFirestore.instance
        .collection("direct")
        .doc(_currentUser.uid)
        .collection(anotherUserId)
        .doc(DateTime.now().toString())
        .set({
      "message": message,
      "userId": _currentUser.uid,
      "createdAt": DateTime.now()
    });

    await FirebaseFirestore.instance
        .collection("direct")
        .doc(anotherUserId)
        .collection(_currentUser.uid)
        .doc(DateTime.now().toString())
        .set({
      "message": message,
      "userId": _currentUser.uid,
      "createdAt": DateTime.now()
    });


    await addUserToChatList(anotherUserId);
    String token =await NotificationHandler.getToken(anotherUserId);
    await NotificationHandler.callOnFcmApiSendPushNotifications(token, "$username send a message : ${message}",DirectScreen.routeName);
  }

  Future<void> addUserToChatList(String anotherUserId) async {
    final _currentUser = FirebaseAuth.instance.currentUser;
    var chatList = [];

    final response = await FirebaseFirestore.instance
        .collection("direct")
        .doc(anotherUserId);

    response.get().then((doc) => chatList = doc["chatList"] );


    await FirebaseFirestore.instance
        .collection("direct")
        .doc(_currentUser!.uid).update({
          "chatList": FieldValue.arrayUnion([anotherUserId],)
    });;

    if(!chatList.contains(_currentUser.uid)) {
      response.update({
        "chatList": FieldValue.arrayUnion([_currentUser.uid],)
      });;
    }
  }

  String daysBetween(DateTime from, DateTime to) {
    from = DateTime(
        from.year, from.month, from.day, from.hour, from.minute, from.second);
    to = DateTime(to.year, to.month, to.day, to.hour, to.minute, to.second);

    if ((to.difference(from).inSeconds).round() < 0) {
      return "Your device time is wrong .";
    }

    if ((to.difference(from).inSeconds).round() < 60) {
      return "${(to.difference(from).inSeconds).round()}s";
    }

    if ((to.difference(from).inMinutes).round() < 60) {
      return "${(to.difference(from).inMinutes).round()}m";
    }

    if ((to.difference(from).inHours).round() < 24) {
      return "${(to.difference(from).inHours).round()}h";
    }

    if ((to.difference(from).inDays).round() < 7) {
      return "${(to.difference(from).inDays).round()}d";
    }

    if ((to.difference(from).inDays / 7).round() < 4) {
      return "${(to.difference(from).inDays / 7).round()}w";
    }

    return "";
  }
}
