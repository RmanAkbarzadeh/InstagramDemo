import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_demo/models/user.dart';

class AppStories with ChangeNotifier{


  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsersWithStory() async {
    AppUsers appUsers = AppUsers();
    final followingList =await appUsers.getFollowingUsers();
    var response = await FirebaseFirestore.instance
        .collection("stories").where("storiesList",isNotEqualTo: []).where("userId",whereIn: followingList)
        .get();

    return response;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getStoriesWithUserId(String userId) {
    var response = FirebaseFirestore.instance
        .collection("stories")
        .where("userId", isEqualTo: userId)
        .get();
    return response;
  }

  Future<int> getStoriesSize(String userId) async{
    int size = 0;
    var doc = await FirebaseFirestore.instance
        .collection("stories")
        .doc(userId)
        .get();
      final list =  doc["storiesList"] as List<dynamic>;
      size = list.length;
    return size;
  }

  String storyTimeBetween(DateTime from, DateTime to,String userId,Timestamp timestamp,String imageUrl) {
    from = DateTime(from.year, from.month, from.day,from.hour,from.minute,from.second);
    to = DateTime(to.year, to.month, to.day , to.hour,to.minute,to.second);

    if((to.difference(from).inSeconds).round() < 0){
      return "Your device time is wrong .";
    }

    if((to.difference(from).inSeconds).round() < 60){
      return "${(to.difference(from).inSeconds).round()}s";
    }

    if((to.difference(from).inMinutes).round() < 60){
      return "${(to.difference(from).inMinutes).round()}m";
    }

    if((to.difference(from).inHours).round() < 24) {
      return "${(to.difference(from).inHours).round()}h";
    }

    if((to.difference(from).inHours).round() > 24) {
      _removeStory(userId,timestamp,imageUrl);
      return "${(to.difference(from).inHours).round()}h";
    }

    return "";
  }

  void _removeStory(String userId,Timestamp timestamp,String imageUrl) async{
    await FirebaseFirestore.instance
        .collection("stories")
        .doc(userId).update({
      "storiesList" : FieldValue.arrayRemove([{
        "createdAt" : timestamp,
        "imageUrl" : imageUrl
      }])
    });
  }

}