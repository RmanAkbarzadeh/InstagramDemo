import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/home_posts/posts_list.dart';
import 'package:instagram_demo/models/notification_handler.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:instagram_demo/screens/notification_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'notification.dart';

class AppPosts with ChangeNotifier{



  Future<QuerySnapshot<Map<String, dynamic>>> getPostsList(PostFrom postFrom,String userId) async {
    var response;
    AppUsers appUsers = AppUsers();
    final followingList =await appUsers.getFollowingUsers();
    if(postFrom == PostFrom.Home) {
      response = await FirebaseFirestore.instance
          .collection("posts")
          .orderBy("createdAt", descending: true).where("userId", whereIn: followingList)
          .get();
    }else if(postFrom == PostFrom.Profile){
      response = await FirebaseFirestore.instance
          .collection("posts")
          .orderBy("createdAt", descending: true)
          .where("userId", isEqualTo: userId)
          .get();
    }else if(postFrom == PostFrom.LikedProfile){
      response = await FirebaseFirestore.instance
          .collection("posts")
          .orderBy("createdAt", descending: true)
          .where("likedMember", arrayContains: userId)
          .get();
    }
    notifyListeners();
    return response;
  }

  Future<void> deletePost(PostFrom postFrom,int docIndex,String anotherUserId) async{
    var document = await getDocument(postFrom,docIndex,anotherUserId);
    await FirebaseFirestore.instance.collection('posts').doc(document.id)
        .delete()
        .then((_) => print('Deleted'))
        .catchError((error) => print('Delete failed: $error'));
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getProfilePostsList(bool isLikedPost,bool isPageView,String anotherUserId) async {
    var response;
    if (!isLikedPost) {
      if (!isPageView) {
        response = await FirebaseFirestore.instance
            .collection("posts")
            .orderBy("createdAt", descending: true)
            .where("userId", isEqualTo: anotherUserId)
            .get();
      } else {
        final _currentUser = FirebaseAuth.instance.currentUser;
        response = await FirebaseFirestore.instance
            .collection("posts")
            .orderBy("createdAt", descending: true)
            .where("userId", isEqualTo: _currentUser!.uid)
            .get();
      }
    } else {
      if (!isPageView) {
        response = await FirebaseFirestore.instance
            .collection("posts")
            .orderBy("createdAt", descending: true)
            .where("likedMember", arrayContains: anotherUserId)
            .get();
      } else {
        final _currentUser = FirebaseAuth.instance.currentUser;
        response = await FirebaseFirestore.instance
            .collection("posts")
            .orderBy("createdAt", descending: true)
            .where("likedMember", arrayContains: _currentUser!.uid)
            .get();
      }
    }
    return response;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getProfileInfoLive(bool isPageView,String anotherUserId) {
    final response;
    if (!isPageView) {
      response = FirebaseFirestore.instance
          .collection("users")
          .where("userId", isEqualTo: anotherUserId)
          .snapshots();
    } else {
      final _currentUser = FirebaseAuth.instance.currentUser;
      response = FirebaseFirestore.instance
          .collection("users")
          .where("userId", isEqualTo: _currentUser!.uid)
          .snapshots();
    }
    return response;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getProfileInfo(bool isPageView,String anotherUserId) async{
    final response;
    if(!isPageView) {
      response = await FirebaseFirestore.instance
          .collection("posts")
          .where("userId", isEqualTo: anotherUserId)
          .get();
    }else{
      final _currentUser = FirebaseAuth.instance.currentUser;
      response = await FirebaseFirestore.instance
          .collection("posts")
          .where("userId", isEqualTo: _currentUser!.uid)
          .get();
    }
    return response;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getComment(String documentId) async {
    final response = await FirebaseFirestore.instance
        .collection("posts").doc(documentId).collection("comments")
        .orderBy("commentTime", descending: false)
        .get();
    return response;
  }

  Future<int> getLiveComments(String documentId) async{
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection("posts").get();
    var document = querySnapshot.docs.firstWhere((element) => element.id==documentId);
    return document["comments"];

  }

  Future<void> addComment(String documentId,TextEditingController _commentController,BuildContext context) async {

    if (_commentController.text.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    String username = await Provider.of<AppUsers>(context,listen: false).getUserName(user!.uid);
    final response = await FirebaseFirestore.instance
        .collection("posts")
        .doc(documentId);
    response.collection("comments").doc(DateTime.now().toString())
        .set({
      "comment": _commentController.text,
      "username": username,
      "commentTime": DateTime.now(),
    });
    String anotherUserId= "";
    String imageUrl = "";
    await response.get().then((doc) {
      anotherUserId = doc["userId"];
      imageUrl = doc["imageUrl"];

    });

    String token =await NotificationHandler.getToken(anotherUserId);
    await Provider.of<AppNotifications>(context, listen: false)
        .setNotification(anotherUserId, "replied : ${_commentController.text}",imageUrl, context);
    await NotificationHandler.callOnFcmApiSendPushNotifications(token, "$username replied : ${_commentController.text}",NotificationPage.routeName);
    int _liveComments = await Provider.of<AppPosts>(context,listen: false).getLiveComments(documentId);
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(documentId)
        .update({
      "comments": _liveComments + 1
    });
    _commentController.clear();
  }

  void toggleFollow(bool isFollow,String anotherUserId,BuildContext context) async{
    final _currentUser = FirebaseAuth.instance.currentUser;
    String username = await Provider.of<AppUsers>(context,listen: false).getUserName(_currentUser!.uid);

    if(!isFollow){
      final _currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("users").doc(_currentUser!.uid).update({
        "following" : FieldValue.arrayUnion([anotherUserId])
      });
      await FirebaseFirestore.instance
          .collection("users").doc(anotherUserId).update({
        "followers" : FieldValue.arrayUnion([_currentUser.uid])
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You successfully followed !")));
      String token =await NotificationHandler.getToken(anotherUserId);
      await Provider.of<AppNotifications>(context, listen: false)
          .setNotification(anotherUserId, "started following you .","noImage", context);
      await NotificationHandler.callOnFcmApiSendPushNotifications(token, "$username started following you .",NotificationPage.routeName);
    }else{
      final _currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("users").doc(_currentUser!.uid).update({
        "following" : FieldValue.arrayRemove([anotherUserId])
      });
      await FirebaseFirestore.instance
          .collection("users").doc(anotherUserId).update({
        "followers" : FieldValue.arrayRemove([_currentUser.uid])
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You successfully unfollowed !")));
      String token =await NotificationHandler.getToken(anotherUserId);
      await Provider.of<AppNotifications>(context, listen: false)
          .setNotification(anotherUserId, "unfollowed you .","noImage", context);
      await NotificationHandler.callOnFcmApiSendPushNotifications(token, "$username unfollowed you .",NotificationPage.routeName);
    }
  }

  String daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day,from.hour,from.minute,from.second);
    to = DateTime(to.year, to.month, to.day , to.hour,to.minute,to.second);

    if((to.difference(from).inSeconds).round() < 0){
      return "Your device time is wrong .";
    }

    if((to.difference(from).inSeconds).round() < 60){
      return "${(to.difference(from).inSeconds).round()} seconds ago";
    }

    if((to.difference(from).inMinutes).round() < 60){
      return "${(to.difference(from).inMinutes).round()} minutes ago";
    }

    if((to.difference(from).inHours).round() < 24) {
      return "${(to.difference(from).inHours).round()} hours ago";
    }

    if((to.difference(from).inDays).round() < 7) {
      return "${(to.difference(from).inDays).round()} days ago";
    }

    if((to.difference(from).inDays / 7).round() < 4) {
      return "${(to.difference(from).inDays /7).round()} weeks ago";
    }

    if((to.difference(from).inDays /30).round() < 12) {
      return "${DateFormat().add_MMMd().format(from)}";
    }

    if((to.difference(from).inDays /30).round() > 12) {
      return "${DateFormat().add_yMMMd().format(from)}";
    }

    return "";
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>> getDocument(PostFrom postFrom,int docIndex,String anotherUserId) async{
    if(PostFrom.Home == postFrom) {
      AppUsers appUsers = AppUsers();
      final followingList = await appUsers.getFollowingUsers();
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection("posts").where(
          "userId", whereIn: followingList).get();
      int temp = docIndex;
      docIndex = querySnapshot.size - 1 - docIndex;
      var document = querySnapshot.docs.elementAt(docIndex);
      docIndex = temp;
      return document;
    }else{
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection("posts").where(
          "userId", isEqualTo: anotherUserId).get();
      int temp = docIndex;
      docIndex = querySnapshot.size - 1 - docIndex;
      var document = querySnapshot.docs.elementAt(docIndex);
      docIndex = temp;
      return document;
    }

  }

  void toggleLikes(bool isLike,int likes,int docIndex,PostFrom postFrom,String anotherUserId , BuildContext context) async {

    var user = FirebaseAuth.instance.currentUser;
    var document = await getDocument(postFrom,docIndex,anotherUserId);
    var liveLikes = document.get("likes");
    List<dynamic> likedMember = document["likedMember"];
    String username = await Provider.of<AppUsers>(context,listen: false).getUserName(user!.uid);

    if (isLike == false) {
      likedMember.add(user.uid);
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(document.id)
          .update({"likedMember": likedMember, "likes": liveLikes + 1});
      String token =await NotificationHandler.getToken(anotherUserId);
      await Provider.of<AppNotifications>(context, listen: false)
          .setNotification(anotherUserId, "liked your post .",document["imageUrl"], context);
      await NotificationHandler.callOnFcmApiSendPushNotifications(token, "$username liked your post",NotificationPage.routeName);
    } else {
      likedMember.removeWhere((element) => element == user.uid);
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(document.id)
          .update({"likedMember": likedMember, "likes": liveLikes - 1});
      String token =await NotificationHandler.getToken(anotherUserId);
      await Provider.of<AppNotifications>(context, listen: false)
          .setNotification(anotherUserId, "unliked your post .",document["imageUrl"], context);
      await NotificationHandler.callOnFcmApiSendPushNotifications(token, "$username unliked your post",NotificationPage.routeName);
    }
    notifyListeners();
  }
}