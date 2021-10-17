import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DirectChatScreenBubble extends StatelessWidget {
  final String userId;
  final String message;

  DirectChatScreenBubble(this.userId, this.message);

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return user!.uid == userId ? Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: deviceSize.width * 0.4),
        decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.15),
            borderRadius: BorderRadius.circular(20)),
        child: Text(message),
      ) ,
    ) : Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: deviceSize.width * 0.4),
        decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.15),width: 1),
            borderRadius: BorderRadius.circular(20)),
        child: Text(message),
      ) ,
    );
  }
}
