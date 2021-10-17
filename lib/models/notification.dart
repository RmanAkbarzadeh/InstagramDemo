import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:provider/provider.dart';

class AppNotifications with ChangeNotifier{

  Future<QuerySnapshot<Map<String, dynamic>>> getNotifications() async{
      final _currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final document = FirebaseFirestore.instance.collection("notification").where("userId",isEqualTo: _currentUserId).get();
      return document;
  }

  Future<void> setNotification(String anotherUserId,String description,String imageUrl,BuildContext context) async{
      final _currentUserId = FirebaseAuth.instance.currentUser!.uid;
      String username = await Provider.of<AppUsers>(context,listen: false).getUserName(_currentUserId);
      await FirebaseFirestore.instance.collection("notification").doc(DateTime.now().toString()).set({
        "anotherUserId" : _currentUserId,
        "userId" : anotherUserId,
        "username" : username,
        "description" : description,
        "imageUrl" : imageUrl
      });
  }
}